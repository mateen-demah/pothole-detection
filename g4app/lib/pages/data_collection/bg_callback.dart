import 'dart:async';
import 'dart:math';
import 'package:g4app/pages/data_collection/database.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:stats/stats.dart';

const speedMonitorKey = "kinsaga.g4.speedMonitoringTask";
const dataCollectionTask = "kinsaga.g4.dataCollecionTask";
const predictionTask = "kinsaga.g4.predictionTask";
const uploadingTask = "kinsaga.g4.uploadingTask";

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != predictionTask) {
      Location location = new Location();

      PermissionStatus _permissionGranted;

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return Future.value(false);
        }
      }
    }
    var preferences = await SharedPreferences.getInstance();
    switch (taskName) {
      case speedMonitorKey:
        return monitorSpeed(preferences);
      case dataCollectionTask:
        return collectData(preferences);
      case predictionTask:
        return startPredicting();
      case uploadingTask:
        return uploadRegisteredPotholes();
      default:
        return Future.value(true);
    }
  });
}

FutureOr<bool> monitorSpeed(preferences) async {
  Location location = new Location();
  double? speed;

  bool _serviceEnabled;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return Future.value(false);
    }
  }

  _locationData = await location.getLocation();
  speed = _locationData.speed;
  var index = await preferences.getInt("nextSpeedIndex");
  await preferences.setDouble("$index", speed!);
  preferences.setInt("nextSpeedIndex", (index! + 1) % 3);

  var prefKeys = await preferences.getKeys();
  if (prefKeys.containsAll(['1', '2', '0'])) {
    var zero = await preferences.getDouble('0');
    var one = await preferences.getDouble('1');
    var two = await preferences.getDouble('2');

    if ((zero! + one! + two!) / 3 > 20) {
      // TODO start datacollectiontask and stop this one
    }
  }
  return true;
}

Timer? timer;
FutureOr<bool> collectData(preferences) async {
  var dataSessions = await SensorDataDb.instance.readAllSessionInfo();
  var numOfSessions = dataSessions.length;
  timer = Timer.periodic(Duration(milliseconds: 200),
      (_) => getDataPoint("session$numOfSessions", preferences));
  return true;
}

int timestamp = 0;
int startTime = DateTime.now().millisecondsSinceEpoch;
double? gpsLat, gpsLong, speed, speedAccuracy;
final accValues = List.filled(3, 0.0);
final gyroValues = List.filled(3, 0.0);
final speedHistory = SpeedHistory();

class SpeedHistory {
  List<double> history = [];
  void add() {
    history.insert(0, speed!);
    history = history.sublist(0, 3);
  }
}

Future<void> getDataPoint(sessionId, SharedPreferences preferences) async {
  timestamp = DateTime.now().millisecondsSinceEpoch;
  var lastSavedTick = preferences.getInt("lastSavedTick");
  fetchSensorData();
  gpsLatLong();
  var session = await SensorDataDb.instance
      .insert("sessionInfo", {'session_id': sessionId});
  if (session == 0) return;
  print('attempt save ======================================');
  await SensorDataDb.instance.insert('rawSensorData', {
    'timestamp': timestamp,
    'latitude': gpsLat!,
    'longitude': gpsLong!,
    'accelerometer_x': accValues[0],
    'accelerometer_y': accValues[1],
    'accelerometer_z': accValues[2],
    'gyroscope_x': gyroValues[0],
    'gyroscope_y': gyroValues[1],
    'gyroscope_z': gyroValues[2],
    'moving_speed': speed!,
    'moving_speed_accuracy': speedAccuracy!,
    'session_id': sessionId,
  });
  if (timer!.tick - lastSavedTick! >= 200) speedHistory.add();
  if (speedHistory.history.length == 3 && speedHistory.history.average < 25) {
    // todo: stop this task and start monitoring speed
    timer?.cancel();
  }
}

Future<void> fetchSensorData() async {
  userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    accValues[0] = filter(event.x);
    accValues[1] = filter(event.y);
    accValues[2] = filter(event.z);
  });
// [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]

  gyroscopeEvents.listen((GyroscopeEvent event) {
    gyroValues[0] = filter(event.x);
    gyroValues[1] = filter(event.y);
    gyroValues[2] = filter(event.z);
  });
// [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]
}

double filter(double value) {
  return value.abs() > 0.2 ? value : 0;
}

Future<void> gpsLatLong() async {
  Location location = new Location();

  bool _serviceEnabled;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }
  _locationData = await location.getLocation();
  gpsLat = _locationData.latitude;
  gpsLong = _locationData.longitude;
  speed = _locationData.speed;
  speedAccuracy = _locationData.speedAccuracy;
}

FutureOr<bool> startPredicting() async {
  var dataSessions = await SensorDataDb.instance.readAllSessionInfo();
  for (var session in dataSessions) {
    if (session["is_uploaded"] == 1) {
    } else if (session["is_predicted"] == 1) {
    } else if (session["is_extracted"] == 1)
      await makePredictions(session["session_id"]);
    else {
      await extractFeatures(session["session_id"]);
      await makePredictions(session["session_id"]);
    }
  }
  return true;
}

Future extractFeatures(session_id) async {
  // load data from db
  final db = await SensorDataDb.instance.database;
  final sessionData = await db?.query(
    "rawSensorData",
    where: "session_id = ?",
    whereArgs: [session_id],
    orderBy: "timestamp",
  );
  int index = 0;
  int dataSize = sessionData!.length;
  while (dataSize > index) {
    var window = sessionData.sublist(index, min(index + 5, dataSize - index));

    int timestamp = window[window.length ~/ 2]["timestamp"] as int;
    double latitude = window[-1]["latitude"] as double;
    double longitude = window[-1]["longitude"] as double;

    List<double> accelerometer_x_values = [];
    List<double> accelerometer_y_values = [];
    List<double> accelerometer_z_values = [];
    List<double> gyroscope_x_values = [];
    List<double> gyroscope_y_values = [];
    List<double> gyroscope_z_values = [];
    List<double> speed_values = [];

    window.forEach((datapoint) {
      accelerometer_x_values.add(datapoint["accelerometer_x"] as double);
      accelerometer_y_values.add(datapoint["accelerometer_y"] as double);
      accelerometer_z_values.add(datapoint["accelerometer_z"] as double);
      gyroscope_x_values.add(datapoint["gyroscope_x"] as double);
      gyroscope_y_values.add(datapoint["gyroscope_y"] as double);
      gyroscope_z_values.add(datapoint["gyroscope_z"] as double);
      speed_values.add(datapoint["moving_speed"] as double);
    });

    var acc_x_stats = Stats.fromData(accelerometer_x_values);
    var avg_acc_x = acc_x_stats.average;
    var std_acc_x = acc_x_stats.standardDeviation;
    var max_acc_x = acc_x_stats.max;
    var min_acc_x = acc_x_stats.min;

    var acc_y_stats = Stats.fromData(accelerometer_y_values);
    var avg_acc_y = acc_y_stats.average;
    var std_acc_y = acc_y_stats.standardDeviation;
    var max_acc_y = acc_y_stats.max;
    var min_acc_y = acc_y_stats.min;

    var acc_z_stats = Stats.fromData(accelerometer_z_values);
    var avg_acc_z = acc_z_stats.average;
    var std_acc_z = acc_z_stats.standardDeviation;
    var max_acc_z = acc_z_stats.max;
    var min_acc_z = acc_z_stats.min;

    var gyro_x_stats = Stats.fromData(gyroscope_x_values);
    var avg_gyro_x = gyro_x_stats.average;
    var std_gyro_x = gyro_x_stats.standardDeviation;
    var max_gyro_x = gyro_x_stats.max;
    var min_gyro_x = gyro_x_stats.min;

    var gyro_y_stats = Stats.fromData(gyroscope_y_values);
    var avg_gyro_y = gyro_y_stats.average;
    var std_gyro_y = gyro_y_stats.standardDeviation;
    var max_gyro_y = gyro_y_stats.max;
    var min_gyro_y = gyro_y_stats.min;

    var gyro_z_stats = Stats.fromData(gyroscope_z_values);
    var avg_gyro_z = gyro_z_stats.average;
    var std_gyro_z = gyro_z_stats.standardDeviation;
    var max_gyro_z = gyro_z_stats.max;
    var min_gyro_z = gyro_z_stats.min;

    var speed_stats = Stats.fromData(speed_values);
    var avg_speed = speed_stats.average;
    var std_speed = speed_stats.standardDeviation;
    var max_speed = speed_stats.max;
    var min_speed = speed_stats.min;

    int success = await db!.insert("extractedFeatures", {
      "timestamp": timestamp,
      "latitude": latitude,
      "longitude": longitude,
      "avg_acc_x": avg_acc_x,
      "avg_acc_y": avg_acc_y,
      "avg_acc_z": avg_acc_z,
      "std_acc_x": std_acc_x,
      "std_acc_y": std_acc_y,
      "std_acc_z": std_acc_z,
      "max_acc_x": max_acc_x,
      "max_acc_y": max_acc_y,
      "max_acc_z": max_acc_z,
      "min_acc_x": min_acc_x,
      "min_acc_y": min_acc_y,
      "min_acc_z": min_acc_z,
      "avg_gyro_x": avg_gyro_x,
      "avg_gyro_y": avg_gyro_y,
      "avg_gyro_z": avg_gyro_z,
      "std_gyro_x": std_gyro_x,
      "std_gyro_y": std_gyro_y,
      "std_gyro_z": std_gyro_z,
      "max_gyro_x": max_gyro_x,
      "max_gyro_y": max_gyro_y,
      "max_gyro_z": max_gyro_z,
      "min_gyro_x": min_gyro_x,
      "min_gyro_y": min_gyro_y,
      "min_gyro_z": min_gyro_z,
      "avg_speed": avg_speed,
      "std_speed": std_speed,
      "max_speed": max_speed,
      "min_speed": min_speed,
      "session_id": session_id,
    });

    if (success != 0) {
      window.forEach(
        (element) => db.delete(
          "rawSensorData",
          where: "timestamp = ?",
          whereArgs: [element["timestamp"]],
        ),
      );
    }

    index += 5;
  }
  db?.update(
    "sessionInfo",
    {"is_extracted": 1},
    where: "session_id = ?",
    whereArgs: [session_id],
  );
}

Future makePredictions(session_id) async {
  var output = List.filled(1, 0.0).reshape([1, 1]);
  var interpreter = await tfl.Interpreter.fromAsset("v21.tflite");
  final db = await SensorDataDb.instance.database;
  final sessionExtractedDataPoints = await db!.query(
    "extractedFeatures",
    where: "session_id = ?",
    whereArgs: [session_id],
  );
  for (var dataPoint in sessionExtractedDataPoints) {
    interpreter.run(dataPoint.values.toList().sublist(4, 32), output);
    var label = output[0][0].round();
    db.update(
      "extractedFeatures",
      {"label": label},
      where: "timestamp = ?",
      whereArgs: [dataPoint["timestamp"]],
    );
  }
  db.update(
    "sessionInfo",
    {"is_predicted": 1},
    where: "session_id = ?",
    whereArgs: [session_id],
  );
}

FutureOr<bool> uploadRegisteredPotholes() async {
  final sessionInfo = await SensorDataDb.instance.readAllSessionInfo();
  for (var session in sessionInfo) {
    if (session["is_uploaded"] == 1)
      deleteSession(session["session_id"]);
    else if (session["is_predicted"] == 1) {
      final db = await SensorDataDb.instance.database;
      final extractedDataPoints = await db!.query(
        "extractedFeatures",
        where: "session_id = ?",
        whereArgs: [session["session_id"]],
      );
      for (var dataPoint in extractedDataPoints) {
        //todo: get proper coodinates from google
        //todo: get any potholes near it
        //todo: if new upload, otherwise increment decrement
      }
    }
  }
  return true;
}

Future deleteSession(session_id) async {
  await SensorDataDb.instance.deleteSession(session_id);
}

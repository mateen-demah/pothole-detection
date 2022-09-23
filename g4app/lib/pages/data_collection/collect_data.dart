import 'dart:async';
import 'dart:math';

import 'package:g4app/pages/data_collection/bg_callback.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stats/stats.dart';
import 'package:workmanager/workmanager.dart';

import 'database.dart';

Timer? timer;
FutureOr<bool> collectData(preferences) async {
  var dataSessions = await SensorDataDb.instance.readAllSessionInfo();
  var numOfSessions = dataSessions.length;
  timer = Timer.periodic(const Duration(milliseconds: 200),
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
    history = history.sublist(0, min(3, history.length));
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
  if (speedHistory.history.length == 3 && speedHistory.history.average < 5) {
    // stop datacollection task and start speed monitoring
    timer?.cancel();
    Workmanager().registerPeriodicTask(
      speedMonitorKey,
      speedMonitorKey,
      frequency: const Duration(seconds: 40),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
    Workmanager().cancelByUniqueName(dataCollectionTaskKey);
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
  Location location = Location();

  bool serviceEnabled;
  LocationData locationData;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }
  locationData = await location.getLocation();
  gpsLat = locationData.latitude;
  gpsLong = locationData.longitude;
  speed = locationData.speed;
  speedAccuracy = locationData.speedAccuracy;
}

import 'dart:async';
import 'dart:math';

import 'package:stats/stats.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import 'database.dart';

FutureOr<bool> startPredicting() async {
  var dataSessions = await SensorDataDb.instance.readAllSessionInfo();
  for (var session in dataSessions) {
    if (session["is_uploaded"] == 1) {
    } else if (session["is_predicted"] == 1) {
    } else if (session["is_extracted"] == 1) {
      await makePredictions(session["session_id"]);
    } else {
      await extractFeatures(session["session_id"]);
      await makePredictions(session["session_id"]);
    }
  }
  return true;
}

Future extractFeatures(sessionId) async {
  // load data from db
  final db = await SensorDataDb.instance.database;
  final sessionData = await db?.query(
    "rawSensorData",
    where: "session_id = ?",
    whereArgs: [sessionId],
    orderBy: "timestamp",
  );
  int index = 0;
  int dataSize = sessionData!.length;
  while (dataSize > index) {
    var window = sessionData.sublist(index, min(index + 5, dataSize - index));

    int timestamp = window[window.length ~/ 2]["timestamp"] as int;
    double latitude = window[-1]["latitude"] as double;
    double longitude = window[-1]["longitude"] as double;

    List<double> accelerometerXValues = [];
    List<double> accelerometerYValues = [];
    List<double> accelerometerZValues = [];
    List<double> gyroscopeXValues = [];
    List<double> gyroscopeYValues = [];
    List<double> gyroscopeZValues = [];
    List<double> speedValues = [];

    for (var datapoint in window) {
      accelerometerXValues.add(datapoint["accelerometer_x"] as double);
      accelerometerYValues.add(datapoint["accelerometer_y"] as double);
      accelerometerZValues.add(datapoint["accelerometer_z"] as double);
      gyroscopeXValues.add(datapoint["gyroscope_x"] as double);
      gyroscopeYValues.add(datapoint["gyroscope_y"] as double);
      gyroscopeZValues.add(datapoint["gyroscope_z"] as double);
      speedValues.add(datapoint["moving_speed"] as double);
    }

    var accXStats = Stats.fromData(accelerometerXValues);
    var avgAccX = accXStats.average;
    var stdAccX = accXStats.standardDeviation;
    var maxAccX = accXStats.max;
    var minAccX = accXStats.min;

    var accYStats = Stats.fromData(accelerometerYValues);
    var avgAccY = accYStats.average;
    var stdAccY = accYStats.standardDeviation;
    var maxAccY = accYStats.max;
    var minAccY = accYStats.min;

    var accZStats = Stats.fromData(accelerometerZValues);
    var avgAccZ = accZStats.average;
    var stdAccZ = accZStats.standardDeviation;
    var maxAccZ = accZStats.max;
    var minAccZ = accZStats.min;

    var gyroXStats = Stats.fromData(gyroscopeXValues);
    var avgGyroX = gyroXStats.average;
    var stdGyroX = gyroXStats.standardDeviation;
    var maxGyroX = gyroXStats.max;
    var minGyroX = gyroXStats.min;

    var gyroYStats = Stats.fromData(gyroscopeYValues);
    var avgGyroY = gyroYStats.average;
    var stdGyroY = gyroYStats.standardDeviation;
    var maxGyroY = gyroYStats.max;
    var minGyroY = gyroYStats.min;

    var gyroZStats = Stats.fromData(gyroscopeZValues);
    var avgGyroZ = gyroZStats.average;
    var stdGyroZ = gyroZStats.standardDeviation;
    var maxGyroZ = gyroZStats.max;
    var minGyroZ = gyroZStats.min;

    var speedStats = Stats.fromData(speedValues);
    var avgSpeed = speedStats.average;
    var stdSpeed = speedStats.standardDeviation;
    var maxSpeed = speedStats.max;
    var minSpeed = speedStats.min;

    int success = await db!.insert("extractedFeatures", {
      "timestamp": timestamp,
      "latitude": latitude,
      "longitude": longitude,
      "avg_acc_x": avgAccX,
      "avg_acc_y": avgAccY,
      "avg_acc_z": avgAccZ,
      "std_acc_x": stdAccX,
      "std_acc_y": stdAccY,
      "std_acc_z": stdAccZ,
      "max_acc_x": maxAccX,
      "max_acc_y": maxAccY,
      "max_acc_z": maxAccZ,
      "min_acc_x": minAccX,
      "min_acc_y": minAccY,
      "min_acc_z": minAccZ,
      "avg_gyro_x": avgGyroX,
      "avg_gyro_y": avgGyroY,
      "avg_gyro_z": avgGyroZ,
      "std_gyro_x": stdGyroX,
      "std_gyro_y": stdGyroY,
      "std_gyro_z": stdGyroZ,
      "max_gyro_x": maxGyroX,
      "max_gyro_y": maxGyroY,
      "max_gyro_z": maxGyroZ,
      "min_gyro_x": minGyroX,
      "min_gyro_y": minGyroY,
      "min_gyro_z": minGyroZ,
      "avg_speed": avgSpeed,
      "std_speed": stdSpeed,
      "max_speed": maxSpeed,
      "min_speed": minSpeed,
      "session_id": sessionId,
    });

    if (success != 0) {
      for (var element in window) {
        db.delete(
          "rawSensorData",
          where: "timestamp = ?",
          whereArgs: [element["timestamp"]],
        );
      }
    }

    index += 5;
  }
  db?.update(
    "sessionInfo",
    {"is_extracted": 1},
    where: "session_id = ?",
    whereArgs: [sessionId],
  );
}

Future makePredictions(sessionId) async {
  var output = List.filled(1, 0.0).reshape([1, 1]);
  var interpreter = await tfl.Interpreter.fromAsset("v21.tflite");
  final db = await SensorDataDb.instance.database;
  final sessionExtractedDataPoints = await db!.query(
    "extractedFeatures",
    where: "session_id = ?",
    whereArgs: [sessionId],
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
    whereArgs: [sessionId],
  );
}

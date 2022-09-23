import 'dart:async';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../services/upload_potholes.dart';
import 'collect_data.dart';
import 'make_predictions.dart';
import 'monitor_speed.dart';

const speedMonitorKey = "kinsaga.g4.speedMonitoringTask";
const dataCollectionTaskKey = "kinsaga.g4.dataCollecionTask";
const predictionTaskKey = "kinsaga.g4.predictionTask";
const uploadingTaskKey = "kinsaga.g4.uploadingTask";

void callbackDispatcher() {
  print("========= stop 1");
  print("callback dispatcher");
  Workmanager().executeTask((taskName, inputDta) async {
    if (taskName != predictionTaskKey) {
      Location location = Location();

      PermissionStatus permissionGranted;

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return Future.error("location permission error");
        }
      }
    }
    var preferences = await SharedPreferences.getInstance();
    switch (taskName) {
      case speedMonitorKey:
        return monitorSpeed(preferences);
      case dataCollectionTaskKey:
        return collectData(preferences);
      case predictionTaskKey:
        return startPredicting();
      case uploadingTaskKey:
        return uploadRegisteredPotholes();
      default:
        return Future.error("taskName mismatch error");
    }
  });
}

import 'dart:async';
import 'package:geolocator/geolocator.dart';
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
  Workmanager().executeTask((taskName, inputDta) async {
    if ((taskName != predictionTaskKey) || (taskName != uploadingTaskKey)) {
      final permissionGranted = await Geolocator.checkPermission();
      final locationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled ||
          (permissionGranted != LocationPermission.whileInUse &&
              permissionGranted != LocationPermission.always)) {
        print('enabled: $locationServiceEnabled, $permissionGranted');
        return Future.error(
            'permission denied or location service not enabled');
      }
    }
    print('================ another stop');
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

import 'dart:async';

import 'package:g4app/pages/data_collection/bg_callback.dart';
import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';

FutureOr<bool> monitorSpeed(preferences) async {
  Location location = Location();
  double? speed;

  bool serviceEnabled;
  LocationData locationData;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return Future.error("location service not enabled");
    }
  }

  locationData = await location.getLocation();
  speed = locationData.speed;
  var index = await preferences.getInt("nextSpeedIndex");
  print("========== nextSpeedIndex: $index");
  await preferences.setDouble("$index", speed!);
  preferences.setInt("nextSpeedIndex", (index! + 1) % 3);

  print("======= stop 2");
  var prefKeys = await preferences.getKeys();
  if (prefKeys.containsAll(['1', '2', '0'])) {
    var zero = await preferences.getDouble('0');
    var one = await preferences.getDouble('1');
    var two = await preferences.getDouble('2');

    if ((zero! + one! + two!) / 3 > 5) {
      Workmanager().registerOneOffTask(
        dataCollectionTaskKey,
        dataCollectionTaskKey,
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: true,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 1),
      );
    }
  }
  Workmanager().cancelByUniqueName(speedMonitorKey);
  return Future.error("================================== true");
}

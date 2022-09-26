import 'dart:async';

import 'package:g4app/pages/data_collection/bg_callback.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';

FutureOr<bool> monitorSpeed(preferences) async {
  // print('============= entered monitor speed');
  // await Location.instance.enableBackgroundMode();

  // Location location = Location();
  double? speed;

  // bool serviceEnabled;
  // LocationData locationData;

  // var numb = 0;
  // serviceEnabled = false;
  // while (!serviceEnabled) {
  //   try {
  //     print('=================== while loop number $numb');
  //     print('=================== b4 service check');
  //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     print('============after service check');
  //     print('service enabled: $serviceEnabled');
  //   } catch (e) {
  //     print('=============== error');
  //     print('$e');
  //     Future.delayed(Duration(seconds: 3));
  //   }

  //   numb++;
  //   // if (!serviceEnabled) {
  //   //   return Future.error("location service not enabled");
  //   // }
  // }
  // print('================= after while loop');

  // await Geolocator.openAppSettings();
  // await Geolocator.openLocationSettings();
  // await location.getLocation().then<void>((value) {
  //   speed = value.speed;
  // });
  Timer? timer;
  bool started = false;
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    // distanceFilter: 2,
  );
  StreamSubscription<Position> positionStream =
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position? position) {
    print('position update');
    if ((position!.speed < 5 && !started) || (position.speed > 5 && started)) {
      return;
    }
    if (!started) {
      timer = Timer(const Duration(minutes: 2), () async {
        await Geolocator.getCurrentPosition().then((value) {
          value.speed > 5
              ? Workmanager().registerOneOffTask(
                  dataCollectionTaskKey,
                  dataCollectionTaskKey,
                  initialDelay: const Duration(seconds: 10),
                  constraints: Constraints(
                    networkType: NetworkType.not_required,
                    requiresBatteryNotLow: true,
                  ),
                  backoffPolicy: BackoffPolicy.linear,
                  backoffPolicyDelay: const Duration(minutes: 1),
                  existingWorkPolicy: ExistingWorkPolicy.keep,
                )
              : print('something');
        });
      });
      started = true;
      return;
    }
    if (position.speed < 5) {
      timer!.cancel();
      started = false;
    }
    // timer.cancel();
  });

  await Geolocator.getCurrentPosition().then((value) {
    speed = value.speed;
  });
  print('====================== after getting location data SPEED=$speed');
  // speed = locationData.speed;
  // var index = await preferences.getInt("nextSpeedIndex");
  // print("========== nextSpeedIndex: $index");
  // await preferences.setDouble("$index", speed!);
  // preferences.setInt("nextSpeedIndex", (index! + 1) % 3);

  // print("======= stop 2");
  // var prefKeys = await preferences.getKeys();
  // if (prefKeys.containsAll(['1', '2', '0'])) {
  //   var zero = await preferences.getDouble('0');
  //   var one = await preferences.getDouble('1');
  //   var two = await preferences.getDouble('2');

  //   if ((zero! + one! + two!) / 3 > 5) {
  //     Workmanager().registerOneOffTask(
  //       dataCollectionTaskKey,
  //       dataCollectionTaskKey,
  //       initialDelay: const Duration(seconds: 10),
  //       constraints: Constraints(
  //         networkType: NetworkType.not_required,
  //         requiresBatteryNotLow: true,
  //       ),
  //       backoffPolicy: BackoffPolicy.linear,
  //       backoffPolicyDelay: const Duration(minutes: 1),
  //     );
  //   }
  // }
  // Workmanager().cancelByUniqueName(speedMonitorKey);
  // return Future.error("================================== true");
// positionStream.
  return true;
}

// initLocation() async {
//   try {
//     _serviceEnabled = await location.serviceEnabled();
//   } on PlatformException catch (err) {
//     print("Platform exception calling serviceEnabled(): $err");
//     _serviceEnabled = false;

//     // location service is still not created

//     initLocation(); // re-invoke himself every time the error is catch, so until the location service setup is complete
//   }
// }

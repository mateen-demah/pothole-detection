// import 'dart:js';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:g4app/pages/login.dart';
import 'package:g4app/pages/main_map.dart';
import 'package:g4app/pages/notifications.dart';
import 'package:g4app/pages/onboarding.dart';
import 'package:g4app/pages/signup.dart';
import 'package:g4app/pages/splash.dart';
import 'package:g4app/services/auth.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'pages/data_collection/bg_callback.dart';

void main() async {
  //initializing firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialise background services worker
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  runApp(StreamProvider<User?>.value(
    value: Authservices().user,
    initialData: null,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      // home: Scaffold(
      //     body: Column(
      //   children: [
      //     ElevatedButton(
      //         onPressed: () {
      //         },
      //         child: Text("uploading")),
      //     ElevatedButton(
      //         onPressed: () {
      //         },
      //         child: Text("prediction")),
      //     ElevatedButton(
      //         onPressed: () {

      //         },
      //         child: Text("speed monitoring")),
      //     ElevatedButton(
      //         onPressed: () {
      //           Workmanager().registerOneOffTask(
      //               dataCollectionTaskKey, dataCollectionTaskKey,
      //               initialDelay: const Duration(seconds: 10),
      //               constraints: Constraints(
      //                 networkType: NetworkType.connected,
      //                 requiresBatteryNotLow: true,
      //               ),
      //               backoffPolicy: BackoffPolicy.linear,
      //               backoffPolicyDelay: const Duration(minutes: 1),
      //               existingWorkPolicy: ExistingWorkPolicy.keep);
      //         },
      //         child: Text("collect data")),
      //     ElevatedButton(
      //       onPressed: () async {
      //         await Workmanager().cancelAll();
      //         print('cancelled');
      //       },
      //       child: Text('cancel all'),
      //     ),
      //   ],
      // )),
      routes: {
        '/': (context) => splash(),
        '/login': (context) => login(),
        '/signup': (context) => signup(),
        '/notification': (context) => Notifications(),
        'onboard': (context) => OnBoarding(),
        'home': (context) => MainMapPage()
      },
    ),
  ));
}

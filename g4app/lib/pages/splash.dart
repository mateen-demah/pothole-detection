import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:g4app/onboardwrapper.dart';
import 'package:g4app/pages/login.dart';
import 'package:g4app/pages/onboarding.dart';
import 'package:g4app/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'data_collection/bg_callback.dart';
// import 'package:http/http.dart';

class splash extends StatefulWidget {
  const splash({Key? key}) : super(key: key);

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  bool? initScreen;
  @override
  void initState() {
    //after 3 seconds load login page
    super.initState();
    wrapperOnboardinit();
    // whereAreWeGoing = wapperfunction
    registerBackgroundWorkers();
    Future.delayed(
      const Duration(milliseconds: 3000),
      () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return initScreen == null || initScreen == false
              ? OnBoarding()
              : Wrapper();
        }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: Colors.green[400],
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 3.0, 12.0, 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Image.asset(
                        'assets/logo.png',
                        // width: 170,
                        // height: 170,
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.5,
                      ),
                    ),
                    // SizedBox(height: 20),
                    Text(
                      'G4 App',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Text(
                      "Welcome to Ghana's Premium Intelligence road classification App",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> wrapperOnboardinit() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    initScreen = preferences.getBool('initScreen');
    log(initScreen.toString());
    await preferences.setBool('initScreen', true);
    return initScreen;
  }

  void registerBackgroundWorkers() async {
    Workmanager().registerOneOffTask(uploadingTaskKey, uploadingTaskKey,
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 1),
        existingWorkPolicy: ExistingWorkPolicy.keep);

    Workmanager().registerOneOffTask(predictionTaskKey, predictionTaskKey,
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: true,
          requiresCharging: true,
          requiresDeviceIdle: true,
          requiresStorageNotLow: true,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 1),
        existingWorkPolicy: ExistingWorkPolicy.keep);
    Workmanager().registerPeriodicTask(speedMonitorKey, speedMonitorKey,
        frequency: const Duration(seconds: 40),
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: true,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 1),
        existingWorkPolicy: ExistingWorkPolicy.keep);
  }
}

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:g4_user/screens/main_map.dart';
import 'package:g4_user/screens/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

int? initScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  initScreen = await preferences.getInt('initScreen');
  await preferences.setInt('initScreen', 1);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "G4 App",
      debugShowCheckedModeBanner: false,

      initialRoute: initScreen == 0 || initScreen == null ? 'onboard' : 'home',
      routes: {
      'home': (context) => MainMapPage(),
      'onboard': (context) => OnBoarding()
      },
      // ignore: unnecessary_const
      // home: const OnBoarding(),
    );
  }
}




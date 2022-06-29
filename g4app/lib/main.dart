// import 'dart:js';

import 'package:flutter/material.dart';
// import 'package:g4app/pages/login.dart';
import 'package:g4app/pages/notifications.dart';
import 'package:g4app/pages/signup.dart';
import 'package:g4app/pages/splash.dart';

void main() {
  runApp(MaterialApp(  
    theme: ThemeData(
scaffoldBackgroundColor: Colors.white),
    // home: splash(),
    initialRoute: '/signup',
    routes: {
      '/' : (context) => splash(),
      // '/login' : (context) => login(),
      '/signup' : (context) => signup(),
      '/notification' : (context) => notifications(),
    },

  ));
}


// import 'dart:js';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:g4app/pages/login.dart';
import 'package:g4app/pages/notifications.dart';
import 'package:g4app/pages/signup.dart';
import 'package:g4app/pages/splash.dart';
import 'firebase_options.dart';

void main() async{
  //initializing firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(  
    theme: ThemeData(
scaffoldBackgroundColor: Colors.white),
    // home: splash(),
    // initialRoute: '/login',
    routes: {
      '/' : (context) => splash(),
      '/login' : (context) => login(),
      '/signup' : (context) => signup(),
      '/notification' : (context) => notifications(),
    },

  ));
}


// import 'dart:js';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:g4app/pages/login.dart';
import 'package:g4app/pages/notifications.dart';
import 'package:g4app/pages/signup.dart';
import 'package:g4app/pages/splash.dart';
import 'package:g4app/services/auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  //initializing firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(StreamProvider<User?>.value(
    value: Authservices().user,
    initialData: null,
    child: MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      // home: splash(),
      routes: {
        '/': (context) => splash(),
        '/login': (context) => login(),
        '/signup': (context) => signup(),
        '/notification': (context) => notifications(),
      },
    ),
  ));
}

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:g4app/pages/onboarding.dart';
import 'package:g4app/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class onboardWrapper extends StatefulWidget {
  const onboardWrapper({Key? key}) : super(key: key);

  @override
  State<onboardWrapper> createState() => _onboardWrapperState();
}

class _onboardWrapperState extends State<onboardWrapper> {
  int? initScreen = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // wrapperOnboardinit();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: wrapperOnboardinit(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return OnBoarding();
        } else {
          return Wrapper();
        }
      },
    );
    // if (initScreen == 0 || initScreen == null) {
    //   return OnBoarding();
    // } else {
    //   return Wrapper();
    // }
  }

  Future<int?> wrapperOnboardinit() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    initScreen = preferences.getInt('initScreen');
    log(initScreen.toString());
    await preferences.setInt('initScreen', 1);
    return initScreen;
  }
}

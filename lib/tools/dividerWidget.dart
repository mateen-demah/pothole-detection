import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Divider(
      height: 1.0,
      color: Colors.black,
      thickness: 1.0,
    );
  }
}

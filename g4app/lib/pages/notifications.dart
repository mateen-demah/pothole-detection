import 'package:flutter/material.dart';
import 'package:http/http.dart';

class notifications extends StatefulWidget {
  const notifications({ Key? key }) : super(key: key);

  @override
  State<notifications> createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title: Text('notification'),
      ),
      body: Text('Review your recent driving experience'),
      
    );
  }
}
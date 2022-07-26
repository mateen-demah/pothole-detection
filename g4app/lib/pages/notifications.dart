import 'package:flutter/material.dart';
// import 'package:http/http.dart';

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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 3.0, 1.0, 6.0),
        child: Column(
          children: [
            Text('Review your recent driving experience'),
            Container(child: Text('see')),
          ],
        ),
        
      ),
        
      
    );
  }
}
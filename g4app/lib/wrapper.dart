import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:g4app/pages/login.dart';
import 'package:g4app/pages/main_map.dart';
import 'package:g4app/pages/notifications.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    print(user);
    if(user == null){
      return login();
    }else{
      return MainMapPage();

    }
    
  }
}
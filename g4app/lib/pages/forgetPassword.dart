// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:g4app/services/auth.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final Authservices _auth = Authservices();
  late String email;
  String error='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Forget password',
      style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold) ,), 
      backgroundColor: Color.fromARGB(255, 36, 179, 41),
      elevation: 0,
      centerTitle: true,
      
      ),
      body:Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 0.0),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('E-mail',)),
            ),
            SizedBox(
              height:10,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none,borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.green)),
                hintText: 'enter your email',
                filled: true,
                fillColor: Colors.grey[100], 
              ),
              onChanged: (value) {setState(() {
                email=value;
                });} ,
            ),
            //warning for empty textfield
            Text(error,
            style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              height:20,
            ),
            Container(
                    width: 250,
                    height: 40,
                    
                    child: Material(
                      elevation: 2,
                      child: TextButton(
                        
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          primary: Colors.white,
                          backgroundColor: Color.fromARGB(255, 36, 179, 41),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Reset password'),
                        onPressed:()async{
                          // Todo: work on email not being recieved for forget [assword]
                          
                          try{var result =await _auth.resetPassword(email);
                          if (result !=null){
                            Navigator.pop(context);
                          }
                          }catch(e){
                            print(e.toString());
                            setState(() {
                              error='please enter a valid email';
                            });
                          }

                          // await _auth.resetPassword(email).then((value) => Navigator.pop(context)).catchError((enError){print(enError.toString());
                          // setState(() {
                          //     error='please enter a valid email';
                          //   });
                          // });
                          
                            
                          
                        },
                        
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
    
  }
}
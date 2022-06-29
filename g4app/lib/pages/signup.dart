import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';


class signup extends StatefulWidget {
  const signup({ Key? key }) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 3.0, 6.0, 0.0 ),
        child: SafeArea(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Container(
              child:Text('Create account'),
            ),
            Container(
              child:Text('Enter your details to get started',
                      style: TextStyle(color: Colors.grey)
              ),

            ),
            Container(child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "email",
                     border:InputBorder.none
                  ),
      
                ),
            ),
            Container(child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "email",
                     border:InputBorder.none
                  ),
      
                ),
              ),
               Container(child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "email",
                     border:InputBorder.none
                  ),
      
                ),
              ),
               Container(child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "email",
                     border:InputBorder.none
                  ),
      
                ),
              ),
              Container(child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "email",
                    //  border:InputBorder.none
                  ),
      
                ),
              ),
           
            
            Container(
              child: TextButton(onPressed: () {
                 
              }, 
                      child:Text('Sign Up'),
            ),
            

            ),
            TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Colors.white,
                    backgroundColor: Color(0xFF76FF03),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                child:const Text('Sign Up'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/notifications');
                  
                  },
                ),      
            Container(
               child: SignInButtonBuilder(
                icon: Icons.facebook,
                backgroundColor: Colors.green,
                onPressed: () {},
                text: "continue with facebook"
               
              ),
            ),
            SignInButton(
              Buttons.Google,
              text: 'continue with google',
             onPressed: () {}
             ),      
            
            Container(
               child: SignInButtonBuilder(
                icon: Icons.facebook,
                backgroundColor: Colors.green,
                onPressed: () {},
                text: "continue with facebook"
              ),
            ),
            SizedBox(height: 10,),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account ? "
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Sign in',
                          style: TextStyle(color: Colors.green,
                          fontWeight: FontWeight.bold)
                    ),
                  ),
                
                ],
                
              ),

          ],
        )
        ),
      ),
      
    );
  }
}
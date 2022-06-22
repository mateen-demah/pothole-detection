import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';


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
              child: Image.asset('assets/logo.png',
                      height: 100,
                      width: 100,
              ),

            ),
            Container(
              child:Text('Create account'),
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
           
            
            Container(
              child: TextButton(onPressed: () {
                Navigator.pushReplacementNamed(context, '/notifications'); 
              }, 
                      child:Text('Sign Up'),
            ),

            ),
            Container(
               child: SignInButtonBuilder(
                icon: Icons.facebook,
                backgroundColor: Colors.green,
                onPressed: () {},
                text: "continue with facebook"
               
              ),
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
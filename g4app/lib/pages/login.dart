import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:http/http.dart';

class login extends StatefulWidget {
  const login({ Key? key }) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 3.0, 6.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image.asset('assets/logo.png',
                height: 100,
                width: 100,),
              ),
              SizedBox(height:16),
              Container(child:Text('Login',
                style: TextStyle(fontWeight:FontWeight.bold),
                )
              ),
              Container(child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "email",
                    //  border:InputBorder.none
                  ),
      
                ),
              ),
              Container(child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility,
                                // color: Colors.green,
                    ),
                    hintText: "password",
                    // border:InputBorder.none
                  ),
      
                ),
              ),
              SizedBox(height: 10,),
              Container(
                child: TextButton(
                  child: Text('Login'),
                  onPressed: () {
                    
                  },
                  ),
              ),             
              Container(
                child:SignInButtonBuilder(
                    icon: Icons.facebook,
                    text: "Continue with google",
                    onPressed: () {},
                    backgroundColor: Colors.green,
                  ) ,
              ),
              Container(
                child:SignInButtonBuilder(
                    text: "Continue with facebook",
                    icon: Icons.facebook,

                    onPressed: () {},
                    backgroundColor: Colors.green,
                  ) ,
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account ? "
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Sign Up',
                          style: TextStyle(color: Colors.green,
                          fontWeight: FontWeight.bold)
                    ),
                  ),
                
                ],
                
              ),
      
            ],
          ),
        ),
      ),
      
    );
  }
}
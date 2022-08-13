import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:g4app/services/auth.dart';
// import 'package:http/http.dart';
class login extends StatefulWidget {
  const login({ Key? key }) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  final Authservices _auth = Authservices();

  // Textfield state
  String email = "";
  var password = "";



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 3.0, 6.0, 0.0),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child:Align(
                alignment: Alignment.centerLeft,
                child: Text('Sign in',
                  style: TextStyle(fontWeight:FontWeight.bold,fontSize:28,)
                  ),
              )
              ),
              SizedBox(height: 5,),
              Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Enter your details to continue',
                  ),
                )
              ),
              SizedBox(height: 20,),
              Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email:',
                  ),
                )
              ),
              SizedBox(height: 5,),
              Container(  
                child: TextField(
                  decoration: InputDecoration(
                    border:OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),),
                    filled: true,
                    // icon: Icon(Icons.person),
                    hintText: "Please enter your email", 
                    fillColor: Colors.grey[200], 
                                   
                  ),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                    
                  },
      
                ),
              ),
              SizedBox(height: 5,),
              Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password:',
                  ),
                )
              ),
               SizedBox(height: 10,),
              Container(child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),),
                    filled: true,
                    suffixIcon: Icon(Icons.visibility,
                    ),
                    hintText: "Please enter your password",
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                    
                  },
      
                ),
              ),
              SizedBox(height: 10,),
              Container(
                child: GestureDetector(
                    onTap: () {},
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forget password?',
                            style: TextStyle(color: Colors.green,
                            fontWeight: FontWeight.bold,decoration:TextDecoration.underline,
                            
                            )
                      ),
                    ),
                  ),
              ),
              SizedBox(height: 10,),
              TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Colors.white,
                    backgroundColor: Color(0xFF4CAF50),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                child:const Text('Login'),
                onPressed: () async{
                  dynamic result = await _auth.signInAnon();
                  if (result == null){
                    print("error signing in ");
                  } else {
                    Navigator.pushReplacementNamed(context, 'home');
                    print("signed in");
                    print(result.uid);
                  }
                  //signin with email and password
                  // dynamic result =await _auth.signinWithEmailAndPassword(email, password);
                  // if (result == null){
                  //   print("error signing in ");
                  // } else {
                  //   print("signed in");
                  // }
                  
                  },
                ), 
                SizedBox(height: 10,), 
                SignInButton(
                        Buttons.Google,
                        text: 'continue with google',
                      onPressed: () {}
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
                    onTap: ()=>handleSignUp(context),
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
  void handleSignUp(BuildContext context){
    Navigator.pushNamed(context, '/signup');
  }
}
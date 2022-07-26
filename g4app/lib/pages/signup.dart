import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:g4app/services/auth.dart';


class signup extends StatefulWidget {
  const signup({ Key? key }) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  String Firstname = "";
  String lastname = "";
  String email="";
  var password="";
  String error ="";
  final Authservices _auth = Authservices();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 3.0, 6.0, 0.0 ),
        child: SafeArea(child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Create account',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize:28),)),
              ),
              Container(
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Enter your details to get started',
                  ),
                ),
        
              ),
              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.all(4),
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text('First Name',
                           style: TextStyle()
                  ),
                ),
        
              ),
              Container(child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      border:OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                       hintText: "Please enter your first name",
                       fillColor: Colors.grey[200],
                       
                    ),
                    
                    onChanged: (value) {
                      setState(() {
                         Firstname = value;
                      });
                     
                    },
              
                  ),
              ),
              Container(
                margin: EdgeInsets.all(4),
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Last Name',
                  ),
                ),
        
              ),
               Container(child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      border:OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                       hintText: "Please enter your Last name",
                       fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) {
                      setState(() {
                        lastname = value;
                      });
                    },
              
                  ),
              ),
              Container(
                margin: EdgeInsets.all(4),
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email',
                  ),
                ),
        
              ),
               Container(child: TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      border:OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                       hintText: "Please enter your email",
                       fillColor: Colors.grey[200],
                    ),
                    validator: (value) => value!.isEmpty? "please enter an email":null,
                    onChanged: (value) {
                      setState(() {
                        email=value;
                      });
                    },
              
                  ),
              ),
              Container(
                margin: EdgeInsets.all(4),
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password',
                  ),
                ),
        
              ),
              Container(child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),),
                      filled: true,
                      // icon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.visibility,
                      ),
                      hintText: "Please enter your password",
                      fillColor: Colors.grey[200],
                    ),
                    validator: (value) => value!.length <6 ? "please enter a password more than 6 characters":null,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
              
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
                  child:const Text('Sign Up'),
                  onPressed: () async{
                    if (_formKey.currentState!.validate()){
                        dynamic result =await _auth.signupWithEmailAndPassword(email, password);
                      if (result == null) {
                        setState(() {
                          error = "please enter a valid email or password";
                        });
                      }
                      // Navigator.pushReplacementNamed(context, '/notifications');
                    }                   
                    },
                  ),
                SizedBox(height: 5),
                Text(error,
                  style: TextStyle(color: Colors.red,fontSize: 14.0), 
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
                      onTap: ()=>Navigator.pushNamed(context, '/login'),
                      child: Text('Sign in',
                            style: TextStyle(color: Colors.green,
                            fontWeight: FontWeight.bold)
                      ),
                    ),
                  
                  ],
                  
                ),
        
            ],
          ),
        )
        ),
      ),
      
    );
  }
}
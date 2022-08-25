import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:g4app/services/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';


class signup extends StatefulWidget {
  const signup({ Key? key }) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  // String Firstname = "";
  String username = "";
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
        padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 0.0 ),
        child: SafeArea(child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child:Align(
                    alignment: Alignment.center,
                    child: Text('Create account',
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize:28),)),
                ),
                // Container(
                //   child:Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text('Enter your details to get started',
                //     ),
                //   ),
                  
                // ),
                // SizedBox(height: 10,),
                // Container(
                //   margin: EdgeInsets.all(4),
                //   child:Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text('First Name:',
                //              style: TextStyle()
                //     ),
                //   ),    
                // ),
                // SizedBox(
                //   height: 5,
                // ),
                // Container(child: TextField(
                //       decoration: InputDecoration(
                //         filled: true,
                //         border:OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                //                 borderSide: BorderSide.none),
                //         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green),borderRadius: BorderRadius.circular(15.0)),
                //         // disabledBorder:OutlineInputBorder(borderSide: inpi),
                      
                //          hintText: "Please enter your first name",
                //          fillColor: Colors.grey[100],
                         
                //       ),
                      
                //       onChanged: (value) {
                //         setState(() {
                //            Firstname = value;
                //         });
                       
                //       },
                
                //     ),
                // ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  child:Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Username:',
                    ),
                  ),
                  
                ),
                SizedBox(
                  height: 5,
                ),
                 Container(child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none),
                        focusedBorder:OutlineInputBorder(borderSide: BorderSide(color: Colors.green),borderRadius: BorderRadius.circular(15.0)),
                         hintText: "Please enter your username",
                         fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        setState(() {
                          username = value;
                        });
                      },
                
                    ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  child:Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email:',
                    ),
                  ),
                  
                ),
                SizedBox(
                  height: 5,
                ),
                 Container(child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green),borderRadius: BorderRadius.circular(15.0)),
                         hintText: "Please enter your email",
                         fillColor: Colors.grey[100],
                      ),
                      validator: (value) => value!.isEmpty? "please enter an email":null,
                      onChanged: (value) {
                        setState(() {
                          email=value;
                        });
                      },
                
                    ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  child:Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password:',
                    ),
                  ),                
                ),
                SizedBox(
                  height: 5,
                ),
                Container(child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green),borderRadius: BorderRadius.circular(15.0)),
                        filled: true,
                        hintText: "Please enter your password",
                        fillColor: Colors.grey[100],
                      ),
                      obscureText: true,
                      validator: (value) => value!.length <6 ? "please enter a password more than 6 characters":null,
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                
                    ),
                  ),
                  SizedBox(height: 10,),                    
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
                            else{
                              Navigator.pushReplacementNamed(context, 'home');
                            }
                            // Navigator.pushReplacementNamed(context, '/notifications');
                          }                   
                          },
                        ),
                  ),
                ),
                   Divider(
                  color: Colors.grey,
                  height: 25,
                ),
                  Text(error,
                    style: TextStyle(color: Colors.red,fontSize: 14.0), 
                    ),  

                    Container(
                  width: 250,
                  height: 40,
                  
                  child: Material(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      label: Text("continue with google",),
                  
                      // TODO:add google icon
                      icon:SvgPicture.asset('assets/Vector.svg',width: 23,),
                      // icon: Icons.facebook,
                      onPressed: () {},
                      // backgroundColor: Color.fromARGB(255, 98, 177, 101),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Container(
                  width: 250,
                  height: 40,
                  
                  child: Material(
                    elevation: 2,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        primary: Colors.white,
                        backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      icon: Icon(Icons.facebook),
                      label: Text("Continue with facebook",),
                      // icon: Icons.facebook,
                      onPressed: () {},
                      // backgroundColor: Color.fromARGB(255, 98, 177, 101),
                    ),
                  ),
                ),   
                // SignInButton(
                //   Buttons.Google,
                //   text: 'continue with google',
                //  onPressed: () {}
                //  ),      
                
                // Container(
                //    child: SignInButtonBuilder(
                //     icon: Icons.facebook,
                //     backgroundColor: Colors.green,
                //     onPressed: () {},
                //     text: "continue with facebook"
                //   ),
                // ),
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
          ),
        )
        ),
      ),
      
    );
  }
}
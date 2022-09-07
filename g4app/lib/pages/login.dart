import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:g4app/pages/forgetPassword.dart';
import 'package:g4app/services/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

// import 'package:http/http.dart';
class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final Authservices _auth = Authservices();

  // Textfield state
  String email = "";
  var password = "";
  String googleerrorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 0.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                    child: Align(
                  alignment: Alignment.center,
                  child: Text('Sign in',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      )),
                )),
                // SizedBox(
                //   height: 5,
                // ),
                // Container(
                //     child: Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     'Enter your details to continue',
                //   ),
                // )),
                SizedBox(
                  height: 20,
                ),
                Container(
                    child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email:',
                  ),
                )),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(15.0)),
                      filled: true,
                      // icon: Icon(Icons.person),
                      hintText: "Please enter your email",
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password:',
                  ),
                )),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(15.0)),
                      filled: true,
                      // suffixIcon: Icon(
                      //   Icons.visibility,
                      // ),
                      hintText: "Please enter your password",
                      fillColor: Colors.grey[100],
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgetPassword(),
                          ));
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forget password?',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          )),
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
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        primary: Colors.white,
                        backgroundColor: Color.fromARGB(255, 36, 179, 41),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Login'),
                      onPressed: () async {
                        // dynamic result = await _auth.signInAnon();
                        // if (result == null) {
                        //   print("error signing in ");
                        // } else {
                        //   Navigator.pushReplacementNamed(context, 'home');
                        //   print("signed in");
                        //   print(result.uid);
                        // }
                        //signin with email and password
                        dynamic result = await _auth.signinWithEmailAndPassword(
                            email, password);
                        if (result == null) {
                          print("error signing in ");
                        } else {
                          Navigator.pushReplacementNamed(context, 'home');
                          print("signed in");
                        }
                      },
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                Divider(
                  color: Colors.grey,
                  height: 25,
                ),
                Text('Continue With'),
                // SignInButton(Buttons.Google,
                //     text: 'continue with google',
                //     onPressed: () {}),

                Text(
                  googleerrorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
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
                        backgroundColor: Colors.red,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      label: Text(
                        "google",
                      ),
                      // todo:add google icon
                      icon: SvgPicture.asset(
                        'assets/Vector.svg',
                        width: 23,
                      ),
                      // icon: Icons.facebook,
                      onPressed: () {
                        _auth
                            .signInWithGoogle()
                            .then((value) =>
                                Navigator.pushReplacementNamed(context, 'home'))
                            .catchError((enError) {
                          print(enError.toString());
                          setState(() {
                            googleerrorMessage =
                                'Could not sign in with google...Retry';
                          });
                        });
                      },
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
                  // decoration: OutlinedBorder(),

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
                      label: Text(
                        "facebook",
                      ),
                      // icon: Icons.facebook,
                      onPressed: () {},
                      // backgroundColor: Color.fromARGB(255, 98, 177, 101),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account ? "),
                    GestureDetector(
                      onTap: () => handleSignUp(context),
                      child: Text('Sign Up',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleSignUp(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }
  // void googlepush(BuildContext context){

  // }
}

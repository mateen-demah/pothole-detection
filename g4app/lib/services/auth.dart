import 'package:firebase_auth/firebase_auth.dart';
class Authservices{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }




// anonymous signin
Future signInAnon() async{
  try{
    UserCredential authResult = await _auth.signInAnonymously();
    User user = authResult.user!;
    return user;
  } catch(e){
    print(e.toString());
    return null;

  }
  

} 







//signin with email and password
Future signinWithEmailAndPassword(String email, String password) async{
  try{
    UserCredential result =await _auth.signInWithEmailAndPassword(email: email, password: password);
    User user = result.user!;
    return user;
  }catch(e){
    print(e.toString());
    return null;
  }

}
 


//register with email and password
Future signupWithEmailAndPassword(String email,String password) async{
  try{
    UserCredential result =await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User user = result.user!;
    return user;
  }catch(e){
    print(e.toString());
    return null;
  }
}



//signout
Future signout() async {
  try{
    return await _auth.signOut();

  }catch(e){
    print(e.toString());
    return null;

  }
}

}
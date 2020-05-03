import 'package:firebase_auth/firebase_auth.dart';
import 'package:temp_project/database/user.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user){
    return user!=null?User(id:user.uid):null;
  }

  Stream<User> get user{
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }


  //sign in with email & password
  Future signInwithEmailAndPassword(String email, String password)async{
    try{
      FirebaseUser result=(await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
      return _userFromFirebaseUser(result);
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  //sign up with email & password
  Future signUpwithEmailAndPassword(String email, String password)async{
    try{
      FirebaseUser result=(await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
      return _userFromFirebaseUser(result);
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  //sign out
  Future signOut()async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future sendPasswordResetEmail(String email)async{
    print(email);
    try{
    return await _auth.sendPasswordResetEmail(email: email);
      }catch(e){
      print(e.toString());
      return null;
    }
  }
}
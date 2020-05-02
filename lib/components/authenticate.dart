

import 'package:flutter/cupertino.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'package:temp_project/screens/UserChooseLesson.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authenticate extends StatefulWidget{
  @override
  _AuthenticateState createState()=>_AuthenticateState();
}
class _AuthenticateState extends State<Authenticate>{

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
          if (snapshot.hasData){
            FirebaseUser user = snapshot.data; // this is your user instance
            /// is because there is user already logged
            return UserChooseLesson();
          }
          /// other way there is no user logged.
          return LoginScreen(emailReset: "",);
        }
    );
  }
}
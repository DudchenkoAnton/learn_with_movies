import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'dart:async';

class OpenScreenLogo extends StatefulWidget {
  @override
  static const String id = 'OpenScreenLogo';
  _OpenScreenLogoState createState() => _OpenScreenLogoState();
}

class _OpenScreenLogoState extends State<OpenScreenLogo> {
  void route() async{
   await Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => LoginScreen()
    )
    );
  }
  startTime() async {
    var duration = new Duration(seconds: 6);
    return new Timer(duration, route);
  }

  void initState() {
    super.initState();
    startTime();
  }

  Widget _buildLogo() {
    return Image(image: AssetImage('images/logo.jpg'));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        color: Colors.white,
        height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 60.0),
              _buildLogo(),
              SizedBox(
                height: 70.0,
              ),
              Text(
                'Learn With Movies',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontFamily: 'OpenSans',
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
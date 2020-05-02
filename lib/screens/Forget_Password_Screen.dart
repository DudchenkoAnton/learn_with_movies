import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:temp_project/database/auth.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'package:temp_project/screens/UserChooseLesson.dart';
import 'package:temp_project/utilites/constants.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  static const String id = 'ForgetPasswordScreen';
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey=GlobalKey<FormState>();
  final AuthService _auth=AuthService();
  String _email='';


  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            onChanged: (input){
              setState(() =>_email=input);
            },
            onSaved: (input){
              setState(() =>_email=input);
            },
            validator: (input)=>input.isEmpty?'Enter an email':null,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildHaveAccountBtn() {
    return Container(
      alignment: Alignment.center,
      child: FlatButton(
        onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(emailReset: "",)));},
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Remember the passport?',
          style: kLabelStyle,
        ),
      ),
    );
  }


  Widget _buildSendCodeBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: ()async {
          if (_formKey.currentState.validate()) {
            await _auth.sendPasswordResetEmail(_email);
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  LoginScreen(emailReset: _email,)));
            }
          },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Send Code',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child:Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Forget Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildEmailTF(),
                      SizedBox(
                        height: 40.0,
                      ),
                      _buildSendCodeBtn(),
                      _buildHaveAccountBtn(),

                    ],
                  ),
                ),
              )
            ],
          ),
          ),
        ),
      ),
    );
  }
}
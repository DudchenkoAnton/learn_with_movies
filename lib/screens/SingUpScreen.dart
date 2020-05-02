import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:temp_project/database/auth.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'package:temp_project/screens/UserChooseLesson.dart';
import 'package:temp_project/utilites/constants.dart';

class CreateUserScreen extends StatefulWidget {
  @override
  static const String id = 'CreateUserScreen';
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final AuthService _auth=AuthService();
  final _formKey=GlobalKey<FormState>();
  String _email='';
  String _password='';
  String error='';

  bool notSamePassword=false;

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

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            onChanged: (input){
              setState(() =>_password=input);
            },
            validator: (input)=>input.length<6?'Enter a password with 6 chars long':null,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
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
          'Do you have alraedy account?',
          style: kLabelStyle,
        ),
      ),
    );
  }


  Widget _buildCreateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async{
            if (_formKey.currentState.validate()) {
                dynamic result = await _auth.signUpwithEmailAndPassword(
                _email, _password);
                print(_email);
                print(result.toString());
                 if (result == null) {
                    setState(() {
                    error = 'please supply a valid email';
                    });
                } else {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => UserChooseLesson()));
                }
            }
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Create User',
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
                        'Sign Up',
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
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildCreateBtn(),
                      _buildHaveAccountBtn(),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(error,style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'OpenSans',
                        fontSize: 15.0,
                        ),
                      ),
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
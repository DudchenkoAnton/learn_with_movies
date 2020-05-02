import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:temp_project/database/auth.dart';
import 'package:temp_project/screens/Forget_Password_Screen.dart';
import 'package:temp_project/screens/SingUpScreen.dart';
import 'package:temp_project/screens/UserChooseLesson.dart';
import 'package:temp_project/utilites/constants.dart';

class LoginScreen extends StatefulWidget {
  String emailReset;
  LoginScreen({this.emailReset});

@override
  static const String id = 'login_screen';
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth=AuthService();
  final _formKey=GlobalKey<FormState>();
  bool _rememberMe = false;
  String _email='';
  String _password='';
  String _error='';

  @override
  void initState() {
    if(widget.emailReset!=''){
      setState(() {
        _email=widget.emailReset;
      });
    }
    super.initState();
  }


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

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPasswordScreen()));},
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }


  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          if (_formKey.currentState.validate()){
            dynamic result= await _auth.signInwithEmailAndPassword(_email, _password);
            print(result);
            if(result==null){
              setState(()=>_error='Could not sign in eith those credentials');
              }else{
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
          'LOGIN',
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

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () {move_screen(context);},
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageReset(){
    return Container(
      width: 350.0,
      height: 45.0,
      color: Colors.yellow[700],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text("A password reset link has been sent to",
                style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,),
              ),
              Text("$_email",
                style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,),
                ),
            ],
          ),
          IconButton(icon: Icon(Icons.close),
            onPressed: (){
            setState(() {
              widget.emailReset="";
            });
          },)
        ],
      ),
    );
  }

  void move_screen(BuildContext context) async {
    ///change the name of the screen and send the lesson!
    await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateUserScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child:
          Form(
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
                    vertical: 90.0,
                  ),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                        child: messageReset(),
                        visible:widget.emailReset==""?false:true ,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Sign In',
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
                      _buildForgotPasswordBtn(),
                      _buildLoginBtn(),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text(_error,style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'OpenSans',
                    fontSize: 15.0,
                    ),
                  ),
                      SizedBox(
                        height: 6.0,
                      ),
                      _buildSignupBtn(),
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
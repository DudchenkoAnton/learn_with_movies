import 'package:flutter/material.dart';
import '../utilites/constants.dart';

class BottomButton extends StatelessWidget {
  BottomButton({@required this.buttonText, @required this.onPressed});

  final String buttonText;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        child: Center(
          child: Text(
            buttonText,
            style: kLabelBigButtonStyle,
          ),
        ),
        color: Colors.lightBlue,
        margin: EdgeInsets.only(top: 10.0),
        padding: EdgeInsets.only(bottom: 20.0),
        width: double.infinity,
        height: 80.0,
      ),
    );
  }
}

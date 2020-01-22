import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  IconData icon;
  double elevation;
  Color color;
  Function onPressed;

  RoundedIconButton(
      {@required this.icon,
      this.elevation = 0.0,
      this.color = Colors.lightBlueAccent,
      @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      child: Icon(icon),
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      fillColor: color,
      constraints: BoxConstraints.tightFor(
        width: 50.0,
        height: 50.0,
      ),
    );
  }
}

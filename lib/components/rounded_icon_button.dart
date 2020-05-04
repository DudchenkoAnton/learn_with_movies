import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  IconData icon;
  double elevation;
  Color color;
  Function onPressed;
  double width;
  double height;
  double iconSize;

  RoundedIconButton(
      {@required this.icon,
      this.elevation = 0.0,
      this.height = 50.0,
      this.width = 50.0,
      this.iconSize,
      this.color = Colors.lightBlueAccent,
      @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        size: iconSize,
      ),
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      fillColor: color,
      constraints: BoxConstraints.tightFor(
        width: width,
        height: height,
      ),
    );
  }
}

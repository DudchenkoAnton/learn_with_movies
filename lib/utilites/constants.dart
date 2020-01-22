import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);

const TextStyle kLabelBigButtonStyle = TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
);

const Constraints kRoundedIconButtonConstraints = BoxConstraints.tightFor(
  width: 50.0,
  height: 50.0,
);

const kContainerDecorationDefaultLessonEditor = BoxDecoration(
  color: Color(0xFFE3F2FD),
  borderRadius: BorderRadius.all(Radius.circular(10.0)),
);

const kContainerDecorationWrongLessonEditor = BoxDecoration(
  color: Color(0xFFFFEBEE),
  borderRadius: BorderRadius.all(Radius.circular(10.0)),
);

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

double rating_print(double rating_num) {
  if (rating_num % 1 != 0) {
    return num.parse(rating_num.toStringAsFixed(2));
  }
  return rating_num;
}

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

const kTimePickerDecoration = InputDecoration(
  hintText: '00',
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

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

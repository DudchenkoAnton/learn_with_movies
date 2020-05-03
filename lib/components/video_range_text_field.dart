import 'package:flutter/material.dart';
import 'package:temp_project/utilites/constants.dart';

class VideoRangeText extends StatefulWidget {
  List<Duration> startAt;
  List<Duration> endAt;
  Duration length;
  bool enabled = true;
  Function callback;

  VideoRangeText(
      {this.enabled = true,
      @required this.startAt,
      @required this.endAt,
      @required this.length,
      this.callback});

  @override
  _VideoRangeTextState createState() => _VideoRangeTextState();
}

class _VideoRangeTextState extends State<VideoRangeText> {
  TextEditingController _startMinutesController = TextEditingController();
  TextEditingController _startSecondsController = TextEditingController();
  TextEditingController _endMinutesController = TextEditingController();
  TextEditingController _endSecondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startMinutesController.text = widget.startAt[0].inMinutes.toString();
    _endMinutesController.text = widget.endAt[0].inMinutes.toString();
    _startSecondsController.text =
        (widget.startAt[0].inSeconds % 60).toString();
    _endSecondsController.text = (widget.endAt[0].inSeconds % 60).toString();
  }

  @override
  Widget build(BuildContext context) {
    _startMinutesController.text = widget.startAt[0].inMinutes.toString();
    _endMinutesController.text = widget.endAt[0].inMinutes.toString();
    _startSecondsController.text =
        (widget.startAt[0].inSeconds % 60).toString();
    _endSecondsController.text = (widget.endAt[0].inSeconds % 60).toString();

    return Row(
      children: <Widget>[
        SizedBox(width: 25),
        Flexible(
          child: Container(
            height: 35,
            decoration: kContainerDecorationDefaultLessonEditor.copyWith(
                color: Colors.white),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  int mins = int.parse(text);
                  widget.startAt[0] = Duration(seconds: 75);
                });
                widget.callback();
              },
              controller: _startMinutesController,
              decoration: kTimePickerDecoration,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(),
            ),
          ),
        ),
        SizedBox(width: 5),
        Text(':'),
        SizedBox(width: 5),
        Flexible(
          child: Container(
            height: 35,
            decoration: kContainerDecorationDefaultLessonEditor.copyWith(
                color: Colors.white),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  int mins = int.parse(text);
                  widget.startAt[0] = Duration(seconds: 85);
                });
                widget.callback();
              },
              controller: _startSecondsController,
              decoration: kTimePickerDecoration,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(),
            ),
          ),
        ),
        SizedBox(width: 35),
        SizedBox(width: 35),
        Flexible(
          child: Container(
            height: 35,
            decoration: kContainerDecorationDefaultLessonEditor.copyWith(
                color: Colors.white),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  int mins = int.parse(text);
                  widget.endAt[0] = Duration(seconds: 105);
                });
                widget.callback();
              },
              controller: _endMinutesController,
              decoration: kTimePickerDecoration,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(),
            ),
          ),
        ),
        SizedBox(width: 5),
        Text(':'),
        SizedBox(width: 5),
        Flexible(
          child: Container(
            height: 35,
            decoration: kContainerDecorationDefaultLessonEditor.copyWith(
                color: Colors.white),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  int mins = int.parse(text);
                  widget.endAt[0] = Duration(seconds: 115);
                  widget.callback();
                });
              },
              controller: _endSecondsController,
              decoration: kTimePickerDecoration,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(),
            ),
          ),
        ),
        SizedBox(width: 25),
      ],
    );
  }
}

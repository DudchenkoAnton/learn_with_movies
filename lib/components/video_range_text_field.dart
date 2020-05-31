import 'package:flutter/material.dart';
import 'package:temp_project/utilites/constants.dart';
import 'package:quiver/strings.dart';

class VideoRangeText extends StatefulWidget {
  int secondsStartPoint;
  int secondsEndPoint;
  final int secondsLength;
  final GlobalKey<FormState> formKey;
  Function(int start, int end) onChanged;

//  TextEditingController startMinutesController = TextEditingController();
//  TextEditingController startSecondsController = TextEditingController();
//  TextEditingController endMinutesController = TextEditingController();
//  TextEditingController endSecondsController = TextEditingController();

  VideoRangeText(
      {@required this.formKey,
      @required this.onChanged,
      @required this.secondsStartPoint,
      @required this.secondsEndPoint,
      @required this.secondsLength}) {
//    startMinutesController.text = (secondsStartPoint ~/ 60).toString();
//    startSecondsController.text = (secondsStartPoint % 60).toString();
//    endMinutesController.text = (secondsEndPoint ~/ 60).toString();
//    endSecondsController.text = (secondsEndPoint % 60).toString();
  }

  @override
  _VideoRangeTextState createState() => _VideoRangeTextState();
}

class _VideoRangeTextState extends State<VideoRangeText> {
  TextEditingController startMinutesController = TextEditingController();
  TextEditingController startSecondsController = TextEditingController();
  TextEditingController endMinutesController = TextEditingController();
  TextEditingController endSecondsController = TextEditingController();

  int secondsStartPoint;
  int secondsEndPoint;

  @override
  void initState() {
    super.initState();
    startMinutesController.text = (widget.secondsStartPoint ~/ 60).toString();
    endMinutesController.text = (widget.secondsEndPoint ~/ 60).toString();
    startSecondsController.text = (widget.secondsStartPoint % 60).toString();
    endSecondsController.text = (widget.secondsEndPoint % 60).toString();
  }

  int isNumeric(String s) {
    if (s == null) {
      return -1;
    }
    if (s == '') {
      return -1;
    }
    if (double.tryParse(s) == null) {
      return -1;
    }
    return double.parse(s).toInt();
  }

  bool checkProvidedValues() {
    int startSec = isNumeric(startSecondsController.text);
    int endSec = isNumeric(endSecondsController.text);
    int startMin = isNumeric(startMinutesController.text);
    int endMin = isNumeric(endMinutesController.text);
//    int startSec = isNumeric(widget.startSecondsController.text);
//    int endSec = isNumeric(widget.endSecondsController.text);
//    int startMin = isNumeric(widget.startMinutesController.text);
//    int endMin = isNumeric(widget.endMinutesController.text);

    if (startSec < 0 || startSec > 59) return false;
    if (endSec < 0 || endSec > 59) return false;
    if (startMin < 0 || startMin > 179) return false;
    if (endMin < 0 || endMin > 179) return false;

    secondsStartPoint = startSec + 60 * startMin;
    secondsEndPoint = endSec + 60 * endMin;

    if (secondsStartPoint > secondsEndPoint) return false;
    if (secondsStartPoint >= widget.secondsLength) return false;
    if (secondsEndPoint > widget.secondsLength) return false;

    return true;
  }

  void onChangedCallback(String text) {
    if (widget.formKey.currentState.validate()) {
      widget.onChanged(secondsStartPoint, secondsEndPoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    startMinutesController.text = (widget.secondsStartPoint ~/ 60).toString();
    endMinutesController.text = (widget.secondsEndPoint ~/ 60).toString();
    startSecondsController.text = (widget.secondsStartPoint % 60).toString();
    endSecondsController.text = (widget.secondsEndPoint % 60).toString();

    return Form(
      key: widget.formKey,
      child: FormField<int>(
        builder: (state) => Column(children: [
          Row(
            children: <Widget>[
              SizedBox(width: 25),
              Flexible(
                child: Container(
                  height: 35,
                  decoration: kContainerDecorationDefaultLessonEditor.copyWith(color: Colors.white),
                  child: TextField(
                    onSubmitted: onChangedCallback,
                    controller: startMinutesController,
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
                  decoration: kContainerDecorationDefaultLessonEditor.copyWith(color: Colors.white),
                  child: TextField(
                    onSubmitted: onChangedCallback,
                    controller: startSecondsController,
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
                  decoration: kContainerDecorationDefaultLessonEditor.copyWith(color: Colors.white),
                  child: TextField(
                    onSubmitted: onChangedCallback,
                    controller: endMinutesController,
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
                  decoration: kContainerDecorationDefaultLessonEditor.copyWith(color: Colors.white),
                  child: TextField(
                    onSubmitted: onChangedCallback,
                    controller: endSecondsController,
                    decoration: kTimePickerDecoration,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),
              ),
              SizedBox(width: 25),
            ],
          ),
          state.hasError
              ? Container(
                  margin: EdgeInsets.only(top: 12),
                  child: Text(
                    state.errorText,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                )
              : Container()
        ]),
        validator: (value) {
          if (checkProvidedValues()) {
            return null;
          } else {
            return 'Please, set valid video range data';
            ;
          }
        },
      ),
    );
  }
}

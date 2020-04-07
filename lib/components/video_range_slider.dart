import 'package:flutter/material.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;

class VideoRangeSlider extends StatefulWidget {
  List<Duration> startAt;
  List<Duration> endAt;
  Duration length;
  bool enabled = true;

  VideoRangeSlider(
      {this.enabled = true,
      @required this.startAt,
      @required this.endAt,
      @required this.length});

  @override
  _VideoRangeSliderState createState() => _VideoRangeSliderState();
}

class _VideoRangeSliderState extends State<VideoRangeSlider> {
  double _lowerValue = 0.0;
  double _upperValue = 100.0;

  @override
  Widget build(BuildContext context) {
    return frs.RangeSlider(
        min: 0.0,
        max: 100.0,
        lowerValue: _lowerValue,
        upperValue: _upperValue,
        divisions: 10000,
        showValueIndicator: true,
        valueIndicatorMaxDecimals: 1,
        valueIndicatorFormatter: (int index, double value) {
          int seconds = widget.length.inSeconds;

          int cur_seconds = (seconds * value / 100).toInt();
          int cur_minutes = (cur_seconds / 60).toInt();
          cur_seconds -= cur_minutes * 60;

          return cur_minutes.toString() + ":" + cur_seconds.toString();
        },
        onChanged: widget.enabled
            ? (double newLowerValue, double newUpperValue) {
                setState(() {
                  _lowerValue = newLowerValue;
                  _upperValue = newUpperValue;

                  int seconds = widget.length.inSeconds;

                  int cur_seconds = (seconds * newLowerValue / 100).toInt();

                  widget.startAt[0] = Duration(seconds: cur_seconds);

                  int cur_minutes = (cur_seconds / 60).toInt();
                  cur_seconds -= cur_minutes * 60;

                  int cur_seconds2 = (seconds * newUpperValue / 100).toInt();

                  widget.endAt[0] = Duration(seconds: cur_seconds2);

                  int cur_minutes2 = (cur_seconds2 / 60).toInt();
                  cur_seconds2 -= cur_minutes * 60;

                  // print("Add question:" + _lowerValue.toString());
                  // print("Add answer:" + _upperValue.toString());
                });
              }
            : null);
  }
}

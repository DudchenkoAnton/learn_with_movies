import 'package:flutter/material.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;

class VideoRangeSliderNew extends StatefulWidget {
  int secondsStartPoint;
  int secondsEndPoint;
  int secondsLength;
  Function(int start, int end) onChanged;

  VideoRangeSliderNew(
      {@required this.onChanged,
      @required this.secondsStartPoint,
      @required this.secondsEndPoint,
      @required this.secondsLength});

  @override
  _VideoRangeSliderNewState createState() => _VideoRangeSliderNewState();
}

class _VideoRangeSliderNewState extends State<VideoRangeSliderNew> {
  double _lowerValue = 0.0;
  double _upperValue = 100.0;
  double _lowerBoundValue = 0.0;
  double _upperBoundValue = 100.0;

  @override
  void initState() {
    super.initState();
    _lowerValue = (widget.secondsStartPoint * 100) / widget.secondsLength;
    _upperValue = (widget.secondsEndPoint * 100) / widget.secondsLength;
  }

  @override
  Widget build(BuildContext context) {
    return frs.RangeSlider(
      min: _lowerBoundValue,
      max: _upperBoundValue,
      lowerValue: (widget.secondsStartPoint * 100) / widget.secondsLength,
      upperValue: (widget.secondsEndPoint * 100) / widget.secondsLength,
      divisions: 10000,
      showValueIndicator: true,
      valueIndicatorMaxDecimals: 1,
      valueIndicatorFormatter: (int index, double value) {
        int seconds = widget.secondsLength;
        int cur_seconds = (seconds * value / 100).toInt();
        int cur_minutes = (cur_seconds / 60).toInt();
        cur_seconds -= cur_minutes * 60;
        return cur_minutes.toString() + ":" + cur_seconds.toString();
      },
      onChanged: (double newLowerValue, double newUpperValue) {
        _lowerValue = newLowerValue;
        _upperValue = newUpperValue;

        int seconds = widget.secondsLength;
        int startSeconds = (seconds * newLowerValue / 100).toInt();
        int endSeconds = (seconds * newUpperValue / 100).toInt();
        widget.secondsStartPoint = startSeconds;
        widget.secondsEndPoint = endSeconds;
        widget.onChanged(startSeconds, endSeconds);
      },
    );
  }
}

import 'package:flutter/material.dart';
//import 'package:youtube_player/youtube_player.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:temp_project/utilites/lesson_objects.dart';

class QuestionCreatorScreen extends StatefulWidget {
  static const String id = 'question_creator_screen';
  final QuestionData question;
  final LessonData videoData;

  QuestionCreatorScreen({Key key, this.question, @required this.videoData})
      : super(key: key);

  @override
  _QuestionCreatorScreenState createState() => _QuestionCreatorScreenState();
}

class _QuestionCreatorScreenState extends State<QuestionCreatorScreen> {
//  TextEditingController _startAtController = TextEditingController();
//  TextEditingController _endAtController = TextEditingController();
  TextEditingController _questionController = TextEditingController();
  TextEditingController _answerController = TextEditingController();
  String id = "https://www.youtube.com/embed/rna7NSJFVy8?&end=50";

  double _lowerValue = 0.0;
  double _upperValue = 100.0;
  Duration videoLengthOriginal = Duration(minutes: 1, seconds: 20);
  Duration startAt = Duration(seconds: 0);
  Duration endAt = Duration(minutes: 1, seconds: 20);
  bool editingMode = false;

  YoutubePlayerController _controller;

  void _incrementCounter() {
    setState(() {
      print("Add question:" + _questionController.text);
      print("Add answer:" + _answerController.text);

      print(startAt.inSeconds.toString());
      print(endAt.inSeconds.toString());
    });
  }

  void saveQuestion() {
    if (_questionController.text != '' && _answerController.text != '') {
      if (editingMode) {
        widget.question.question = _questionController.text;
        widget.question.answer = _answerController.text;
        widget.question.start = startAt;
        widget.question.end = endAt;
        Navigator.pop(context);
      } else {
        QuestionData temp = QuestionData();
        temp.question = _questionController.text;
        temp.answer = _answerController.text;
        temp.start = startAt;
        temp.end = endAt;
        temp.videoId = widget.videoData.videoId;
        Navigator.pop(context, temp);
      }
    }
    print("Add question:" + _questionController.text);
    print("Add answer:" + _answerController.text);

    print(startAt.inSeconds.toString());
    print(endAt.inSeconds.toString());
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.question == null) {
    } else {
      editingMode = true;
      _answerController.text = widget.question.answer;
      _questionController.text = widget.question.question;
      startAt = widget.question.start;
      endAt = widget.question.end;
    }

    //TODO: update videoLengthOriginal, startAt, endAt, depending on received video data
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoData.videoId,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        forceHideAnnotation: true,
      ),
    );
    _controller.addListener(() {
      if (_controller.value.position < startAt) {
        _controller.seekTo(startAt);
        _controller.pause();
      } else if (_controller.value.position > endAt) {
        _controller.seekTo(endAt);
        _controller.pause();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Question"),
        actions: <Widget>[
          RawMaterialButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: saveQuestion,
          )
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                onReady: () {
                  _controller.seekTo(startAt);
                  print('Player is ready.');
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                'Question',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _questionController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter Question'),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Answer',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _answerController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter Answer'),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Choose the range of the question:',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(
                height: 10.0,
              ),
              frs.RangeSlider(
                  min: 0.0,
                  max: 100.0,
                  lowerValue: _lowerValue,
                  upperValue: _upperValue,
                  divisions: 10000,
                  showValueIndicator: true,
                  valueIndicatorMaxDecimals: 1,
                  valueIndicatorFormatter: (int index, double value) {
                    int seconds = videoLengthOriginal.inSeconds;

                    int cur_seconds = (seconds * value / 100).toInt();
                    int cur_minutes = (cur_seconds / 60).toInt();
                    cur_seconds -= cur_minutes * 60;

                    return cur_minutes.toString() +
                        ":" +
                        cur_seconds.toString();
                  },
                  onChanged: (double newLowerValue, double newUpperValue) {
                    setState(() {
                      _lowerValue = newLowerValue;
                      _upperValue = newUpperValue;

                      int seconds = videoLengthOriginal.inSeconds;

                      int cur_seconds = (seconds * newLowerValue / 100).toInt();

                      startAt = Duration(seconds: cur_seconds);

                      int cur_minutes = (cur_seconds / 60).toInt();
                      cur_seconds -= cur_minutes * 60;

                      int cur_seconds2 =
                          (seconds * newUpperValue / 100).toInt();

                      endAt = Duration(seconds: cur_seconds2);

                      int cur_minutes2 = (cur_seconds2 / 60).toInt();
                      cur_seconds2 -= cur_minutes * 60;

                      // print("Add question:" + _lowerValue.toString());
                      // print("Add answer:" + _upperValue.toString());
                    });
                  }),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

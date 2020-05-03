import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:temp_project/components/video_range_slider.dart';
import 'create_answer_segment.dart';

class QuestionCreatorScreen extends StatefulWidget {
  static const String id = 'question_creator_screen';
  final QuestionDB question;
  final LessonDB videoData;

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
  TextEditingController _inc_answerController_1 = TextEditingController();
  TextEditingController _inc_answerController_2 = TextEditingController();
  TextEditingController _inc_answerController_3 = TextEditingController();
  String id = "https://www.youtube.com/embed/rna7NSJFVy8?&end=50";

  double _lowerValue = 0.0;
  double _upperValue = 100.0;
  Duration videoLengthOriginal = Duration(minutes: 1, seconds: 20);
  List<Duration> startAt = [Duration(seconds: 0)];
  List<Duration> endAt = [Duration(minutes: 1, seconds: 20)];
  QuestionDB temp = QuestionDB();

  YoutubePlayerController _controller;

  void _incrementCounter() {
    setState(() {
      print("Add question:" + _questionController.text);
      print("Add answer:" + _answerController.text);

      print(startAt[0].inSeconds.toString());
      print(endAt[0].inSeconds.toString());
    });
  }

  void addAnswerSegment() async {

    QuestionDB question_cur = QuestionDB();
    question_cur.setQuestion(_questionController.text);
    question_cur.setAnswer(_answerController.text);
    question_cur.setVideoStartTime(startAt[0].inSeconds);
    question_cur.setVideoEndTime(endAt[0].inSeconds);
    question_cur.setVideoURL(widget.videoData.videoURL);

    question_cur = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AnswerSegmentScreen(
              videoData: widget.videoData,
              question: question_cur,
            )));
    temp.setAnswerEndTime(question_cur.getAnswerEndTime());
    temp.setAnsewerStartTime(question_cur.getAnswerStartTime());
  }

  void saveQuestion() {
    if (_questionController.text != '' && _answerController.text != '') {

      temp.setQuestion(_questionController.text);
      temp.setAnswer(_answerController.text);
      temp.setAmericanAnswers(
          _inc_answerController_1.text + ";" +
              _inc_answerController_2.text + ";" +
              _inc_answerController_3.text);
      temp.setVideoStartTime(startAt[0].inSeconds);
      temp.setVideoEndTime(endAt[0].inSeconds);
      temp.setVideoURL(widget.videoData.videoURL);
      Navigator.pop(context, temp);
    }
    print("Add question:" + _questionController.text);
    print("Add answer:" + _answerController.text);

    print(startAt[0].inSeconds.toString());
    print(endAt[0].inSeconds.toString());
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
    videoLengthOriginal = Duration(
        seconds: widget.videoData.getVideoEndPoint() -
            widget.videoData.getVideoStartPoint());

    if (widget.question == null) {
      startAt[0] = Duration(seconds: widget.videoData.getVideoStartPoint());
      endAt[0] = Duration(seconds: widget.videoData.getVideoEndPoint());
    } else {
      _answerController.text = widget.question.answer;
      _questionController.text = widget.question.question;
      startAt[0] = Duration(seconds: widget.question.getVideoStartTime());
      endAt[0] = Duration(seconds: widget.question.getVideoEndTime());
    }

    //TODO: update videoLengthOriginal, startAt, endAt, depending on received video data
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoData.getVideoID(),
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        //forceHideAnnotation: true,
      ),
    );
    _controller.addListener(() {
      if (_controller.value.position < startAt[0]) {
        _controller.seekTo(startAt[0]);
        _controller.pause();
      } else if (_controller.value.position > endAt[0]) {
        _controller.seekTo(endAt[0]);
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
                 _controller.seekTo(startAt[0]);
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
              Text(
                'Enter 3 incorrect possible answers',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _inc_answerController_1,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter incorrect answer #1'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _inc_answerController_2,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter incorrect answer #2'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _inc_answerController_3,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter incorrect answer #3'),
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
              VideoRangeSlider(
                startAt: startAt,
                endAt: endAt,
                length: videoLengthOriginal,
              ),
              RaisedButton(
                child: Text("To add segment of answer"),
                onPressed: addAnswerSegment,
                color: Colors.green,
                textColor: Colors.amberAccent,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';


class UserQuestionsScreen extends StatefulWidget {
  static const String id = 'lesson_video_screen';

  LessonDB lessonDB;

  UserQuestionsScreen({Key key, this.title, @required this.lessonDB})
      : super(key: key);

  final String title;

  @override
  _UserQuestionsScreenState createState() => _UserQuestionsScreenState();
}

class _UserQuestionsScreenState extends State<UserQuestionsScreen> {
  int _counter = 0;
  int _cur_question = 0;
  TextEditingController _answerController = TextEditingController();
  YoutubePlayerController _controller;
  LessonDB lesson;
  List<QuestionDB> questions = [];
  QuestionDB question;
  String result = '';
  String curQuestionText = "";
  int curQuestionStartPoint = 0;
  int curQuestionEndPoint = 0;
  String disclossedAnswer = "";
  bool isAnswerDisclosed = true;
  var rating = 0.0;

  @override
  void initState() {
    //TODO: update videoLengthOriginal, startAt, endAt, depending on received video data
    lesson = widget.lessonDB;
    questions = lesson.getQuestionsList();

    QuestionDB question = questions[0];

    curQuestionStartPoint = question.getVideoStartTime();
    curQuestionEndPoint = question.getVideoEndTime();

    curQuestionText = question.getQuestion();

    _cur_question += 1;

    _controller = YoutubePlayerController(
      initialVideoId: lesson.getVideoID(),
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        //forceHideAnnotation: true,
      ),
    );
    _controller.addListener(() {
      if (_controller.value.position <
          Duration(seconds: curQuestionStartPoint)) {
        _controller.seekTo(Duration(seconds: curQuestionStartPoint));
        _controller.pause();
      } else if (_controller.value.position >
          Duration(seconds: curQuestionEndPoint)) {
        _controller.seekTo(Duration(seconds: curQuestionEndPoint));
        _controller.pause();
      }
    });
    super.initState();
  }

  void nextQuestion() {
    disclossedAnswer = "";
    isAnswerDisclosed = true;
    result = "";
    if (_cur_question == lesson.getQuestionsList().length) {
      /*
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RateScreen(),
        ),
      );

       */

      _showDialog();

    } else {
      question = lesson.getQuestionsList()[_cur_question];
      _cur_question += 1;

      setState(() {
        curQuestionText = question.getQuestion();
        curQuestionStartPoint = question.getVideoStartTime();
        curQuestionEndPoint = question.getVideoEndTime();
        _answerController.text = "";
        _controller.play();
      });
    }
  }

  void checkAnswer() {
    if (_answerController.text == question.getAnswer()) {
      isAnswerDisclosed = true;
      setState(() {
        disclossedAnswer = "";
        result = "Correct!";
      });
    } else {
      isAnswerDisclosed = false;
      setState(() {
        result = "Incorrect!";
      });
    }
  }

  void discloseAnswer() {
    setState(() {
      disclossedAnswer = question.getAnswer();
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Would you like to rate the lesson ?"),
          content: new Text(""),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new SmoothStarRating(
        rating: rating,
          size: 40,
          filledIconData: Icons.star,
          halfFilledIconData: Icons.star_half,
          defaultIconData: Icons.star_border,
          starCount: 5,
          allowHalfRating: false,
          spacing: 2.0,
          onRatingChanged: (value) {
            setState(() {
              rating = value;
            });
          },
        ),

            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    question = lesson.getQuestionsList()[_cur_question - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          RawMaterialButton(
            child: Text(
              'Next Question    ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: nextQuestion,
          )
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              onReady: () {
                _controller.seekTo(Duration(seconds: curQuestionStartPoint));
                print('Player is ready.');
              },
            ),
            Text(
              '$curQuestionText',
              style: Theme.of(context).textTheme.display1,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _answerController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Enter Answer'),
              ),
            ),
            RaisedButton(
              child: Text("Check Answer"),
              onPressed: checkAnswer,
              color: Colors.green,
              textColor: Colors.amberAccent,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              splashColor: Colors.grey,
            ),
            Text(
              '$result',
              style: Theme.of(context).textTheme.display1,
            ),

            RaisedButton(
              child: Text("Disclose the answer"),
              onPressed: isAnswerDisclosed ? null : discloseAnswer,
              //onPressed: discloseAnswer,
              color: Colors.green,
              textColor: Colors.amberAccent,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              splashColor: Colors.grey,
            ),
            Text(
              '$disclossedAnswer',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

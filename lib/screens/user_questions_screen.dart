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

  void nextQuestion() {
    if (_cur_question == lesson.getQuestionsList().length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RateScreen(),
        ),
      );
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
      setState(() {
        result = "Correct!";
      });
    } else {
      setState(() {
        result = "Incorrect!";
      });
    }
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
        forceHideAnnotation: true,
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
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/*
class SubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Page'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Click button to back to Main Page'),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.redAccent,
              child: Text('Back to Main Page'),
              onPressed: () {
                // TODO
              },
            )
          ],
        ),
      ),
    );
  }
}
*/

class RateScreen extends StatelessWidget {
  double rating = 0;

  void rateChanged(v) {
    rating = v;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
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
            Text(
              'Would you like to rate the lesson ?',
              style: Theme.of(context).textTheme.display1,
            ),
            SmoothStarRating(
                allowHalfRating: false,
                onRatingChanged: rateChanged,
                starCount: 5,
                rating: rating,
                size: 40.0,
                filledIconData: Icons.blur_off,
                halfFilledIconData: Icons.blur_on,
                color: Colors.green,
                borderColor: Colors.green,
                spacing: 0.0)
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

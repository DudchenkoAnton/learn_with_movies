import 'dart:math';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:temp_project/database/database_utilities.dart';

class ScoreScreen extends StatefulWidget {
  static const String id = 'lesson_video_screen';

  LessonDB lessonDB;
  int num_correct_answ;

  ScoreScreen({Key key, this.title, @required this.lessonDB,
    @required this.num_correct_answ}) : super(key: key);

  final String title;

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
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

  String answer_option_1 = "";
  String answer_option_2 = "";
  String answer_option_3 = "";
  String answer_option_4 = "";

  List<int> answer_options = [1, 2, 3, 4];

  int correctAnswerNum = 0;

  TextEditingController _answer_open_format = TextEditingController();

  int result_mode = 0; // 1 if in result mode, 0 in question mode

  String next_question_label = "";

  bool dialog_showed = false;

  bool check_answer_enabled = false;

  Widget rating_widget;

  int times_dialog_called = 0;

  void defineOptionsForAnswers() {
    if (question.americanAnswers != ";;" && question.americanAnswers != "") {
      List<String> incorrectOptionsList = question.getAmericanAnswers().split(";");

      Random random = new Random();
      correctAnswerNum = answer_options[random.nextInt(answer_options.length)];
      answer_options.remove(correctAnswerNum);
      int incorrect_option_1 = answer_options[random.nextInt(answer_options.length)];
      answer_options.remove(incorrect_option_1);
      int incorrect_option_2 = answer_options[random.nextInt(answer_options.length)];
      answer_options.remove(incorrect_option_2);
      int incorrect_option_3 = answer_options[0];

      if (correctAnswerNum == 1) {
        answer_option_1 = question.getAnswer();
      }
      if (correctAnswerNum == 2) {
        answer_option_2 = question.getAnswer();
      }
      if (correctAnswerNum == 3) {
        answer_option_3 = question.getAnswer();
      }
      if (correctAnswerNum == 4) {
        answer_option_4 = question.getAnswer();
      }

      if (incorrect_option_1 == 1) {
        answer_option_1 = incorrectOptionsList[0];
      }
      if (incorrect_option_1 == 2) {
        answer_option_2 = incorrectOptionsList[0];
      }
      if (incorrect_option_1 == 3) {
        answer_option_3 = incorrectOptionsList[0];
      }
      if (incorrect_option_1 == 4) {
        answer_option_4 = incorrectOptionsList[0];
      }

      if (incorrect_option_2 == 1) {
        answer_option_1 = incorrectOptionsList[1];
      }
      if (incorrect_option_2 == 2) {
        answer_option_2 = incorrectOptionsList[1];
      }
      if (incorrect_option_2 == 3) {
        answer_option_3 = incorrectOptionsList[1];
      }
      if (incorrect_option_2 == 4) {
        answer_option_4 = incorrectOptionsList[1];
      }

      if (incorrect_option_3 == 1) {
        answer_option_1 = incorrectOptionsList[2];
      }
      if (incorrect_option_3 == 2) {
        answer_option_2 = incorrectOptionsList[2];
      }
      if (incorrect_option_3 == 3) {
        answer_option_3 = incorrectOptionsList[2];
      }
      if (incorrect_option_3 == 4) {
        answer_option_4 = incorrectOptionsList[2];
      }

      answer_options = [1, 2, 3, 4];
    }
  }

  @override
  void initState() {
    //TODO: update videoLengthOriginal, startAt, endAt, depending on received video data
    lesson = widget.lessonDB;
    questions = lesson.getQuestionsList();

    QuestionDB question = questions[0];

    //defineOptionsForAnswers();

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
      if (_controller.value.position < Duration(seconds: curQuestionStartPoint)) {
        _controller.seekTo(Duration(seconds: curQuestionStartPoint));
        _controller.pause();
      } else if (_controller.value.position > Duration(seconds: curQuestionEndPoint)) {
        _controller.seekTo(Duration(seconds: curQuestionEndPoint));
        _controller.pause();
      }
    });
    super.initState();
  }


  void build_rating_widget() {

      rating_widget = SmoothStarRating(
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
            dialog_showed = true;

            rating = value;
            DatabaseUtilities db = new DatabaseUtilities();
            lesson.setNumberViews(lesson.getNumberViews() + 1);
            double lesson_rating = ((lesson.getNumberReviews() * lesson.getAverageRating()) + rating) /
                (lesson.getNumberReviews() + 1);
            lesson.setAverageRating(lesson_rating);
            lesson.setNumberReviews(lesson.getNumberReviews() + 1);
            db.updateLessonRatingAndViews(lesson);
            //Navigator.of(context).popUntil((route) => route.isFirst);

            Navigator.pop(context);
            times_dialog_called = 0;
            _showDialog();
          });
        },
      );

  }


  void _showDialog() {

    times_dialog_called += 1;
    if (times_dialog_called >= 2) {
      return;
    }

    build_rating_widget();

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

            rating_widget,

            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                //DatabaseUtilities db = new DatabaseUtilities();
                //lesson.setNumberViews(lesson.getNumberViews() + 1);
                //db.updateNumberViews(lesson);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    question = lesson.getQuestionsList()[_cur_question - 1];
    defineOptionsForAnswers();

    Future.delayed(const Duration(seconds: 5), () {

      _showDialog();

    });

    return Scaffold(
        appBar: AppBar(

          leading: new IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
          ),

          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Center(
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
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child:Text(
                    "Well done!\nYou've finished the lesson:\n",
                    style: Theme.of(context).textTheme.display1.apply(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                //SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child:Text(
                    widget.lessonDB.lessonName,
                    style: Theme.of(context).textTheme.display1.apply(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child:Text(
                    "You answered correctly on " + widget.num_correct_answ.toString()
                    + "/" + widget.lessonDB.getQuestionsList().length.toString()
                    + " questions!",
                    style: Theme.of(context).textTheme.display1.apply(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        )
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

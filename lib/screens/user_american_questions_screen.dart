import 'dart:math';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:temp_project/database/database_utilities.dart';

class UserAmericanQuestionsScreen extends StatefulWidget {
  static const String id = 'lesson_video_screen';

  LessonDB lessonDB;

  UserAmericanQuestionsScreen({Key key, this.title, @required this.lessonDB}) : super(key: key);

  final String title;

  @override
  _UserAmericanQuestionsScreenState createState() => _UserAmericanQuestionsScreenState();
}

class _UserAmericanQuestionsScreenState extends State<UserAmericanQuestionsScreen> {
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

  Widget selectedWidget = Container();

  TextEditingController _answer_open_format = TextEditingController();

  int result_mode = 0; // 1 if in result mode, 0 in question mode

  String next_question_label = "";

  bool dialog_showed = false;

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

  void handle_option_1() {
    setState(() {
      result_mode = 1;

      if (correctAnswerNum == 1) {
        result = "Correct!";
        create_result_widget(true, "");
      }
      if (correctAnswerNum == 2) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_1);
      }
      if (correctAnswerNum == 3) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_1);
      }
      if (correctAnswerNum == 4) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_1);
      }
    });
  }

  void handle_option_2() {
    setState(() {
      result_mode = 1;

      if (correctAnswerNum == 1) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_2);
      }
      if (correctAnswerNum == 2) {
        result = "Correct!";
        create_result_widget(true, "");
      }
      if (correctAnswerNum == 3) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_2);
      }
      if (correctAnswerNum == 4) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_2);
      }
    });
  }

  void handle_option_3() {
    setState(() {
      result_mode = 1;

      if (correctAnswerNum == 1) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_3);
      }
      if (correctAnswerNum == 2) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_3);
      }
      if (correctAnswerNum == 3) {
        result = "Correct!";
        create_result_widget(true, "");
      }
      if (correctAnswerNum == 4) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_3);
      }
    });
  }

  void handle_option_4() {
    setState(() {
      result_mode = 1;

      if (correctAnswerNum == 1) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_4);
      }
      if (correctAnswerNum == 2) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_4);
      }
      if (correctAnswerNum == 3) {
        result = "Incorrect!";
        create_result_widget(false, answer_option_4);
      }
      if (correctAnswerNum == 4) {
        result = "Correct!";
        create_result_widget(true, "");
      }
    });
  }

  void nextQuestion() {
    result_mode = 0;

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

      //defineOptionsForAnswers();

      setState(() {
        curQuestionText = question.getQuestion();
        curQuestionStartPoint = question.getVideoStartTime();
        curQuestionEndPoint = question.getVideoEndTime();
        _answerController.text = "";
        _controller.reset();
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

  void _showAnswer() {
    // flutter defined function
    if (!this.question.isAnswerVideoAdded()) {
      discloseAnswer();
    } else {
      _controller.pause();

      curQuestionStartPoint = question.getAnswerStartTime();
      curQuestionEndPoint = question.getAnswerEndTime();

      _controller.play();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Listen for the answer!"),
            content: new Text(""),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                onReady: () {
                  _controller.seekTo(Duration(seconds: curQuestionStartPoint));
                  print('Player is ready.');
                },
              ),
            ],
          );
        },
      ).then((val) {
        _controller.pause();

        curQuestionStartPoint = question.getVideoStartTime();
        curQuestionEndPoint = question.getVideoEndTime();

        _controller.play();
      });
    }
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
                  dialog_showed = true;

                  rating = value;
                  DatabaseUtilities db = new DatabaseUtilities();
                  lesson.setNumberViews(lesson.getNumberViews() + 1);
                  double lesson_rating = ((lesson.getNumberReviews() * lesson.getAverageRating()) + rating) /
                      (lesson.getNumberReviews() + 1);
                  lesson.setAverageRating(lesson_rating);
                  lesson.setNumberReviews(lesson.getNumberReviews() + 1);
                  db.updateLessonRatingAndViews(lesson);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                });
              },
            ),

            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                DatabaseUtilities db = new DatabaseUtilities();
                lesson.setNumberViews(lesson.getNumberViews() + 1);
                db.updateNumberViews(lesson);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  void create_result_widget(bool result, String answer) {
    setState(() {
      next_question_label = 'Next Question    ';
    });

    if (result == false) {
      selectedWidget = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(
              Icons.not_interested,
              color: Colors.red,
              size: 60.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Your answer: ' + answer + "\n\nCorrect answer:",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              question.answer,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.green),
            ),
          ),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              _controller.seekTo(Duration(seconds: curQuestionStartPoint));
              print('Player is ready.');
            },
          ),
        ],
      );
    } else {
      selectedWidget = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Correct!',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60.0,
            ),
          ),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              _controller.seekTo(Duration(seconds: curQuestionStartPoint));
              print('Player is ready.');
            },
          ),
        ],
      );
    }
  }

  void create_question_widget() {
    if (result_mode == 1) {
      return;
    }

    int num_of_circles = this.lesson.getQuestionsList().length;

    Widget circle1 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );

    if (_cur_question == 1) {
      circle1 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }

    Widget circle2 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 2) {
      circle2 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle3 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 3) {
      circle3 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle4 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 4) {
      circle4 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle5 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 5) {
      circle5 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle6 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 6) {
      circle6 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle7 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 7) {
      circle7 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle8 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 8) {
      circle8 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle9 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 9) {
      circle9 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }
    Widget circle10 = Icon(
      Icons.fiber_manual_record,
      color: Colors.grey,
      size: 20.0,
    );
    if (_cur_question == 10) {
      circle10 = Icon(
        Icons.fiber_manual_record,
        color: Colors.blue,
        size: 20.0,
      );
    }

    Widget circles;

    if (num_of_circles == 10) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
            circle4,
            circle5,
            circle6,
            circle7,
            circle8,
            circle9,
            circle10,
          ],
        ),
      );
    }
    if (num_of_circles == 9) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
            circle4,
            circle5,
            circle6,
            circle7,
            circle8,
            circle9,
          ],
        ),
      );
    }
    if (num_of_circles == 8) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
            circle4,
            circle5,
            circle6,
            circle7,
            circle8,
          ],
        ),
      );
    }
    if (num_of_circles == 7) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
            circle4,
            circle5,
            circle6,
            circle7,
          ],
        ),
      );
    }
    if (num_of_circles == 6) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
            circle4,
            circle5,
            circle6,
          ],
        ),
      );
    }
    if (num_of_circles == 5) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
            circle4,
            circle5,
          ],
        ),
      );
    }
    if (num_of_circles == 4) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
            circle4,
          ],
        ),
      );
    }
    if (num_of_circles == 3) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
            circle3,
          ],
        ),
      );
    }
    if (num_of_circles == 2) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
            circle2,
          ],
        ),
      );
    }
    if (num_of_circles == 1) {
      circles = Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            circle1,
          ],
        ),
      );
    }

    setState(() {
      next_question_label = "";
    });

    if (question.americanAnswers != ";;" && question.americanAnswers != "") {
      selectedWidget = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
            child: circles,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(70, 10, 70, 10),
            child: Text(
              '$curQuestionText',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FlatButton(
              onPressed: handle_option_1,
              //onPressed: discloseAnswer,
              textColor: Colors.black,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(
                answer_option_1,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 2,
                    //style: BorderStyle.solid
                  ),
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FlatButton(
              onPressed: handle_option_2,
              //onPressed: discloseAnswer,
              textColor: Colors.black,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(
                answer_option_2,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 2,
                    //style: BorderStyle.solid
                  ),
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FlatButton(
              onPressed: handle_option_3,
              //onPressed: discloseAnswer,
              textColor: Colors.black,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(
                answer_option_3,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 2,
                    //style: BorderStyle.solid
                  ),
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FlatButton(
              onPressed: handle_option_4,
              //onPressed: discloseAnswer,
              textColor: Colors.black,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(
                answer_option_4,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 2,
                    //style: BorderStyle.solid
                  ),
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$result',
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ],
      );
    } else {
      selectedWidget = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
            child: circles,
          ),
          Text(
            '$curQuestionText',
            style: Theme.of(context).textTheme.display1,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onEditingComplete: () {
                result_mode = 1;
                if (_answer_open_format.text == question.answer) {
                  create_result_widget(true, "");
                } else {
                  create_result_widget(false, _answer_open_format.text);
                }
                _answer_open_format.text = "";
              },
              controller: _answer_open_format,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    ),
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  contentPadding: new EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  hintText: 'Enter the Answer'),
            ),
          ),
/*
          FlatButton(
            onPressed: (){
              String str = _answer_open_format.text;
              _answer_open_format.text = "";
              result_mode = 1;
              if (str == question.answer) {
                create_result_widget(true, "");
              }
              else {
                create_result_widget(false, str);
              }
            },
            //onPressed: discloseAnswer,
            textColor: Colors.black,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Text("Check the answer", style: TextStyle(color: Colors.black, fontSize: 20),),
            shape: RoundedRectangleBorder(side: BorderSide(
                color: Colors.blue,
                width: 4,
                style: BorderStyle.solid
            ), borderRadius: BorderRadius.circular(20)),
          ),
 */
        ],
      );
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
  Widget build(BuildContext context) {
    question = lesson.getQuestionsList()[_cur_question - 1];
    defineOptionsForAnswers();

    create_question_widget();

    return Scaffold(
      appBar: AppBar(
        /*
        leading: new IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        ),
         */
        title: Text(widget.title),
        actions: <Widget>[
          RawMaterialButton(
            child: Text(
              '$next_question_label',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
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
            Container(
              child: selectedWidget,
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

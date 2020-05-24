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
  TextEditingController _answerController2 = TextEditingController();
  TextEditingController _answerController3 = TextEditingController();
  TextEditingController _answerController4 = TextEditingController();
  TextEditingController _answer_open_format = TextEditingController();

  String id = "https://www.youtube.com/embed/rna7NSJFVy8?&end=50";

  double _lowerValue = 0.0;
  double _upperValue = 100.0;
  Duration videoLengthOriginal = Duration(minutes: 1, seconds: 20);
  List<Duration> startAt = [Duration(seconds: 0)];
  List<Duration> endAt = [Duration(minutes: 1, seconds: 20)];
  QuestionDB temp = QuestionDB();

  YoutubePlayerController _controller;

  Color option_color_1 = Colors.green;
  Color option_color_2 = Colors.white;
  Color option_color_3 = Colors.white;
  Color option_color_4 = Colors.white;

  String option_text_1 = "o";
  String option_text_2 = "o";
  String option_text_3 = "o";
  String option_text_4 = "o";

  bool is_pressed_1 = true;
  bool is_pressed_2 = false;
  bool is_pressed_3 = false;
  bool is_pressed_4 = false;

  int correct_answer = 1;

  int format_of_question = 0;

  Widget selectedWidget = Container();

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


    if (format_of_question == 1) {
      List<String> answers = [_answerController.text, _answerController2.text,
        _answerController3.text, _answerController4.text];

      String correct_answer_str = "";

      if (correct_answer == 1) {
        correct_answer_str= answers.removeAt(0);
      }
      if (correct_answer == 2) {
        correct_answer_str = answers.removeAt(1);
      }
      if (correct_answer == 3) {
        correct_answer_str = answers.removeAt(2);
      }
      if (correct_answer == 4) {
        correct_answer_str = answers.removeAt(3);
      }

      temp.setQuestion(_questionController.text);
      temp.setAnswer(correct_answer_str);
      temp.setAmericanAnswers(
          answers[0] + ";" +
              answers[1] + ";" +
              answers[2]);
    }

    if (format_of_question == 2) {

      temp.setQuestion(_questionController.text);
      temp.setAnswer(_answer_open_format.text);
    }


    temp.setVideoStartTime(startAt[0].inSeconds);
    temp.setVideoEndTime(endAt[0].inSeconds);
    temp.setVideoURL(widget.videoData.videoURL);
    Navigator.pop(context, temp);

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


    selectedWidget = Container(
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
            Text(
              'Range video for answer',
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
          ],
        ),
      ),
    );
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
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Padding(padding: const EdgeInsets.all(8.0),
                  child:FlatButton(
                    onPressed: () {

                      format_of_question = 1;

                      setState(() {
                        selectedWidget = Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Padding(

                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _questionController,
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
                                        hintText: 'Enter the Question'),
                                  ),
                                ),
                                Text(
                                  'Marker one correct answer:',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                                ),

                                Row(
                                  children: <Widget>[

                                    RawMaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          is_pressed_4 = false;
                                          is_pressed_2 = false;
                                          is_pressed_3 = false;
                                          is_pressed_1 = true;

                                          correct_answer = 1;
                                        });
                                      },
                                      elevation: 2.0,
                                      fillColor: (is_pressed_1) ? Colors.green : Colors.grey,
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 17.0,
                                        //color: (is_pressed_1) ? Colors.green : Colors.grey,
                                      ),
                                      padding: EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                    ),


                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _answerController,
                                          decoration: InputDecoration(
                                              enabledBorder: const OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(8.0),
                                                ),
                                                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                              ),
                                              contentPadding: new EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              hintText: 'Enter answer #1'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),

                                Row(
                                  children: <Widget>[

                                    RawMaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          is_pressed_1 = false;
                                          is_pressed_4 = false;
                                          is_pressed_3 = false;
                                          is_pressed_2 = true;

                                          correct_answer = 2;
                                        });
                                      },
                                      elevation: 2.0,
                                      fillColor: (is_pressed_2) ? Colors.green : Colors.grey,
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 17.0,
                                        //color: (is_pressed_2) ? Colors.green : Colors.grey,
                                      ),
                                      padding: EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _answerController2,
                                          decoration: InputDecoration(
                                              enabledBorder: const OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(8.0),
                                                ),
                                                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                              ),
                                              contentPadding: new EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              hintText: 'Enter answer #2'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[

                                    RawMaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          is_pressed_1 = false;
                                          is_pressed_2 = false;
                                          is_pressed_4 = false;
                                          is_pressed_3 = true;

                                          correct_answer = 3;
                                        });
                                      },
                                      elevation: 2.0,
                                      fillColor: (is_pressed_3) ? Colors.green : Colors.grey,
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 17.0,
                                        //color: (is_pressed_3) ? Colors.green : Colors.grey,
                                      ),
                                      padding: EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _answerController3,
                                          decoration: InputDecoration(
                                              enabledBorder: const OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(8.0),
                                                ),
                                                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                              ),
                                              contentPadding: new EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              hintText: 'Enter answer #3'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[

                                    RawMaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          is_pressed_1 = false;
                                          is_pressed_2 = false;
                                          is_pressed_3 = false;
                                          is_pressed_4 = true;

                                          correct_answer = 4;
                                        });
                                      },
                                      elevation: 2.0,
                                      fillColor: (is_pressed_4) ? Colors.green : Colors.grey,
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 17.0,
                                        //color: (is_pressed_4) ? Colors.green : Colors.grey,
                                      ),
                                      padding: EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _answerController4,
                                          decoration: InputDecoration(
                                              enabledBorder: const OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(8.0),
                                                ),
                                                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                              ),
                                              contentPadding: new EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              hintText: 'Enter answer #4'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                YoutubePlayer(
                                  controller: _controller,
                                  showVideoProgressIndicator: true,
                                  onReady: () {
                                    _controller.seekTo(startAt[0]);
                                    print('Player is ready.');
                                  },
                                ),
                                Text(
                                  'Range video for answer',
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
                              ],
                            ),
                          ),
                        );
                      });
                    },
                    child: Text("\nmultiple\nchoise\nquestion\n", style: TextStyle(color: Colors.black, fontSize: 20),),
                    shape: RoundedRectangleBorder(side: BorderSide(
                        color: Colors.blue,
                        width: 4,
                        style: BorderStyle.solid
                    ), borderRadius: BorderRadius.circular(20)),
                  ),),





              FlatButton(
                onPressed: () {
                  format_of_question = 2;
                  setState(() {
    selectedWidget = Container(
    child: SingleChildScrollView(
    child: Column(
    children: <Widget>[
    Padding(

    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
    controller: _questionController,
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
    hintText: 'Enter the Question'),
    ),
    ),
      Padding (
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
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
    YoutubePlayer(
    controller: _controller,
    showVideoProgressIndicator: true,
    onReady: () {
    _controller.seekTo(startAt[0]);
    print('Player is ready.');
    },
    ),
    Text(
    'Range video for answer',
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
    ],
    ),
    ),
    );
    });

                },

                child: Text("\nopen\nquestion\n\n", style: TextStyle(color: Colors.black, fontSize: 20),),
                shape: RoundedRectangleBorder(side: BorderSide(
                    color: Colors.blue,
                    width: 4,
                    style: BorderStyle.solid
                ), borderRadius: BorderRadius.circular(20)),
              ),
            ],
          ),
          Container(
            child: selectedWidget,
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

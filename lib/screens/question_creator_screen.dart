import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:temp_project/components/video_range_slider.dart';
import 'create_answer_segment.dart';
import 'package:temp_project/components/video_range_text_field.dart';
import 'package:temp_project/components/video_range_slider_new.dart';

class QuestionCreatorScreen extends StatefulWidget {
  static const String id = 'question_creator_screen';
  QuestionDB question;
  final LessonDB videoData;

  QuestionCreatorScreen({Key key, this.question, @required this.videoData}) : super(key: key);

  @override
  _QuestionCreatorScreenState createState() => _QuestionCreatorScreenState();
}

class _QuestionCreatorScreenState extends State<QuestionCreatorScreen> {
  final _secondStepFormKey = GlobalKey<FormState>();

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

  bool activate_button_1 = true;
  bool activate_button_2 = true;
  bool activate_button_3 = true;
  bool activate_button_4 = true;

  int american_function_counter = 0;
  int open_function_counter = 0;

  int correct_answer = 1;

  int format_of_question = 0;

  String question_creation_text = "";

  Widget selectedWidget = Container();

  int cur_start_time_secconds = 0;
  int cur_end_time_secconds = 0;

  int last_range_indication = 0; // 0 - slider, 1 - text

  int widgetless_fix = 0;

  int lenght_cur = 0;

  int open_visited_func = 0;

  int num_of_screen_updates = 0;
  int american_num_of_screen_updates = 0;

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
      List<String> answers = [
        _answerController.text,
        _answerController2.text,
        _answerController3.text,
        _answerController4.text
      ];

      String correct_answer_str = "";

      if (correct_answer == 1) {
        correct_answer_str = answers.removeAt(0);
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
      temp.setAmericanAnswers(answers[0] + ";" + answers[1] + ";" + answers[2]);
    }

    if (format_of_question == 2) {
      temp.setQuestion(_questionController.text);
      temp.setAnswer(_answer_open_format.text);
    }

    temp.setVideoURL(widget.videoData.videoURL);

    bool is_data_full = false;

    if (temp.americanAnswers.length == 0) {
      if (_questionController.text.length > 0 && _answer_open_format.text.length > 0) {
        is_data_full = true;
      }
    }
    else {
      if (_questionController.text.length > 0 && _answerController.text.length > 0 &&
          _answerController2.text.length > 0 && _answerController3.text.length > 0 &&
          _answerController4.text.length > 0) {
        is_data_full = true;
      }
    }

    if (is_data_full == true) {
      Navigator.pop(context, temp);
    }
    else {
      _showDialog();
    }

    print("Add question:" + _questionController.text);
    print("Add answer:" + _answerController.text);

    print(startAt[0].inSeconds.toString());
    print(endAt[0].inSeconds.toString());
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Please fill the missing data to create a question"),
          content: new Text(""),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
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
  void initState() {
    widgetless_fix = widget.videoData.getVideoStartPoint();

    videoLengthOriginal =
        Duration(seconds: widget.videoData.getVideoEndPoint() - widget.videoData.getVideoStartPoint());
    ///// *****************************
    if (widget.question == null) {
      cur_start_time_secconds = widget.videoData.getVideoStartPoint();
      cur_end_time_secconds = widget.videoData.getVideoEndPoint();
    } else {
      question_creation_text = "";
      _answerController.text = widget.question.answer;
      _answer_open_format.text = widget.question.answer;
      List<String> options = widget.question.americanAnswers.split(";");

      if (options.length >= 3 && (options[0].length > 0 || options[1].length > 0 || options[2].length > 0)) {
        _answerController2.text = options[0];
        _answerController3.text = options[1];
        _answerController4.text = options[2];
      }

      _questionController.text = widget.question.question;
      ///// *****************************
      cur_start_time_secconds = widget.question.getVideoStartTime();
      cur_end_time_secconds = widget.question.getVideoEndTime();
      print("Answer start time - ${cur_start_time_secconds}");
      print("Answer start time - ${cur_end_time_secconds}");
    }

    //TODO: update videoLengthOriginal, startAt, endAt, depending on received video data
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoData.getVideoID(),
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        //forceHideAnnotation: true,
      ),
    );
    _controller.addListener(() {
      if (_controller.value.position < Duration(seconds: cur_start_time_secconds)) {
        _controller.seekTo(Duration(seconds: cur_start_time_secconds));
        //_controller.pause();
      } else if (_controller.value.position > Duration(seconds: cur_end_time_secconds)) {
        _controller.seekTo(Duration(seconds: cur_start_time_secconds));
        _controller.pause();
      }
    });
    super.initState();

    selectedWidget = Container();

    ///// *****************************
    lenght_cur = cur_end_time_secconds - cur_start_time_secconds;

    ///// *****************************
    if (widget.question == null) {
      temp.setVideoStartTime(widget.videoData.getVideoStartPoint());
      temp.setVideoEndTime(widget.videoData.getVideoEndPoint());
    } else {
      temp.setVideoStartTime(widget.question.getVideoStartTime());
      temp.setVideoEndTime(widget.question.getVideoEndTime());
    }
  }

  @override
  Widget build(BuildContext context) {
    void american_button_action() {
      if (american_function_counter > 1) {
        return;
      }

      setState(() {
        startAt[0] = Duration(seconds: widget.videoData.getVideoStartPoint());
        endAt[0] = Duration(seconds: widget.videoData.getVideoEndPoint());
        //cur_start_time_secconds = widget.videoData.getVideoStartPoint();
        //cur_end_time_secconds = widget.videoData.getVideoEndPoint();

        question_creation_text = "";
        format_of_question = 1;
        selectedWidget = Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
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
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Marker one correct answer:',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(
                  height: 10.0,
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

                          if (activate_button_1 == true) {
                            american_button_action();
                            activate_button_1 = false;
                            activate_button_4 = true;
                            activate_button_2 = true;
                            activate_button_3 = true;

                            american_function_counter += 1;
                          }
                        });
                      },
                      elevation: 2.0,
                      fillColor: (is_pressed_1 == true) ? Colors.green : Colors.grey,
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
                        child: TextFormField(minLines: 2, maxLines: 2,

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

                          if (activate_button_2 == true) {
                            american_button_action();
                            activate_button_2 = false;
                            activate_button_1 = true;
                            activate_button_4 = true;
                            activate_button_3 = true;

                            american_function_counter += 1;
                          }
                        });
                      },
                      elevation: 2.0,
                      fillColor: (is_pressed_2 == true) ? Colors.green : Colors.grey,
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
                        child: TextFormField(minLines: 2, maxLines: 2,
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

                          if (activate_button_3 == true) {
                            american_button_action();
                            activate_button_3 = false;
                            activate_button_1 = true;
                            activate_button_2 = true;
                            activate_button_4 = true;

                            american_function_counter += 1;
                          }
                        });
                      },
                      elevation: 2.0,
                      fillColor: (is_pressed_3 == true) ? Colors.green : Colors.grey,
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
                        child: TextFormField(minLines: 2, maxLines: 2,
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

                          if (activate_button_4 == true) {
                            american_button_action();
                            activate_button_4 = false;
                            activate_button_1 = true;
                            activate_button_2 = true;
                            activate_button_3 = true;
                          }
                        });
                      },
                      elevation: 2.0,
                      fillColor: (is_pressed_4 == true) ? Colors.green : Colors.grey,
                      child: Icon(
                        Icons.check_circle,
                        size: 17.0,
                        //color: (is_pressed_4) ? Colors.green : Colors.grey,
                      ),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                    Expanded (
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(minLines: 2, maxLines: 2,
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
                    //_controller.seekTo(Duration(seconds: cur_start_time_secconds));
                    print('Player is ready.');
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Range video for answer',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                /*
                VideoRangeSlider(
                  startAt: startAt,
                  endAt: endAt,
                  length: videoLengthOriginal,
                ),

                 */
                // AMERICAN

                VideoRangeSliderNew(
                  secondsStartPoint: cur_start_time_secconds,
                  secondsEndPoint: cur_end_time_secconds,
                  secondsLength: widget.videoData.originalVideoLength,
                  onChanged: (int start, int end) {
                    setState(() {
                      last_range_indication = 1;
                      cur_start_time_secconds = start;
                      cur_end_time_secconds =  end;
                      temp.setVideoStartTime(start);
                      temp.setVideoEndTime(end);
                      _controller.pause();
                      american_button_action();
                      american_function_counter += 1;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                VideoRangeText(
                  formKey: _secondStepFormKey,
                  secondsStartPoint: cur_start_time_secconds,
                  secondsEndPoint: cur_end_time_secconds,
                  secondsLength: widget.videoData.originalVideoLength,
                  onChanged: (int start, int end) {
                    setState(() {
                      last_range_indication = 2;
                      cur_start_time_secconds = start;
                      cur_end_time_secconds = end;
                      temp.setVideoStartTime(start);
                      temp.setVideoEndTime(end);
                      _controller.pause();
                      american_button_action();
                      american_function_counter += 1;
                    });
                  },
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      });

      american_function_counter = 0;
    }

    void open_button_action() {
      if (open_function_counter > 1) {
        return;
      }

      setState(() {
        startAt[0] = Duration(seconds: widget.videoData.getVideoStartPoint());
        endAt[0] = Duration(seconds: widget.videoData.getVideoEndPoint());
        //if (widget.question == null) {
        //cur_start_time_secconds = widget.videoData.getVideoStartPoint();
        //cur_end_time_secconds = widget.videoData.getVideoEndPoint();
        //}
        //else {
        // cur_start_time_secconds = widget.question.getVideoStartTime();
        // cur_end_time_secconds = widget.question.getVideoEndTime();
        // }

        question_creation_text = "";
        format_of_question = 2;
        selectedWidget = Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
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
                    //_controller.seekTo(Duration(seconds: cur_start_time_secconds));
                    print('Player is ready.');
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Range video for answer',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),),
                SizedBox(
                  height: 10.0,
                ),
                /*
                            VideoRangeSlider(
                              startAt: startAt,
                              endAt: endAt,
                              length: videoLengthOriginal,
                            ),
                             */

                VideoRangeSliderNew(
                  secondsStartPoint: cur_start_time_secconds,
                  secondsEndPoint: cur_end_time_secconds,
                  secondsLength: widget.videoData.originalVideoLength,
                  onChanged: (int start, int end) {
                    setState(() {
                      last_range_indication = 1;
                      cur_start_time_secconds = start;
                      cur_end_time_secconds =  end;
                      temp.setVideoStartTime(start);
                      temp.setVideoEndTime(end);
                      _controller.pause();
                      open_button_action();
                      open_function_counter += 1;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                VideoRangeText(
                  formKey: _secondStepFormKey,
                  secondsStartPoint: cur_start_time_secconds,
                  secondsEndPoint: cur_end_time_secconds,
                  secondsLength: widget.videoData.originalVideoLength,
                  onChanged: (int start, int end) {
                    setState(() {
                      last_range_indication = 2;
                      cur_start_time_secconds = start;
                      cur_end_time_secconds = end;
                      temp.setVideoStartTime(start);
                      temp.setVideoEndTime(end);
                      _controller.pause();
                      open_button_action();
                      open_function_counter += 1;
                    });
                  },
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      });

      open_function_counter = 0;
    }

    if (widget.question == null) {

      american_num_of_screen_updates++;

      if (american_num_of_screen_updates <= 1) {


        american_button_action();
      }

    } else {
      List<String> options = widget.question.americanAnswers.split(";");

      num_of_screen_updates++;

      if (options.length >= 3 && (options[0].length > 0 ||
          options[1].length > 0 || options[2].length > 0) && num_of_screen_updates <= 1) {
        american_button_action();
      }
      if (widget.question.americanAnswers.length == 0 && num_of_screen_updates <= 1) {
        open_button_action();
      }
    }


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Question"),
        actions: <Widget>[
          RawMaterialButton(
            child: Text(
              'Continue',
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: american_button_action,
                  child: Text(
                    "\nMultiple Choice\n     Question\n",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue, width: 4, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20)),
                  color: (format_of_question == 1) ? Colors.blue : Colors.white,
                ),
              ),
              FlatButton(
                onPressed: open_button_action,
                child: Text(
                  "\n         Open\n      Question       \n",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue, width: 4, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20)),
                color: (format_of_question == 2) ? Colors.blue : Colors.white,
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

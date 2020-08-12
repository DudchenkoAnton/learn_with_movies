import 'dart:async';

import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/screens/UserChooseLesson.dart';
import 'package:temp_project/screens/user_questions_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../database/database_utilities.dart';
import 'user_american_questions_screen.dart';
import 'package:temp_project/utilites/texts.dart';

class LessonVideoScreen extends StatefulWidget {
  static const String id = 'lesson_video_screen';
  LessonDB lessonData;

  LessonVideoScreen({@required this.lessonData});

  @override
  _LessonVideoScreenState createState() => _LessonVideoScreenState();
}

class _LessonVideoScreenState extends State<LessonVideoScreen> {
  int secondsStartPoint = 0;
  int secondsEndPoint = 1;
  bool dialogOnScreen = false;
  bool firstBuild = true;
  Orientation currentOrientation;
  YoutubePlayerController _youtubePlayerController;
  YoutubePlayer _youtubePlayer;
  DatabaseUtilities db = new DatabaseUtilities();
  bool passedInitialDialog = false;

  Timer _timer;
  int _start = 10;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    secondsStartPoint = widget.lessonData.getVideoStartPoint();
    secondsEndPoint = widget.lessonData.getVideoEndPoint();
    _youtubePlayerController = YoutubePlayerController(initialVideoId: widget.lessonData.videoID);
    _youtubePlayerController.addListener(playSelectedSegmentListener);
    _youtubePlayer = YoutubePlayer(
      bottomActions: <Widget>[
        SizedBox(width: 14.0),
        CurrentPosition(),
        SizedBox(width: 8.0),
        ProgressBar(isExpanded: true),
        RemainingDuration(),
        PlaybackSpeedButton(),
      ],
      controller: _youtubePlayerController,
      showVideoProgressIndicator: true,
      onReady: () {
        print('Player is ready.');
      },
      onEnded: onEndedCallback,
    );
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: passedInitialDialog ? buildVideoPlayer() : buildInitialDialog(),
        ));
  }

  @override
  void dispose() {
    _timer.cancel();
    if (_youtubePlayerController != null) _youtubePlayerController.dispose();
    super.dispose();
  }

  // This function starts counting down from 10 seconds, once user enters screen
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
            passedInitialDialog = true;
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  // This callback enables playing video only on chosen borders (by creator of lesson)
  void playSelectedSegmentListener() {
    if (_youtubePlayerController.value.position.inSeconds < secondsStartPoint) {
      _youtubePlayerController.seekTo(Duration(seconds: secondsStartPoint));
    } else if (_youtubePlayerController.value.position.inSeconds > secondsEndPoint) {
      _youtubePlayerController.seekTo(Duration(seconds: secondsEndPoint));
      _youtubePlayerController.pause();
      if (!dialogOnScreen) {
        dialogOnScreen = true;
        onEndedCallback(_youtubePlayerController.metadata);
      }
    }
  }

  // This callback shows dialog screen once lesson video is ended
  void onEndedCallback(YoutubeMetaData metaData) {
    setState(() {
      _youtubePlayerController.pause();
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Are you ready for quezze?"),
          actions: <Widget>[
            FlatButton(
              child: Icon(
                Icons.home,
                color: Colors.blue,
              ),
              onPressed: () {
                dialogOnScreen = false;
                db.addLessonToUserHistory(widget.lessonData);
                Navigator.pop(context);
                returnButton();
              },
            ),
            FlatButton(
              child: Icon(Icons.replay, color: Colors.blue),
              onPressed: () {
                dialogOnScreen = false;
                db.addLessonToUserHistory(widget.lessonData);
                Navigator.pop(context, true);
                _youtubePlayerController.seekTo(Duration(seconds: secondsStartPoint));
              },
            ),
            FlatButton(
              child: Text("Yes!"),
              onPressed: () {
                dialogOnScreen = false;
                db.addLessonToUserHistory(widget.lessonData);
                Navigator.pop(context);
                _youtubePlayerController.seekTo(Duration(seconds: secondsStartPoint));
                _youtubePlayerController.pause();
                proceedToQuestionsButton();
              },
            ),
          ],
        ),
      );
    });
  }

  void returnButton() {
    Navigator.pop(context);
  }

  void proceedToQuestionsButton() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserAmericanQuestionsScreen(
                  lessonDB: widget.lessonData,
                  title: "Questions",
                )));
  }

  // This function builds widget of video player screen
  Widget buildVideoPlayer() {
    return Center(
      child: _youtubePlayer,
    );
  }

  // This is a layout that shows initial screen with only button
  Widget buildInitialDialog() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              color: Colors.lightBlue,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              child: Text(
                "Let's start! (${_start})",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              onPressed: () {
                setState(() {
                  passedInitialDialog = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

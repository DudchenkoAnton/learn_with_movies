import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/screens/UserChooseLesson.dart';
import 'package:temp_project/screens/user_questions_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../database/database_utilities.dart';
import 'user_american_questions_screen.dart';

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
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_youtubePlayerController != null) _youtubePlayerController.dispose();
    super.dispose();
  }

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
    // TODO: Write code for going to questions screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserAmericanQuestionsScreen(
                  lessonDB: widget.lessonData,
                  title: "Questions",
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: Center(
            child: _youtubePlayer,
          ),
        ));
  }

  Widget generateLessonScreen(Orientation orientation) {
//    OrientationBuilder(
//      builder: (context, orientation) {
//        if (orientation == Orientation.landscape) {
//          return generateLessonScreen(orientation);
//        } else {
//          return generateLessonScreen(orientation);
//        }
//      },
//    )

//    if (firstBuild) {
//      firstBuild = false;
//      currentOrientation = orientation;
//    } else if (orientation != currentOrientation) {
//      print('INSIDE THE CHANGE OF ORIENTATION MODE!!!!!+++++++++--------');
//      currentOrientation = orientation;
//      Duration currentDuration = _youtubePlayerController.value.position;
//      _youtubePlayerController = YoutubePlayerController(initialVideoId: widget.lessonData.videoID);
//      _youtubePlayerController.seekTo(currentDuration);
//      _youtubePlayerController.addListener(playSelectedSegmentListener);
//    }

    return Container(
        child: Center(
      child: _youtubePlayer,
    ));
  }
}

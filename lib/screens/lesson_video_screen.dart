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
  YoutubePlayerController _youtubePlayerController;
  DatabaseUtilities db = new DatabaseUtilities();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _youtubePlayerController = YoutubePlayerController(initialVideoId: widget.lessonData.videoID);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_youtubePlayerController != null) _youtubePlayerController.dispose();
    super.dispose();
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
        child: YoutubePlayer(
          controller: _youtubePlayerController,
          showVideoProgressIndicator: true,
          onReady: () {
            print('Player is ready.');
          },
          onEnded: (YoutubeMetaData metaData) {
            setState(() {
              _youtubePlayerController.pause();
              showDialog(
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
                        Navigator.pop(context);
                        returnButton();
                      },
                    ),
                    FlatButton(
                      child: Icon(Icons.replay, color: Colors.blue),
                      onPressed: () {
                        db.addLessonToUserHistory(widget.lessonData);
                        Navigator.pop(context, true);
                        _youtubePlayerController.seekTo(Duration(seconds: widget.lessonData.getVideoStartPoint()));
                      },
                    ),
                    FlatButton(
                      child: Text("Yes!"),
                      onPressed: () {
                        Navigator.pop(context);
                        _youtubePlayerController.seekTo(Duration(seconds: widget.lessonData.getVideoStartPoint()));
                        _youtubePlayerController.pause();
                        proceedToQuestionsButton();
                      },
                    ),
                  ],
                ),
              );
            });
          },
        ),
      )),
    );
  }
}

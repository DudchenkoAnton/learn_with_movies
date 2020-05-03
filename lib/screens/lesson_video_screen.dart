import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/screens/user_questions_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _youtubePlayerController = YoutubePlayerController(
        initialVideoId: widget.lessonData.videoID, flags: YoutubePlayerFlags());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _youtubePlayerController.dispose();
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
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Are you ready for quezze?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.pop(context);
                        returnButton();
                      },
                    ),
                    FlatButton(
                      child: Text("Yes!"),
                      onPressed: () {
                        Navigator.pop(context);
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

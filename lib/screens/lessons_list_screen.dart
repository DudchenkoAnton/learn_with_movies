import 'package:flutter/material.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/components/lesson_card.dart';
import 'package:temp_project/screens/video_creator_screen.dart';

class LessonsListScreen extends StatefulWidget {
  static const String id = 'lessons_list_screen';
  List<LessonData> card = [];
  @override
  _LessonsListScreenState createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  //list of all the cards

  @override
  Widget build(BuildContext context) {
    Widget cardTemplate(videoObject, delete, edit) {
      return new card_movie(videoObject, delete, edit);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson'),
        centerTitle: true,
      ),
      body: Column(
        //show all the card in the list of card
        children: widget.card
            .map((Video) => cardTemplate(Video, () {
                  setState(() {
                    widget.card.remove(Video);
                  });
                }, () {
                  setState(() {
                    edit_card(context, Video);
                  });
                }))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          add_card(context);
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  void edit_card(BuildContext context, videoObject) async {
    videoObject = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoCreatorScreen(
                  videoData: videoObject,
                )));
    setState(() {
      videoObject;
    });
  }

  void add_card(BuildContext context) async {
    final video_new = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => VideoCreatorScreen()));
    if (video_new != null) {
      setState(() {
        ////here we need to call your screen and the data you return should be CardObject object
        widget.card.add(video_new);
      });
    }
  }
}

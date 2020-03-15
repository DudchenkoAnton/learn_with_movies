import 'package:flutter/material.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/components/lesson_card.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:temp_project/database/question_db.dart';

import 'package:temp_project/screens/video_creator_screen.dart';

class LessonsListScreen  extends StatefulWidget{
  static const String id = 'lessons_list_screen';

   @override
  _LessonsListScreenState  createState()=> _LessonsListScreenState ();

}
class _LessonsListScreenState  extends State<LessonsListScreen>{
  //the search of a word
  DatabaseUtilities db = new DatabaseUtilities();
  var _searceView=new TextEditingController();
  List<LessonDB> all_lesson = List<LessonDB>();

  @override
  void initState(){
    _getThingsOnStartup().then((value){
    });
    super.initState();

  }

  Future _getThingsOnStartup() async {
    List<LessonDB> list = await db.getLessonsFromDB();
    all_lesson.clear();
    all_lesson.addAll(list);
    setState(() {
      build(context);
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<LessonDB> dummyListData = List<LessonDB>();
      all_lesson.forEach((item) {
        if (item.getMainVideoName().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        all_lesson.clear();
        all_lesson.addAll(dummyListData);
      });
      return;
    } else {
      setState(() async{
        all_lesson.clear();
        all_lesson.addAll(await db.getLessonsFromDB());
      });
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Create Lesson with movies"),
      ),
      body: Container(
         margin: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
         child:Column(
           children: <Widget>[
             _createSearchView(),
             _CardView(),
           ],
         )
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





  Widget _CardView(){
    return new Column(
      //show all the card in the list of card
      children: all_lesson.map((lesson_object) => new card_movie(lesson_object, () {
        setState(() {
          all_lesson.remove(lesson_object);
        });
      }, () {
        setState(() {
          edit_card(context, lesson_object);
        });
      }))
          .toList(),
    );
  }



  void edit_card(BuildContext context, lesson_object) async {
    lesson_object = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoCreatorScreen(videoData: lesson_object,)
        ));
    setState(() {
      lesson_object;
    });
  }
  Widget _createSearchView(){
    return new Container(
        child:
        TextField(
          onChanged: (value) {
            filterSearchResults(value);
          },
          controller: _searceView,
          decoration: InputDecoration(
              labelText: "Search",
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)))),
     ),
    );
  }


  void add_card(BuildContext context) async {
    final lesson_new = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => VideoCreatorScreen()));
    if (lesson_new != null) {
      setState(() {
        //lesson_new need to by from the shape of LessonDB
        all_lesson.add(lesson_new);
      });
    }
  }
}


import 'package:flutter/material.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/components/lesson_card.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:temp_project/screens/video_creator_screen.dart';

class LessonsListScreen  extends StatefulWidget{
  static const String id = 'lessons_list_screen';

   @override
  _LessonsListScreenState  createState()=> _LessonsListScreenState ();

}
class _LessonsListScreenState  extends State<LessonsListScreen>{
  //the search of a word
  DatabaseUtilities db;
  var _searceView=new TextEditingController();
  List<LessonDB> all_lesson;
  ProgressDialog pr;


  @override
  void initState() {
    super.initState();
    db = new DatabaseUtilities();

    LessonDB l1 = new LessonDB("rrr", "ttt", "fff bbb",
        2.34, 5.32, ["uouou", "oioio", "opopo"]);
    l1.addQuestion(
        new QuestionDB("https://www.youtube.com/watch?v=xHcPhdZBngw",
            "Some question ?",
            "Some answer",
            6.19,
            7.20)
    );

    l1.addQuestion(
        new QuestionDB("https://www.youtube.com/watch?v=xHcPhdZBngw",
            "Some question 2 ?",
            "Some answer 2",
            9.33,
            11.56)
    );

    db.addLessonToDB(l1);
    _lessonGetDB();
  }
  Future _lessonGetDB() async{
    List<LessonDB> lessonTemp=new List();
    lessonTemp= await db.getLessonsFromDB();

    setState(() {
      all_lesson=lessonTemp;
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
      setState(() {
        all_lesson.clear();
       // all_lesson.addAll(db.getLessonsFromDB());
      });
    }
  }


  @override
  Widget build(BuildContext context){
    pr = new ProgressDialog(context);
    pr.style(
        message: 'Please Waiting...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Create Lesson with movies"),
      ),
      body:
      Container(
         margin: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
         child:Column(
           children: <Widget>[
             _createSearchView(),
             //_waiting(),
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


  Widget _waiting(){
    return new Scaffold(
    body: Center(child: RaisedButton(
        child: Text('Show dialog and go to next screen',
            style: TextStyle(color: Colors.white)),
        color: Colors.blueAccent,
        onPressed: () {
  pr.show();
  Future.delayed(Duration(seconds: 3)).then((value) {
  pr.hide().whenComplete(() {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (BuildContext context) => VideoCreatorScreen()));},
  );
  }
  );
  }
  )
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


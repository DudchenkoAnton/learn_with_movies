import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:temp_project/screens/video_creator_screen.dart';

class LessonsListScreen extends StatefulWidget {
  static const String id = 'lessons_list_screen';

  @override
  _LessonsListScreenState createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  //the search of a word
  DatabaseUtilities db = new DatabaseUtilities();
  var _searchView = new TextEditingController();
  List<LessonDB> allLesson = List<LessonDB>();
  var animationOn = true;

  @override
  void initState() {
    _getThingsOnStartup().then((value) {});
    super.initState();
  }

  Future _getThingsOnStartup() async {
    List<LessonDB> list = await db.getLessonsFromDB();
    allLesson.clear();
    allLesson.addAll(list);
    animationOn = false;
    setState(() {
      build(context);
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<LessonDB> dummyListData = List<LessonDB>();
      allLesson.forEach((item) {
        if (item.getLessonName().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        allLesson.clear();
        allLesson.addAll(dummyListData);
      });
      return;
    } else {
      setState(() async {
        _getThingsOnStartup().then((value) {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Create Lesson with movies"),
      ),
      body: Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0,),
              _createSearchView(),
              SizedBox(height: 8.0,),
              animationOn ? create_animation() : _LessonView(context),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          add_card(context);
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
  String url_image(youtubeUrl) {
    Uri uri = Uri.parse(youtubeUrl);
    String videoID = uri.queryParameters["v"];
    String url = "http://img.youtube.com/vi/" + videoID + "/0.jpg";
    return url;
  }


  Widget _LessonView(context){
    return
      Container(
        child:  ListView.separated(
          shrinkWrap: true,
        itemBuilder: (context,index){
          return Row(
            children: <Widget>[
              Container(
                  width: 140.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(url_image(allLesson[index].videoURL))
                          ,fit: BoxFit.cover)
                  ),
                ),
              Column(
              children: <Widget>[
              Container(
               width: MediaQuery.of(context).size.width-200.0,
                height: 70.0,
                child: ListTile(
                  title: Text(allLesson[index].getLessonName()),
                  subtitle: Text(allLesson[index].getVideoLenght() + ' min'),
                ),
              ),
                     Row(
                        children: <Widget>[
                          IconButton(
          onPressed: ()=>setState(() {
          edit_card(context, allLesson[index]);
          }),
          icon: Icon(Icons.edit),
          ),
          IconButton(
          onPressed: ()=> setState(() {
          delete_card(context, allLesson[index]);
          }),
          icon: Icon(Icons.delete),
          ),
          ],
                     )]),
            ],
          );
        },
        separatorBuilder: (context,index)=>Divider(
          height: 4.0,
          color: Colors.grey,
        ),
        itemCount: allLesson.length),
      );
  }

  void delete_card(BuildContext context, lesson_object) async {
    if (await db.deleteLessonFromDB(lesson_object)) {
      allLesson.remove(lesson_object);
    }
  }

  Widget create_animation() {
    return Container(
      color: Colors.grey[50],
      width: 300.0,
      height: 300.0,
      child: SpinKitFadingCircle(
        itemBuilder: (_, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
        size: 120.0,
      ),
    );
  }

  void edit_card(BuildContext context, lesson_object) async {
    lesson_object = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoCreatorScreen(
                  videoData: lesson_object,
                )));
    setState(() {
      lesson_object;
    });
  }

  Widget _createSearchView() {
    return new Container(
      child: TextField(
        onChanged: (value) {
          filterSearchResults(value);
        },
        controller: _searchView,
        decoration: InputDecoration(
            labelText: "Search",
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(22.0)))),
      ),
    );
  }

  void add_card(BuildContext context) async {
    final lesson_new = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => VideoCreatorScreen()));
    if (lesson_new != null) {
      setState(() {
        //lesson_new need to by from the shape of LessonDB
        allLesson.insert(0, lesson_new);
       // allLesson.add(lesson_new);
      });
    }
  }
}

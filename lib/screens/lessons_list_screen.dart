import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:temp_project/screens/video_creator_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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
  bool endOfList = false;
  ScrollController _scrollController;
  Lock lock = new Lock();
  List<String> categories = [];
  bool showSpinner = false;

  @override
  void initState() {
    _getThingsOnStartup().then((value) {});
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  Future _getThingsOnStartup() async {
    List<LessonDB> list = await db.getFirstUserLessonsChunk("averageRating", categories);
    List<LessonDB> listDraft = await db.getDraftsFromDB();
    allLesson.clear();
    allLesson.addAll(listDraft);
    allLesson.addAll(list);
    animationOn = false;
    setState(() {
      build(context);
    });
  }

  void filterSearchResults(String query) async {
    if (query.isNotEmpty) {
      List<LessonDB> dummyListData = List<LessonDB>();
      setState(() {
        showSpinner = true;
      });
      //////change the search for only movies that the user create
      dummyListData = await db.searchUserLessonsFirstChunk(query, []);
      setState(() {
        showSpinner = false;
      });
      setState(() {
        allLesson.clear();
        allLesson.addAll(dummyListData);
      });
    } else {
      setState(() async {
        setState(() {
          showSpinner = true;
        });
        _getThingsOnStartup().then((value) {});
        setState(() {
          showSpinner = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Create My Lessons"),
      ),
      body: Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 8.0,
              ),
              _createSearchView(),
              SizedBox(
                height: 8.0,
              ),
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

  Widget _LessonView(context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshAllVideos,
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == allLesson.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Row(
                  children: <Widget>[
                    Container(
                      width: 140.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(url_image(allLesson[index].videoURL)), fit: BoxFit.cover)),
                    ),
                    Column(children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 200.0,
                        height: 70.0,
                        child: ListTile(
                          title: Text(allLesson[index].getLessonName()),
                          subtitle: Text(allLesson[index].getVideoLenght() + ' min'),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () => setState(() {
                              edit_card(context, allLesson[index]);
                            }),
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => setState(() {
                              if (allLesson[index].isDraft) {
                                delete_card_draft(context, allLesson[index]);
                              } else {
                                delete_card(context, allLesson[index]);
                              }
                            }),
                            icon: Icon(Icons.delete),
                          ),
                          allLesson[index].isDraft ? Icon(Icons.build, color: Colors.purpleAccent) : Container(),
                        ],
                      )
                    ]),
                  ],
                );
              },
              separatorBuilder: (context, index) => Divider(
                    height: 4.0,
                    color: Colors.grey,
                  ),
              itemCount: (!endOfList && allLesson.length > 4) ? allLesson.length + 1 : allLesson.length),
        ),
      ),
    );
  }

  void delete_card(BuildContext context, lesson_object) async {
    if (await db.deleteLessonFromDB(lesson_object)) {
      allLesson.remove(lesson_object);
    }
  }

  void delete_card_draft(BuildContext context, lesson_object) async {
    if (await db.deleteDraftFromDB(lesson_object)) {
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
              color: index.isEven ? Colors.blueAccent : Colors.white,
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
            labelText: "Search my lessons",
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(22.0)))),
      ),
    );
  }

  void add_card(BuildContext context) async {
    final lesson_new = await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCreatorScreen()));
    if (lesson_new != null) {
      setState(() {
        refreshAllVideos();
        //allLesson.insert(0, lesson_new);
      });
    }
  }

  void _scrollListener() async {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // TODO: add to here pagination function invocation
      await lock.synchronized(() async {
        print(' --------------REACHED THE END OF THE LIST ----------');
        List<LessonDB> list = await db.getNextUserLessonsChunk('averageRating', categories);
        if (list.length > 0) {
          setState(() {
            allLesson.addAll(list);
          });
        } else {
          setState(() {
            endOfList = true;
          });
        }
      });
    }
  }

  Future<void> refreshAllVideos() async {
    List<LessonDB> list = await db.getFirstUserLessonsChunk("averageRating", categories);
    List<LessonDB> draftList = await db.getDraftsFromDB();
    setState(() {
      allLesson.clear();
      allLesson.addAll(draftList);
      allLesson.addAll(list);
      endOfList = false;
    });
  }
}

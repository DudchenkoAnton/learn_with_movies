import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:synchronized/synchronized.dart';
import 'package:temp_project/components/side_menu.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:temp_project/screens/lesson_video_screen.dart';
import 'package:temp_project/database/auth.dart';
import 'package:temp_project/utilites/constants.dart';
import '../database/database_utilities.dart';
import '../database/database_utilities.dart';
import '../database/database_utilities.dart';
import '../database/database_utilities.dart';

class BodyBestMovie extends StatefulWidget {
  @override
  _BodyBestMovieState createState() => _BodyBestMovieState();
}

class _BodyBestMovieState extends State<BodyBestMovie> {
  DatabaseUtilities db = new DatabaseUtilities();
  final AuthService _auth = AuthService();
  var _searchView = new TextEditingController();
  List<LessonDB> allLesson = List<LessonDB>();
  var animationOn = true;
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text("Learn With Movies");
  List<String> labels = ['All','Medicine', 'Law', 'Entertainment', 'Sport', 'History', 'Music'];
  bool prase = false;
  ScrollController _scrollController;
  ScrollController _scrollController_2;
  bool endOfList = false;
  Lock lock = new Lock();
  List<String> categories = [];
  bool change_category = false;
  List<String> moviesSeen = [];
  bool showSpinner=false;


  @override
  void initState() {
    _getLessonsHistory();
    _getThingsOnStartup().then((value) {});
    _scrollController = ScrollController();
    _scrollController_2=ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  Future _getLessonsHistory() async {
    //pull the id movies of the movies seen to the list -moviesSeen
    moviesSeen = await db.getWatchedLessonIDs();
  }

  Future _getThingsOnStartup() async {
    List<LessonDB> list = await db.getFirstLessonsChunk("averageRating", categories);
    allLesson.clear();
    allLesson.addAll(list);
    animationOn = false;
    setState(() {
      build(context);
    });
  }

  void filterSearchResults(String query) async{
    if (query.isNotEmpty) {
      List<LessonDB> dummyListData = List<LessonDB>();
      setState(() {
        showSpinner=true;
      });
      dummyListData=await db.searchLessonsFirstChunk(query,[]);
      setState(() {
        showSpinner=false;
      });
      setState(() {
        allLesson.clear();
        allLesson.addAll(dummyListData);
      });

    } else {

      setState(() async{
        setState(() {
          showSpinner=true;
        });
        await refreshAllVideos();
        setState(() {
          showSpinner=false;
        });

      });
    }
  }

  Widget appBarWidget() {
    return AppBar(
      actions: <Widget>[
        IconButton(
          onPressed: () {
            setState(() {
              searchAction();
            });
          },
          icon: cusIcon,
        ),
      ],
      centerTitle: true,
      title: cusSearchBar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(),
      drawer: SideMenu(),
      body: animationOn ? create_animation() : _CardViewCheck(context),
      //_CardView(context),
    );
  }

  void searchAction() {
    if (this.cusIcon.icon == Icons.search) {
      this.cusIcon = Icon(Icons.clear);
      this.cusSearchBar =TextField(
        onChanged: (value) {
          filterSearchResults(value);
        },
        controller: _searchView,
        textInputAction: TextInputAction.go,
        decoration: InputDecoration(
          hintText: "Search Movie",
          hintStyle: TextStyle(
            color: Colors.black26,
          ),
          border: UnderlineInputBorder(),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    } else {
      this.cusIcon = Icon(Icons.search);
      this.cusSearchBar = Text("Learn With Movies");
      _searchView.clear();
      filterSearchResults("");
    }
  }




  bool _visible(index) {
    if (allLesson[index].averageRating == null) {
      return false;
    }
    return true;
  }

  List<int> generateNumbers() => List<int>.generate(labels.length, (i) => i + 1);
  List<Color> colorButton = [
    Colors.yellow[700],
    Colors.pink,
    Colors.deepPurpleAccent,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.purpleAccent
  ];
  List<Color> colorRangeButton = [Colors.grey[700],Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white];
  List<bool> isPress = [true,false, false, false, false, false, false];

  Widget _CardViewCheck(context) {
    return ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController_2,
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                    itemCount: labels.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 20.0,
                          margin: const EdgeInsets.all(5.0),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: colorRangeButton[index]),
                            ),
                            color: colorButton[index],
                            child: Center(
                              child: Text(
                                labels[index],
                                style: TextStyle(color: Colors.white, fontSize: 13.0),
                              ),
                            ),
                            onPressed: () async {
                              if (!isPress[index]) {
                                //the button is on
                                setState(() {
                                  if (isPress.contains(true)) {
                                    int index_last_press = isPress.indexOf(true);
                                    isPress[index_last_press] = false;
                                    colorRangeButton[index_last_press] = Colors.white;
                                  }
                                  colorRangeButton[index] = Colors.grey[700];
                                  categories.clear();
                                  if (labels[index]!='All') {
                                    categories.add(labels[index]);
                                  }
                                  isPress[index] = true;
                                  change_category = true;
                                });
                                await refreshAllVideos();
                                setState(() {
                                  if (categories.isEmpty){
                                    isPress[index]=false;
                                    isPress[0]=true;
                                    colorRangeButton[index] = Colors.white;
                                    colorRangeButton[0] = Colors.grey[700];

                                  }
                                  change_category = false;
                                });
                              } else if (isPress[index]) {
                                if (labels[index]!='All') {
                                  //the button is off!
                                  setState(() {
                                    colorRangeButton[index] = Colors.white;
                                    colorRangeButton[0]=Colors.grey[700];
                                    categories.remove(labels[index]);
                                    isPress[index] = false;
                                    isPress[0] = true;
                                    change_category = true;
                                  });
                                  await refreshAllVideos();
                                  setState(() {
                                    change_category = false;
                                  });
                                }
                              }
                            },
                          ));
                    }),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 200.0,
                width: MediaQuery.of(context).size.width,
                child: RefreshIndicator(
                  onRefresh: refreshAllVideos,
                  child: ModalProgressHUD(
                    inAsyncCall: change_category,
                    child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index == allLesson.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          return Column(
                            children: <Widget>[
                              SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  move_screen(context, index);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 10.0,
                                  height: 200.0,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(url_image(allLesson[index].videoURL)),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                              ListTile(
                                title: Text(allLesson[index].lessonName),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text("${allLesson[index].getVideoLenght()} min"),
                                        Visibility(
                                            child: Row(
                                              children: <Widget>[
                                                Text(",  Rating: ${rating_print(allLesson[index].averageRating)}  "),
                                                Icon(
                                                  Icons.star,
                                                  size: 15.0,
                                                ),
                                              ],
                                            ),
                                            visible: _visible(index)),
                                      ],
                                    ),
                                    userSeeMovie(allLesson[index].getDBReference())
                                        ? Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 25.0,
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) => Divider(
                              height: 1.0,
                              color: Colors.grey,
                            ),
                        itemCount: (!endOfList && allLesson.length > 4) ? allLesson.length + 1 : allLesson.length),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  void move_screen(BuildContext context, int index) async {
    ///change the name of the screen and send the lesson!
    print('This is a video id - ${allLesson[index].videoID}');
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LessonVideoScreen(
                  lessonData: allLesson[index],
                )));
  }

  String url_image(youtubeUrl) {
    Uri uri = Uri.parse(youtubeUrl);
    String videoID = uri.queryParameters["v"];
    String url = "http://img.youtube.com/vi/" + videoID + "/0.jpg";
    return url;
  }

  Widget create_animation() {
    return Container(
      color: Colors.grey[50],
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
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

  bool userSeeMovie(String id) {
    if (moviesSeen.contains(id)) {
      return true;
    }
    return false;
  }



  void _scrollListener() async {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // TODO: add to here pagination function invocation
      await lock.synchronized(() async {
        print(' --------------REACHED THE END OF THE LIST ----------');
        List<LessonDB> list = await db.getNextLessonsChunk('averageRating', categories);
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
    List<LessonDB> list = await db.getFirstLessonsChunk("averageRating", categories);
    if (list.isEmpty &  categories.isNotEmpty){
      categories.clear();
      list = await db.getFirstLessonsChunk("averageRating", categories);
    }
    setState(() {
      allLesson.clear();
      allLesson.addAll(list);
      endOfList = false;
    });
  }
}

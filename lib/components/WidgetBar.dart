import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'package:temp_project/screens/lesson_video_screen.dart';
import 'package:temp_project/database/auth.dart';


class WidgetBar extends StatefulWidget {
  final String show;
  WidgetBar({Key key, this.show}) : super(key: key);

  @override
  _WidgetBarState createState() => _WidgetBarState();
}

class _WidgetBarState extends State<WidgetBar>{

  DatabaseUtilities db = new DatabaseUtilities();
  final AuthService _auth=AuthService();
  var _searchView = new TextEditingController();
  List<LessonDB> allLesson = List<LessonDB>();
  var animationOn = true;
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text("Learn With Movies");

  @override
  void initState() {
    _getThingsOnStartup(this.widget.show).then((value) {});
    super.initState();
  }

  Future _getThingsOnStartup(show) async {
    print(show);
    List<LessonDB> list = await db.getLessonsFromDB();
    allLesson.clear();
    //sort the element by rating
    if (show=="Best Movies"){
      list.sort((b,a)=>a.getAverageRatingInt().compareTo(b.getAverageRatingInt()));
    }
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
      } else {
          setState(() {
            _getThingsOnStartup(this.widget.show).then((value) {});
         });
    }
  }


  Widget appBarWidget(){
    return AppBar(
      leading: IconButton(onPressed: () {setState(() {searchAction();});
      },
        icon: cusIcon,
      ),
      centerTitle: true,
      title: cusSearchBar,
      actions: <Widget>[IconButton(
        onPressed: ()async{
          await _auth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(emailReset: "",)));

        },
        icon: Icon(Icons.person,color: Colors.white,),
      )
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(),
      body: animationOn ? create_animation() : _CardView(context),
    );
  }

  void searchAction() {
    if (this.cusIcon.icon == Icons.search) {
      this.cusIcon = Icon(Icons.clear);
      this.cusSearchBar = TextField(
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
      filterSearchResults("");
    }
  }

  bool _visible(index){
    if(allLesson[index].averageRating==null){
      return false;
    }
    return true;
  }


  Widget _CardView(context) {
    return ListView.separated(
        itemBuilder: (context, index) {
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
                          image: NetworkImage(
                              url_image(allLesson[index].videoURL)),
                          fit: BoxFit.cover)),
                ),
              ),
              ListTile(
                title: Text(allLesson[index].lessonName),
                subtitle: Row(
                    children: <Widget>[
                      Text("${allLesson[index].getVideoLenght()} min"),
                      Visibility(
                        child: Row(
                          children: <Widget>[
                            Text(",  Rating: ${allLesson[index].averageRating}  "),
                            Icon(Icons.star,size: 15.0,),
                          ],
                        ),
                        visible: _visible(index)
                      )

               ]
              ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(
              height: 1.0,
              color: Colors.grey,
            ),
        itemCount: allLesson.length);
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

}

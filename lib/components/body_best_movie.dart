import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:temp_project/components/side_menu.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:temp_project/screens/lesson_video_screen.dart';
import 'package:temp_project/database/auth.dart';


class BodyBestMovie extends StatefulWidget {
  @override
  _BodyBestMovieState createState() => _BodyBestMovieState();
}

class _BodyBestMovieState extends State<BodyBestMovie>{

  DatabaseUtilities db = new DatabaseUtilities();
  final AuthService _auth=AuthService();
  var _searchView = new TextEditingController();
  List<LessonDB> allLesson = List<LessonDB>();
  var animationOn = true;
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text("Learn With Movies");
  List<String> labels=['Medicine', 'Law', 'Entertainment', 'Sport', 'History'];
  bool prase=false;
  @override
  void initState() {
    _getThingsOnStartup().then((value) {});
    super.initState();
  }

  Future _getThingsOnStartup() async {
    List<LessonDB> list = await db.getLessonsFromDB();
    allLesson.clear();
    //sort the element by rating
    list.sort((b,a)=>a.getAverageRatingInt().compareTo(b.getAverageRatingInt()));
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
            _getThingsOnStartup().then((value) {});
         });
    }
  }


  Widget appBarWidget(){
    return AppBar(
      actions:<Widget>[IconButton(onPressed: () {setState(() {searchAction();});
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
      appBar: appBarWidget(),drawer: SideMenu(),

      body: animationOn ? create_animation() : _CardViewCheck(context),
      //_CardView(context),
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



  List<int> generateNumbers() => List<int>.generate(labels.length, (i) => i + 1);
  List<Color> colorButton=[Colors.pink,Colors.deepPurpleAccent,Colors.cyan,Colors.deepOrange,Colors.lightGreen];
  List<Color> colorRangeButton=[Colors.white,Colors.white,Colors.white,Colors.white,Colors.white];
  List<bool> isPress=[false,false,false,false,false];

  Widget _CardViewCheck(context){
    return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 110,
                  child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: labels.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 3,childAspectRatio: MediaQuery.of(context).size.width /
                      (600 / 4),
                  ),
                      itemBuilder: (context,index){
                      return Container(
                          width: MediaQuery.of(context).size.width/4,
                        height: 20.0,
                        margin: const EdgeInsets.all(7.0),
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(width: 3,color: colorRangeButton[index],style: BorderStyle.solid),

                        ),
                        child:RaisedButton(
                      color: colorButton[index],
                      child: Center(child:Text(labels[index],style: TextStyle(color: Colors.white,fontSize: 13.0),),),
                        onPressed: (){
                            if(!isPress[index] && !isPress.contains(true)) {
                            //the button is on!


                                setState(() {
                                  colorRangeButton[index]=Colors.black;
                                  isPress[index]=true;
                              });
                            }
                            else if(isPress[index]){
                              //the button is off!
                              setState(() {
                                colorRangeButton[index]=Colors.white;
                                isPress[index]=false;
                              });
                            }
                        },
                      )
                      );
                    }
                    ),
                ),
                Container(
                    height:MediaQuery.of(context).size.height-200.0,
                    child: ListView.separated(
                        scrollDirection: Axis.vertical,
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
                        itemCount: allLesson.length)
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _CardView(context) {
    return Container(
        child: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Container(
            height: 150.0,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: <Widget>[
                    GestureDetector(
                      onTap:(){
                        //sort it by the "Medicine"
                      },
                      child:Container(
                        width: MediaQuery.of(context).size.width/4,
                        height: 50.0,
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color:Colors.orangeAccent ,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(width: 3,color: Colors.orangeAccent,style: BorderStyle.solid),

                        ),
                        child:Center(child:Text("Medicine",style: TextStyle(color: Colors.white,fontSize: 15.0),),),
                      ),
                    ),
                    GestureDetector(
                      onTap:(){
                        //sort it by the "Law"
                      },
                      child:Container(
                        width: MediaQuery.of(context).size.width/4,
                        height: 50.0,
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color:Colors.deepPurpleAccent ,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(width: 3,color: Colors.deepPurpleAccent,style: BorderStyle.solid),

                        ),
                        child:Center(child:Text("Law",style: TextStyle(color: Colors.white,fontSize: 15.0),),),
                      ),
                    ),
                    GestureDetector(
                      onTap:(){
                        //sort it by the "Entertainment"
                      },
                      child:Container(
                        width: MediaQuery.of(context).size.width/4,
                        height: 50.0,
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color:Colors.cyan ,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(width: 3,color: Colors.cyan,style: BorderStyle.solid),

                        ),
                        child:Center(child:Text("Entertainment",style: TextStyle(color: Colors.white,fontSize: 15.0),),),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      child: Center(child:Text("Sport",style: TextStyle(color: Colors.white,fontSize: 15.0),),),
                      onPressed: (){
                        if (!prase){
                          setState(() {
                            prase=true;

                          });
                        }
                      },
                    ),




                    GestureDetector(
                      onTap:(){
                        //sort it by the "Entertainment"
                      },
                      child:Container(
                        width: MediaQuery.of(context).size.width/4,
                        height: 50.0,
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color:Colors.amberAccent ,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(width: 3,color: Colors.amberAccent,style: BorderStyle.solid),

                        ),
                        child:Center(child:Text("Sport",style: TextStyle(color: Colors.white,fontSize: 15.0),),),
                      ),
                    ),
                    GestureDetector(
                      onTap:(){
                        //sort it by the "Entertainment"
                      },
                      child:Container(
                        width: MediaQuery.of(context).size.width/4,
                        height: 50.0,
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color:Colors.greenAccent ,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(width: 3,color: Colors.greenAccent,style: BorderStyle.solid),

                        ),
                        child:Center(child:Text("History",style: TextStyle(color: Colors.white,fontSize: 15.0),),),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ),
          Container(
        height:MediaQuery.of(context).size.height-150.0,
        child: ListView.separated(
        scrollDirection: Axis.vertical,
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
        itemCount: allLesson.length)
          ),
          ],
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

}

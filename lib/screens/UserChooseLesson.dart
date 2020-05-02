import 'package:flutter/material.dart';
import 'package:temp_project/components/WidgetBar.dart';
class UserChooseLesson extends StatefulWidget {
  static const String id = 'user_choose_lesson_screen';

  @override
  _UserChooseLessonState createState() => _UserChooseLessonState();
}
class _UserChooseLessonState extends State<UserChooseLesson> {
  int _currentIndex = 0;


  final List<Widget> _children = [
   new WidgetBar(show: "Home",),
   new WidgetBar(show: "Best Movies",),
    new WidgetBar(show: "History",),
  ];



  PageController pageController = PageController();

  void onTabTapped(int index) {
    pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

/*
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      print(_currentIndex);
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // body: _children.elementAt(_currentIndex), // new

     body: PageView(
         controller: pageController,
         onPageChanged: _onPageChanged,
         children: _children,),

      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.star_border),
            title: new Text('Best Movies'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              title: Text('History'))
        ],
      ),
    );
  }
}

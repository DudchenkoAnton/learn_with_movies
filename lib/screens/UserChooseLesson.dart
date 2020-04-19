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
    WidgetBar(
      show: "home",
    ),
    WidgetBar(
      show: "Best Movies",
    ),
    WidgetBar(show: "History"),
  ];

  @override
  void initState() {
    super.initState();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex], // new
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
              icon: Icon(Icons.bookmark_border), title: Text('History'))
        ],
      ),
    );
  }
}

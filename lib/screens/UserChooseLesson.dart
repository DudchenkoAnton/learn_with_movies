import 'package:flutter/material.dart';
import 'package:temp_project/components/body_best_movie.dart';
import 'package:temp_project/components/body_history.dart';
import 'package:temp_project/components/side_menu.dart';
class UserChooseLesson extends StatefulWidget {
  static const String id = 'user_choose_lesson_screen';

  @override
  _UserChooseLessonState createState() => _UserChooseLessonState();
}
class _UserChooseLessonState extends State<UserChooseLesson> {
  int _currentIndex = 0;


  final List<Widget> _children = [
    new BodyBestMovie(),
    new BodyHistory(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
         controller: pageController,
         onPageChanged: _onPageChanged,
         children: _children,),

      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
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

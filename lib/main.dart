import 'package:flutter/material.dart';
import 'package:temp_project/screens/OpenScreenLogo.dart';
import 'package:temp_project/screens/lesson_video_screen.dart';
import 'package:temp_project/screens/lessons_list_screen.dart';
import 'package:temp_project/screens/video_creator_screen.dart';
import 'package:temp_project/screens/UserChooseLesson.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'screens/lessons_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LessonsListScreen.id,
      routes: {
        VideoCreatorScreen.id: (context) => VideoCreatorScreen(),
        UserChooseLesson.id: (context) => UserChooseLesson(),
        LessonsListScreen.id: (context) => LessonsListScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        OpenScreenLogo.id: (context) => OpenScreenLogo(),
      },
    );
  }
}

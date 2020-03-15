import 'package:flutter/material.dart';
import 'package:temp_project/screens/lessons_list_screen.dart';
import 'package:temp_project/screens/video_creator_screen.dart';
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
        LessonsListScreen.id: (context) => LessonsListScreen(),
      },
    );
  }
}

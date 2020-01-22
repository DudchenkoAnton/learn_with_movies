import 'dart:math';

import 'package:flutter/material.dart';

class QuestionData {
  QuestionData(
      {this.question, this.answer, this.start, this.end, this.videoId});
  String question;
  String answer;
  Duration start;
  Duration end;
  String videoId;
}

class LessonData {
  LessonData(
      {this.url,
      this.questions,
      this.name,
      this.start,
      this.end,
      this.categories,
      this.youtubeName});
  String videoId;
  String url;
  List<QuestionData> questions = [];
  String name;
  String youtubeName;
  Duration start;
  Duration end;
  List<String> categories = [];

  void printData() {
    print('Start debug printing:');
    print(name);
    print(url);
    print(start);
    print(end);
    print(categories);
    print(youtubeName);
  }
}

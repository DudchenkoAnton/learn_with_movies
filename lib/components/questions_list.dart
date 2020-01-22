import 'package:flutter/material.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/screens/question_creator_screen.dart';

class QuestionsList extends StatefulWidget {
  final LessonData videoData;
  QuestionsList({Key key, this.videoData}) : super(key: key);

  @override
  _QuestionsListState createState() => _QuestionsListState();
}

class _QuestionsListState extends State<QuestionsList> {
  List<QuestionData> questionsTemp;

  void addNewQuestion() async {
    var questionObject =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return QuestionCreatorScreen(videoData: widget.videoData);
    }));

    if (questionObject != null) {
      questionsTemp.add(questionObject);
    }
  }

  @override
  void initState() {
    super.initState();
    questionsTemp = widget.videoData.questions;
    print(questionsTemp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: Text(
              'Questions',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: List.generate(
                questionsTemp.length,
                (index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.lightBlue,
                        width: 1.0,
                      ),
                    ),
                    key: ValueKey('value${questionsTemp[index]}'),
                    child: ListTile(
                      title: Text('Question number - ${questionsTemp[index]}'),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewQuestion,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

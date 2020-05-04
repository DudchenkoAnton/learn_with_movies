import 'package:flutter/material.dart';
import 'rounded_icon_button.dart';

class QuestionDataContainer extends StatelessWidget {
  String numberOfQuestion;
  String questionText;
  String answerText;
  Function onEdit;
  Function onRemove;

  QuestionDataContainer(
      {@required this.questionText,
      @required this.answerText,
      @required this.onEdit,
      @required this.onRemove,
      @required this.numberOfQuestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[200],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: 5),
          Text(
            numberOfQuestion,
            style: TextStyle(
              fontSize: 40,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              children: <Widget>[
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: questionText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 10),
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: answerText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Container(
            height: 65.0,
            width: 2.0,
            color: Colors.grey[800],
            margin: const EdgeInsets.only(left: 5.0, right: 5.0),
          ),
          Container(
            width: 38,
            child: Column(
              children: <Widget>[
                RoundedIconButton(
                  width: 30,
                  height: 30,
                  icon: Icons.edit,
                  color: Colors.blueGrey[200],
                  onPressed: onEdit,
                ),
                RoundedIconButton(
                  width: 30,
                  height: 30,
                  icon: Icons.delete_forever,
                  color: Colors.blueGrey[200],
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//Expanded(
//child: Container(
//child: Text(
//questionText,
//style: TextStyle(fontSize: 15),
//),
//padding: EdgeInsets.only(left: 15)),
//flex: 2,
//),
//Expanded(
//child: Text(answerText, style: TextStyle(fontSize: 15)),
//flex: 2,
//),
//Row(children: <Widget>[
//RoundedIconButton(
//icon: Icons.edit,
//color: Colors.blueGrey[200],
//onPressed: onEdit,
//),
//RoundedIconButton(
//icon: Icons.delete_forever,
//color: Colors.blueGrey[200],
//onPressed: onRemove,
//),
//])

import 'package:flutter/material.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
// this class is how the card will look like

class card_movie extends StatefulWidget {
  LessonData videoObject;
  Function delete;
  Function edit;

  card_movie(card_o, delete_func, edit) {
    this.videoObject = card_o;
    this.delete = delete_func;
    this.edit = edit;
  }

  @override
  _card_movieState createState() => _card_movieState();
}

class _card_movieState extends State<card_movie> {
  String calc_time(int start, int end) {
    int res = end - start;
    return res.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.videoObject.name,
              style: TextStyle(fontSize: 20.0, color: Colors.grey),
            ),
            SizedBox(
              height: 6.0,
            ),
            Text(
              widget.videoObject.url,
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            SizedBox(
              height: 6.0,
            ),
            Text(
              calc_time(widget.videoObject.start.inSeconds,
                  widget.videoObject.end.inMilliseconds),
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 150.0,
                ),
                FlatButton.icon(
                  onPressed: this.widget.edit,
                  label: Text('Edit'),
                  icon: Icon(Icons.edit),
                ),
                SizedBox(
                  width: 10.0,
                ),
                FlatButton.icon(
                  onPressed: this.widget.delete,
                  label: Text('Delete'),
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

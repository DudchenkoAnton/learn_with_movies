import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';

class card_movie extends StatefulWidget {
  LessonDB videoObject;
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
    double res = (end - start) / 60;
    return res.toString();
  }
/*
  String thumb = await Thumbnails.getThumbnail(
  thumbnailFolder:'[FOLDER PATH TO STORE THUMBNAILS]', // creates the specified path if it doesnt exist
  videoFile: '[VIDEO PATH HERE]',
  imageType: ThumbFormat.PNG,
  quality: 30);
*/

  String url_image(youtubeUrl) {
    Uri uri = Uri.parse(youtubeUrl);
    String videoID = uri.queryParameters["v"];
    String url = "http://img.youtube.com/vi/" + videoID + "/0.jpg";
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.grey[200],
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  height: 90.0,
                  width: 110.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            url_image(widget.videoObject.getVideoURL())),
                        fit: BoxFit.cover),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Text(widget.videoObject.getLessonName(),
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      calc_time(widget.videoObject.getVideoStartPoint(),
                              widget.videoObject.getVideoEndPoint()) +
                          ' min',
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: this.widget.edit,
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: this.widget.delete,
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    )
                  ],
                ),
              ]),
        ));
  }
}

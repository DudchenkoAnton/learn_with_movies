import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';

import 'package:temp_project/utilites/lesson_objects.dart';
// this class is how the card will look like

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
  String calc_time(double start, double end) {
    double res = (end - start)/60;
    return res.toString();
  }
/*
  String thumb = await Thumbnails.getThumbnail(
  thumbnailFolder:'[FOLDER PATH TO STORE THUMBNAILS]', // creates the specified path if it doesnt exist
  videoFile: '[VIDEO PATH HERE]',
  imageType: ThumbFormat.PNG,
  quality: 30);
*/

   String url_image(youtubeUrl){
    Uri uri = Uri.parse(youtubeUrl);
    String videoID=uri.queryParameters["v"];
    String url = "http://img.youtube.com/vi/" + videoID +"/0.jpg";
    return url;
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            Row(children: <Widget>[
              Container(
              height: 90.0,
              width: 100.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image:NetworkImage(url_image(widget.videoObject.getMainVideoURL())), fit: BoxFit.cover),
              ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            widget.videoObject.getMainVideoName(),
                            style: TextStyle(fontSize: 20.0, color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            calc_time(widget.videoObject.getMainVideoStartTime(),
                                widget.videoObject.getMainVideoEndTime())+' min',
                            style: TextStyle(fontSize: 15.0, color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                ],
              )
            ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 110.0,
                      ),
                      IconButton(
                        onPressed: this.widget.edit,
                        icon: Icon(Icons.edit),
                      ),
                      SizedBox(
                        width: 2.0,
                      ),
                      IconButton(
                        onPressed: this.widget.delete,
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  )


            ]
              ),
              ],
            ),
      ),
    );
  }
}

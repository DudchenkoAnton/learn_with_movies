import 'package:flutter/material.dart';
import 'package:temp_project/utilites/constants.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:temp_project/components/expanded_chekbox_list.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCreatorDetails extends StatefulWidget {
  final LessonData videoData;
  final YoutubePlayerController controller;
  final bool hasInitialVideo;

  VideoCreatorDetails(
      {Key key,
      this.videoData,
      @required this.hasInitialVideo,
      @required this.controller})
      : super(key: key);

  @override
  _VideoCreatorDetailsState createState() => _VideoCreatorDetailsState();
}

class _VideoCreatorDetailsState extends State<VideoCreatorDetails> {
  List<bool> checkBoxValues = [false, false, false, false, false];
  List<String> checkBoxLabels = [
    'Medicine',
    'Law',
    'Entertainment',
    'Sport',
    'History'
  ];
  bool videoLoaded = false;
  bool copyNameCheckBoxValue = false;
  var selectedRange = RangeValues(0.0, 1.0);
  Widget _myAnimatedWidget = Container();
  String enteredURL = '';

  bool updateController() {
    String videoID = YoutubePlayer.convertUrlToId(enteredURL);

    if (videoID != null) {
      widget.videoData.url = enteredURL;
      widget.controller.load(videoID);
      return true;
    }
    return false;
  }

  void updateVideo() {
    bool controllerInitiated = updateController();

    if (controllerInitiated) {
      fetchVideoData();
      uploadVideo();
      videoLoaded = true;
    }
  }

  void uploadVideo() {
    setState(() {
      _myAnimatedWidget = YoutubePlayer(
        controller: widget.controller,
        showVideoProgressIndicator: true,
        onReady: () {
          print('Player is ready.');
          widget.controller.pause();
        },
      );
    });
  }

  void fetchVideoData() {}

  void rangeSelectionFunction(RangeValues values) {}

  @override
  void initState() {
    super.initState();
    if (widget.hasInitialVideo) {
      fetchVideoData();
      uploadVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(9.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
              margin: EdgeInsets.only(bottom: 8.0),
              decoration: kContainerDecorationDefaultLessonEditor,
              child: Column(
                children: <Widget>[
                  Text(
                    'Choose Video',
                    style: TextStyle(fontSize: 23.0),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    onChanged: (value) {
                      enteredURL = value;
                      print(enteredURL);
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter video link',
                    ),
                  ),
                  CheckboxListTile(
                      title: Text('Set video name as lesson name'),
                      value: copyNameCheckBoxValue,
                      onChanged: null),
                  SizedBox(height: 8.0),
                  RawMaterialButton(
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    fillColor: Colors.lightBlueAccent,
                    child: Text('Upload Video'),
                    constraints: BoxConstraints.tightFor(
                      width: double.infinity,
                      height: 50.0,
                    ),
                    onPressed: () {
                      setState(() {
                        updateVideo();
                      });
                    },
                  ),
                  SizedBox(height: 8.0)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
              margin: EdgeInsets.only(bottom: 8.0),
              decoration: kContainerDecorationDefaultLessonEditor,
              child: Column(
                children: <Widget>[
                  Text(
                    'Video Details',
                    style: TextStyle(fontSize: 23.0),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    onChanged: (value) {
                      widget.videoData.name = value;
                    },
                    enabled: !copyNameCheckBoxValue,
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter name of lesson',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ExpandedCheckboxList(
                    mainText: 'Select Labels',
                    expanded: List.generate(checkBoxLabels.length, (int index) {
                      return CheckboxListTile(
                        title: Text(checkBoxLabels[index]),
                        value: checkBoxValues[index],
                        onChanged: (value) {
                          setState(() {
                            checkBoxValues[index] = value;
                          });
                          if (value) {
                            widget.videoData.categories
                                .add(checkBoxLabels[index]);
                            print(widget.videoData.categories);
                          } else {
                            widget.videoData.categories
                                .remove(checkBoxLabels[index]);
                            print(widget.videoData.categories);
                          }
                        },
                      );
                    }),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
              decoration: kContainerDecorationDefaultLessonEditor,
              child: Column(
                children: <Widget>[
                  Text(
                    'Lesson Video Range',
                    style: TextStyle(fontSize: 23.0),
                  ),
                  SizedBox(height: 8.0),
                  AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    child: _myAnimatedWidget,
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        videoLoaded ? '${widget.videoData.start}' : 'Start',
                        style: TextStyle(
                            fontSize: 18.0, color: Colors.blueGrey[900]),
                      ),
                      Text(
                        videoLoaded ? '${widget.videoData.end}' : 'End',
                        style: TextStyle(
                            fontSize: 18.0, color: Colors.blueGrey[900]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  RangeSlider(
                    values: selectedRange,
                    activeColor: Colors.black,
                    onChanged: videoLoaded ? rangeSelectionFunction : null,
                  ),
                  SizedBox(height: 8.0),
                  RawMaterialButton(
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    fillColor: Colors.lightBlueAccent,
                    child: Text('Play Selected Segment'),
                    constraints: BoxConstraints.tightFor(
                      width: double.infinity,
                      height: 50.0,
                    ),
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ]),
    );
  }
}

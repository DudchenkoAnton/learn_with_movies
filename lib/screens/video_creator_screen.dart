import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:temp_project/components/questions_list.dart';
import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:temp_project/utilites/constants.dart';
import 'package:temp_project/components/expanded_chekbox_list.dart';
import 'package:temp_project/services/youtube_helper.dart';

class VideoCreatorScreen extends StatefulWidget {
  static const String id = 'video_creator_screen';
  final LessonData videoData;
  VideoCreatorScreen({Key key, this.videoData}) : super(key: key);

  @override
  _VideoCreatorScreenState createState() => _VideoCreatorScreenState();
}

class _VideoCreatorScreenState extends State<VideoCreatorScreen>
    with TickerProviderStateMixin {
  TabController _tabController;
  YoutubePlayerController _controller;
  LessonData currentLesson;
  final List<Tab> tabsList = [Tab(text: 'Details'), Tab(text: 'Questions')];
  bool videoProvided = false;
  String enteredURL = '';
  bool copyNameCheckBoxValue = false;
  var selectedRange = RangeValues(0.0, 1.0);
  Widget _myAnimatedWidget = Container();
  int startPointValue = 0;
  int endPointValue = 10000000;
  YoutubeNetworkHelper youtubeHelper;

  List<bool> checkBoxValues = [false, false, false, false, false];
  List<String> checkBoxLabels = [
    'Medicine',
    'Law',
    'Entertainment',
    'Sport',
    'History'
  ];

  Container videoNotChosenScreen = Container(
    color: Colors.red[400],
    child: Center(
      child: Text(
        'Please, first choose video',
        style: TextStyle(fontSize: 30.0),
      ),
    ),
  );

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  void playSelectedSegmentListener() {
    Duration startPoint = Duration(seconds: startPointValue);
    Duration endPoint = Duration(seconds: endPointValue);

    if (_controller.value.position < startPoint) {
      _controller.seekTo(startPoint);
      _controller.pause();
    } else if (_controller.value.position > endPoint) {
      _controller.seekTo(endPoint);
      _controller.pause();
    }
  }

  void loadVideo(String url, bool initial) {
    String videoID = YoutubePlayer.convertUrlToId(url);

    if (videoID != null && _controller != null) {
      currentLesson.url = url;
      currentLesson.videoId = videoID;
      _controller.load(videoID);
      _controller.pause();
    } else if (videoID != null && _controller == null) {
      if (!initial) {
        currentLesson.url = url;
        currentLesson.videoId = videoID;
      }
      _controller = YoutubePlayerController(
          initialVideoId: videoID,
          flags: YoutubePlayerFlags(hideControls: true));
      _controller.addListener(playSelectedSegmentListener);
    } else {
      return;
    }

    print('videoIsOk');
    youtubeHelper.loadVideoData(currentLesson);
    uploadVideo();
    videoProvided = true;
  }

  void uploadVideo() {
    setState(() {
      _myAnimatedWidget = YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {
          print('Player is ready.');
          _controller.pause();
        },
      );
    });
  }

  void rangeSelectionFunction(RangeValues newRange) {
//    if (videoProvided) {
//      int videoLength = (widget.videoData.end - widget.videoData.start).toInt();
//
//      setState(() {
//        selectedRange = newRange;
//        startPointValue = (videoLength * newRange.start).round();
//        endPointValue = (videoLength * newRange.end).round();
//      });
//    }
  }

  void saveAndExit() {
    if (videoProvided) {
      currentLesson.printData();
      Navigator.pop(context, currentLesson);
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    youtubeHelper = YoutubeNetworkHelper();
    _tabController = TabController(length: tabsList.length, vsync: this);

    String url;
    if (widget.videoData == null) {
      currentLesson = LessonData(categories: [], questions: []);
    } else {
      widget.videoData.printData();
      url = widget.videoData.url;
      currentLesson = widget.videoData;
      loadVideo(url, true);
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.videoData);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Lesson'),
        actions: <Widget>[
          RawMaterialButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: saveAndExit,
          )
        ],
        bottom: TabBar(
          tabs: tabsList,
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(9.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
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
                                loadVideo(enteredURL, false);
                              });
                            },
                          ),
                          SizedBox(height: 8.0)
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
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
                              currentLesson.name = value;
                            },
                            enabled: !copyNameCheckBoxValue,
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Enter name of lesson',
                            ),
                          ),
                          SizedBox(height: 8.0),
                          ExpandedCheckboxList(
                            mainText: 'Select Labels',
                            expanded: List.generate(checkBoxLabels.length,
                                (int index) {
                              return CheckboxListTile(
                                title: Text(checkBoxLabels[index]),
                                value: checkBoxValues[index],
                                onChanged: (value) {
                                  setState(() {
                                    checkBoxValues[index] = value;
                                  });
                                  if (value) {
                                    currentLesson.categories
                                        .add(checkBoxLabels[index]);
                                    print(currentLesson.categories);
                                  } else {
                                    currentLesson.categories
                                        .remove(checkBoxLabels[index]);
                                    print(currentLesson.categories);
                                  }
                                },
                              );
                            }),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
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
                                'Start',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.blueGrey[900]),
                              ),
                              Text(
                                'End',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.blueGrey[900]),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          RangeSlider(
                            values: selectedRange,
                            activeColor: Colors.black,
                            onChanged:
                                videoProvided ? rangeSelectionFunction : null,
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
            ),
          ),
          videoProvided
              ? QuestionsList(
                  videoData: currentLesson,
                )
              : videoNotChosenScreen,
        ],
      ),
    );
  }
}

//videoProvided
//? SingleChildScrollView(
//child: VideoCreatorDetails(
//controller: _controller,
//hasInitialVideo: true,
//videoData: currentVideo,
//))
//: SingleChildScrollView(
//child: VideoCreatorDetails(
//controller: _controller,
//hasInitialVideo: false,
//videoData: currentVideo,
//)),

//  YoutubeMetaData metaData;
//  Video currentVideoData;
//  var selectedRange = RangeValues(0.0, 1.0);
//
//  QuestionsList videoWasChosenScreen = QuestionsList();

//  void uploadVideoFromYoutube() {
//    String videoID;
//    print(currentVideoData.url);
//    videoID = YoutubePlayer.convertUrlToId(currentVideoData.url);
//    print(videoID);
//    if (videoID == null) {
//      return;
//    }
//    metaDataArrived = false;
//    dataIsUploaded = true;
//    _controller.load(videoID);
//    _controller.pause();
//  }

//  void metaDataListener() {
//    if (_controller.metadata == null ||
//        _controller.metadata.title == null ||
//        _controller.metadata.title == '') {
//      metaData = _controller.metadata;
//      return;
//    }
//    if (metaData.title != null &&
//        metaData.title != _controller.metadata.title) {
//      metaData = _controller.metadata;
//      setState(() {
//        metaDataArrived = true;
//      });
//      print('Meta data arrived');
//      print(metaDataArrived);
//      print(metaData);
//      endPointValue = metaData.duration.inSeconds;
//      videoLength = metaData.duration.inSeconds;
//    }
//  }

//
//  void playSelectedSegment() {
//    Duration startPoint = Duration(seconds: startPointValue);
//    _controller.seekTo(startPoint);
//    _controller.play();
//  }

//  void checkBoxVideoName(value) {
//    setState(() {
//      copyNameCheckBoxValue = value;
//      if (value == true) {
//        selectedYoutubeName = true;
//        nameFieldEnabled = false;
//        currentVideoData.name = metaData.title;
//      }
//      selectedYoutubeName = false;
//    });
//  }

//  void rangeSelectionFunction(RangeValues newRange) {
//    setState(() {
//      selectedRange = newRange;
//      startPointValue = (videoLength * newRange.start).round();
//      endPointValue = (videoLength * newRange.end).round();
//    });
//  }

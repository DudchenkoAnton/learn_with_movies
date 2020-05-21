import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:temp_project/components/question_data_container.dart';
import 'package:temp_project/components/rounded_icon_button.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:temp_project/screens/question_creator_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:temp_project/utilites/constants.dart';
import 'package:temp_project/components/expanded_chekbox_list.dart';
import 'package:temp_project/services/youtube_helper.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:temp_project/components/video_range_slider.dart';
import 'package:temp_project/components/video_range_text_field.dart';

class VideoCreatorScreen extends StatefulWidget {
  static const String id = 'video_creator_screen';
  final LessonDB videoData;
  VideoCreatorScreen({Key key, this.videoData}) : super(key: key);

  @override
  _VideoCreatorScreenState createState() => _VideoCreatorScreenState();
}

class _VideoCreatorScreenState extends State<VideoCreatorScreen>
    with TickerProviderStateMixin {
  YoutubePlayerController _youtubePlayerController;
  LessonDB currentLesson;
  bool videoProvided = false;
  String enteredURL = '';
  bool copyNameCheckBoxValue = false;
  Widget _myAnimatedWidget = Container();
  YoutubeNetworkHelper youtubeHelper;
  List<Duration> startPointValue = [Duration(seconds: 0)];
  List<Duration> endPointValue = [Duration(seconds: 7200)];
  Duration videoLength = Duration(seconds: 10);
  bool showSpinner = false;
  bool canReloadVideo = false;
  List<QuestionDataContainer> _questionsList = [];
  DatabaseUtilities dbHelper = DatabaseUtilities();
  bool editingMode = false;
  TextEditingController _lessonNameFieldController = TextEditingController();
  TextEditingController _videoUrlTextController = TextEditingController();

  List<bool> checkBoxValues = [false, false, false, false, false];
  List<String> checkBoxLabels = [
    'Medicine',
    'Law',
    'Entertainment',
    'Sport',
    'History'
  ];

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  void playSelectedSegmentListener() {
    Duration startPoint = startPointValue[0];
    Duration endPoint = endPointValue[0];

    if (_youtubePlayerController.value.position < startPoint) {
      _youtubePlayerController.seekTo(startPoint);
      _youtubePlayerController.pause();
    } else if (_youtubePlayerController.value.position > endPoint) {
      _youtubePlayerController.seekTo(endPoint);
      _youtubePlayerController.pause();
    }
  }

  void loadVideo(String url, bool initial) async {
    bool loadingFailed = false;
    String videoID;
    showSpinner = true;

    videoID = YoutubePlayer.convertUrlToId(url);
    if (videoID == null) {
      // Todo: show message to user, that url is not valid
      loadingFailed = true;
      canReloadVideo = true;
    }

    if (!loadingFailed && !initial) {
      currentLesson.setVideoURL(url);
      currentLesson.setVideoID(videoID);
      bool videoLoaded = await youtubeHelper.loadVideoData(currentLesson);
      if (!videoLoaded) {
        // Todo: show message to user, that tells that failed to load video data;
        loadingFailed = true;
        canReloadVideo = true;
      }
    }

    print('Got to creating youtuvbe controller');
    print(_youtubePlayerController);
    print(loadingFailed);
    if (_youtubePlayerController == null && !loadingFailed) {
      try {
        _youtubePlayerController = YoutubePlayerController(
            initialVideoId: videoID, flags: YoutubePlayerFlags());
        _youtubePlayerController.addListener(playSelectedSegmentListener);
      } catch (e) {
        // Todo: write code that responds to error in initializing video controller
        print(e);
        canReloadVideo = true;
        loadingFailed = true;
      }
    } else if (!loadingFailed) {
      try {
        _youtubePlayerController.load(videoID);
        _youtubePlayerController.pause();
      } catch (e) {
        // Todo: write code that responds to error in reloading video source
        print(e);
        canReloadVideo = true;
        loadingFailed = true;
      }
    }

    setState(() {
      if (!loadingFailed) {
        switchVideoPlayerPresentationMode(true);
        updateVideoProvided();
      } else {
        switchVideoPlayerPresentationMode(false);
        updateVideoNotProvided();
        if (_youtubePlayerController != null) {
          _youtubePlayerController.pause();
        }
      }
      showSpinner = false;
    });

    setState(() {
      isRange = true;
      changeRangeSelection();
    });
  }

  void updateVideoProvided() {
    videoProvided = true;
    startPointValue[0] = Duration(seconds: currentLesson.getVideoStartPoint());
    endPointValue[0] = Duration(seconds: currentLesson.getVideoEndPoint());
    videoLength = Duration(
        seconds: currentLesson.getVideoEndPoint() -
            currentLesson.getVideoStartPoint());
  }

  void updateVideoNotProvided() {
    videoProvided = false;
  }

  void switchVideoPlayerPresentationMode(bool showPlayer) {
    setState(() {
      if (showPlayer) {
        _myAnimatedWidget = YoutubePlayer(
          controller: _youtubePlayerController,
          showVideoProgressIndicator: true,
          onReady: () {
            print('Player is ready.');
            _youtubePlayerController.pause();
          },
        );
      } else {
        print('Switched to container');
        _myAnimatedWidget = Container();
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  int questionSortFunc(question1, question2) {
    if (question1.getVideoEndTime() < question2.getVideoEndTime()) {
      return 1;
    } else if (question1.getVideoEndTime() > question2.getVideoEndTime()) {
      return -1;
    } else {
      return 0;
    }
  }

  void updateQuestionListOnScreen() {
    _questionsList.clear();
    for (int i = 0; i < currentLesson.questionsList.length; i++) {
      _questionsList.add(QuestionDataContainer(
        numberOfQuestion: (i + 1).toString(),
        questionText: currentLesson.questionsList[i].question,
        answerText: currentLesson.questionsList[i].answer,
        onRemove: () {
          currentLesson.questionsList.removeAt(i);
          setState(() {
            updateQuestionListOnScreen();
          });
        },
        onEdit: () async {
          QuestionDB editedQuestion = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuestionCreatorScreen(
                        videoData: currentLesson,
                        question: currentLesson.questionsList[i],
                      )));
          currentLesson.questionsList.removeAt(i);
          currentLesson.questionsList.add(editedQuestion);
          currentLesson.questionsList.sort(questionSortFunc);
          setState(() {
            updateQuestionListOnScreen();
          });
        },
      ));
    }
  }

  bool allDataIsEntered() {
    print(currentLesson);

    if (!videoProvided ||
        currentLesson.lessonName == null ||
        currentLesson.lessonName == '' ||
        currentLesson.questionsList.length == 0 ||
        currentLesson.labelsList.length == 0) {
      return false;
    }

    return true;
  }

  void saveAndExit() async {
    print('Start of a video is - ${currentLesson.getVideoStartPoint()}');
    print('Start of a video is - ${currentLesson.getVideoEndPoint()}');

    if (!allDataIsEntered()) {
      return;
    }
    showSpinner = true;
    if (videoProvided) {
      if (!editingMode) {
        String documentID = await dbHelper.addLessonToDB(currentLesson);
        currentLesson.setDBReference(documentID);
      } else {
        currentLesson = await dbHelper.editLessonInDB(currentLesson);
      }
      Navigator.pop(context, currentLesson);
    }
    showSpinner = false;
  }

  void initializeData() {
    currentLesson = widget.videoData;
    _videoUrlTextController.text = widget.videoData.videoURL;
    _lessonNameFieldController.text = widget.videoData.lessonName;

    updateQuestionListOnScreen();
  }

  Widget selectionWidget = Container();
  bool isRange = true;
  void changeRangeSelection() {
    if (isRange) {
      selectionWidget = VideoRangeSlider(
        startAt: startPointValue,
        endAt: endPointValue,
        length: videoLength,
        enabled: videoProvided,
        callbackToUpdateScreen: () {
          setState(() {
            currentLesson.setVideoStartPoint(startPointValue[0].inSeconds);
            print(currentLesson.getVideoStartPoint());
            currentLesson.setVideoEndPoint(endPointValue[0].inSeconds);
            print(currentLesson.getVideoEndPoint());
          });
        },
      );
    } else {
      selectionWidget = VideoRangeText(
        startAt: startPointValue,
        endAt: endPointValue,
        length: videoLength,
        enabled: videoProvided,
        callback: () {
          setState(() {
            currentLesson.setVideoStartPoint(startPointValue[0].inSeconds);
            currentLesson.setVideoEndPoint(endPointValue[0].inSeconds);
          });
        },
      );
    }

    isRange = isRange ? false : true;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    youtubeHelper = YoutubeNetworkHelper();
    String url;
    if (widget.videoData == null) {
      currentLesson = LessonDB(labelsList: [], questionsList: []);
    } else {
      editingMode = true;
      initializeData();
      // Todo: this print will be deleted
      widget.videoData.printData();
      url = widget.videoData.getVideoURL();
      loadVideo(url, true);
    }
  }

  @override
  void deactivate() {
    if (_youtubePlayerController != null) {
      _youtubePlayerController.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_youtubePlayerController != null) {
      _youtubePlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
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
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _videoUrlTextController,
                                  onChanged: (value) {
                                    enteredURL = value;
                                  },
                                  decoration: kTextFieldDecoration.copyWith(
                                    hintText: 'Enter video link',
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.0),
                              // Todo: write callback, that removes text, entered to link
                              RoundedIconButton(
                                icon: Icons.delete,
                                onPressed: () {
                                  _videoUrlTextController.text = '';
                                },
                              ),
                            ]),
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
                            if (enteredURL != currentLesson.getVideoURL() ||
                                canReloadVideo) {
                              canReloadVideo = false;
                              setState(() {
                                loadVideo(enteredURL, false);
                              });
                            }
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
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(height: 8.0),
                        TextField(
                          controller: _lessonNameFieldController,
                          enabled: !copyNameCheckBoxValue && videoProvided,
                          onChanged: (value) {
                            currentLesson.lessonName =
                                _lessonNameFieldController.text;
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter name of lesson',
                          ),
                        ),
                        CheckboxListTile(
                          title: Text('Set video name as lesson name'),
                          value: copyNameCheckBoxValue,
                          onChanged: true
                              ? null
                              : (value) {
                                  setState(() {
                                    if (value) {
                                      _lessonNameFieldController.text =
                                          currentLesson.youtubeOriginalName;
                                      currentLesson.lessonName =
                                          currentLesson.youtubeOriginalName;
                                    }
                                    copyNameCheckBoxValue = value;
                                  });
                                },
                        ),
                        SizedBox(height: 8.0),
                        ExpandedCheckboxList(
                          mainText: 'Select Labels',
                          expanded:
                              List.generate(checkBoxLabels.length, (int index) {
                            return CheckboxListTile(
                              title: Text(checkBoxLabels[index]),
                              value: checkBoxValues[index],
                              onChanged: !videoProvided
                                  ? null
                                  : (value) {
                                      setState(() {
                                        checkBoxValues[index] = value;
                                      });
                                      if (value) {
                                        currentLesson
                                            .addLabel(checkBoxLabels[index]);
                                      } else {
                                        currentLesson
                                            .removeLabel(checkBoxLabels[index]);
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
                    margin: EdgeInsets.only(bottom: 8.0),
                    decoration: kContainerDecorationDefaultLessonEditor,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Lesson Video Range',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(height: 8.0),
                        AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: _myAnimatedWidget,
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          child: selectionWidget,
                          height: 40,
                        ),
                        SizedBox(height: 16.0),
                        RawMaterialButton(
                          elevation: 6.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          fillColor: Colors.lightBlueAccent,
                          child: Text('Change Selection Method'),
                          constraints: BoxConstraints.tightFor(
                            width: double.infinity,
                            height: 50.0,
                          ),
                          // Todo: write callback, that changes widgets, that's shown on screen
                          onPressed: () {
                            setState(() {
                              changeRangeSelection();
                            });
                          },
                        ),
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
                          'Questions List',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(height: 20.0),
                        Column(children: _questionsList),
                        SizedBox(height: 15),
                        RoundedIconButton(
                          icon: Icons.add,
                          // Todo: write callback, that responsible for adding question widget to screen
                          onPressed: () async {
                            print(
                                'current start time - ${currentLesson.getVideoStartPoint()} - and end time - ${currentLesson.getVideoEndPoint()} - and current length - ${currentLesson.getVideoLenght()}');
                            QuestionDB newQuestion = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QuestionCreatorScreen(
                                          videoData: currentLesson,
                                        )));
                            if (newQuestion != null &&
                                newQuestion is QuestionDB) {
                              currentLesson.addQuestion(newQuestion);
                              currentLesson.questionsList
                                  .sort(questionSortFunc);
                              setState(() {
                                updateQuestionListOnScreen();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

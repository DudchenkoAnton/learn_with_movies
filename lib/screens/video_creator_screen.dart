import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:temp_project/components/question_data_container.dart';
import 'package:temp_project/components/rounded_icon_button.dart';
import 'package:temp_project/components/video_range_slider_new.dart';
import 'package:temp_project/database/database_utilities.dart';
import 'package:temp_project/screens/question_creator_screen.dart';
import 'package:temp_project/utilites/category_object.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:temp_project/utilites/constants.dart';
import 'package:temp_project/components/expanded_chekbox_list.dart';
import 'package:temp_project/services/youtube_helper.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:temp_project/components/video_range_slider.dart';
import 'package:temp_project/components/video_range_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as youtubeMeta;

class VideoCreatorScreen extends StatefulWidget {
  static const String id = 'video_creator_screen';
  final LessonDB videoData;
  VideoCreatorScreen({Key key, this.videoData}) : super(key: key);

  @override
  _VideoCreatorScreenState createState() => _VideoCreatorScreenState();
}

class _VideoCreatorScreenState extends State<VideoCreatorScreen> with TickerProviderStateMixin {
  //////////////////////////////////////////////////////////////////////
  bool isSaveDraftMode = false;
  bool isEditedStep = false;
  int currentStep = 0;
  int stepLength = 3;
  bool stepsCompleted = false;
  bool isAlreadySavedAsDraft = false;
  //////////////////////////////////////////////////////////////////////
  TextEditingController videoLinkController = TextEditingController();
  TextEditingController lessonNameController = TextEditingController();
  String currentLoadedLink = "";
  bool loadingVideoFailed = false;
  bool loadingProcessFailed = false;
  bool videoSuccessfullyLoaded = false;
  bool shouldValidateThird = false;
  final _videoLinkFormKey = GlobalKey<FormState>();
  final _firstStepFormKey = GlobalKey<FormState>();
  final _secondStepFormKey = GlobalKey<FormState>();
  final _thirdStepFormKey = GlobalKey<FormState>();
  int secondsStartPoint = 0;
  int secondsEndPoint = 1;
  int secondsLength = 2;
  List<QuestionDataContainer> _questionsList = [];
  /////////////////////////////////////////////////////////////////////
  LessonDB currentLesson;
  bool showSpinner = false;
  DatabaseUtilities dbHelper = DatabaseUtilities();
  YoutubeNetworkHelper youtubeHelper;
  YoutubePlayerController youtubePlayerController;
  YoutubePlayer youtubePlayer;
  List<bool> checkBoxValues = [false, false, false, false, false, false];
  List<String> checkBoxLabels = ['Medicine', 'Law', 'Entertainment', 'Sport', 'History', 'Music'];
  //////////////////////////////////////////////////////////////////////

  Widget getFirstForm() {
    return Form(
      key: _firstStepFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(9.0),
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: kContainerDecorationDefaultLessonEditor,
            child: Column(children: <Widget>[
              Text('Choose Video', style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),
              Form(
                key: _videoLinkFormKey,
                child: TextFormField(
                  controller: videoLinkController,
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter video link',
                      suffixIcon: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            videoLinkController.clear();
                          })),
                  validator: (input) {
                    if (input.length == 0) {
                      return 'Enter a youtube video link';
                    } else if (loadingVideoFailed && !loadingProcessFailed) {
                      loadingVideoFailed = false;
                      return 'Invalid youtube video link';
                    } else if (loadingProcessFailed && loadingProcessFailed) {
                      loadingVideoFailed = false;
                      loadingProcessFailed = false;
                      return 'There was problem with network, please retry again';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(height: 8),
              FormField<bool>(
                builder: (state) => Column(children: [
                  RawMaterialButton(
                    elevation: 6,
                    fillColor: Colors.lightBlueAccent,
                    child: Text('Upload Video'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    constraints: BoxConstraints.tightFor(width: double.infinity, height: 50),
                    onPressed: () async {
                      if (_videoLinkFormKey.currentState.validate() && videoLinkController.text != currentLoadedLink) {
                        await loadVideo(videoLinkController.text, true);
                        _videoLinkFormKey.currentState.validate();
                        _firstStepFormKey.currentState.validate();
                        setEditedStep();
                      }
                    },
                  ),
                  state.hasError
                      ? Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            state.errorText,
                            style: TextStyle(color: Colors.red[700], fontSize: 12),
                          ),
                        )
                      : Container()
                ]),
                validator: (widget) {
                  if (!videoSuccessfullyLoaded) {
                    return 'Please, upload youtube video';
                  } else {
                    return null;
                  }
                },
              ),
              videoSuccessfullyLoaded
                  ? Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Text(
                        "Video uploaded successfully!",
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    )
                  : Container(),
            ]),
          ),
          Container(
            padding: EdgeInsets.all(9.0),
            decoration: kContainerDecorationDefaultLessonEditor,
            child: Column(
              children: <Widget>[
                Text(
                  'Video Details',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 8.0),
                TextFormField(
                  onChanged: (string) => setEditedStep(),
                  controller: lessonNameController,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter name of lesson',
                  ),
                  validator: (input) => input.length == 0 ? 'Enter a lesson name' : null,
                ),
                SizedBox(height: 8.0),
                FormField<bool>(
                  builder: (state) => Column(children: [
                    ExpandedCheckboxList(
                      mainText: generateMainText(),
                      expanded: List.generate(checkBoxLabels.length, (int index) {
                        return CheckboxListTile(
                          title: Text(checkBoxLabels[index]),
                          value: checkBoxValues[index],
                          onChanged: (value) {
                            setState(() => checkBoxValues[index] = value);
                            if (value) {
                              currentLesson.addLabel(checkBoxLabels[index]);
                            } else {
                              currentLesson.removeLabel(checkBoxLabels[index]);
                            }
                            setEditedStep();
                          },
                        );
                      }),
                    ),
                    state.hasError
                        ? Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              state.errorText,
                              style: TextStyle(color: Colors.red[700], fontSize: 12),
                            ),
                          )
                        : Container()
                  ]),
                  validator: (widget) {
                    bool hasLabel = false;
                    for (bool value in checkBoxValues) {
                      if (value) hasLabel = true;
                    }
                    if (!hasLabel) {
                      return 'Pick at least one label';
                    } else {
                      return null;
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String generateMainText() {
    String res = 'Selected Labels:';
    bool labelPicked = false;
    for (int i = 0; i < checkBoxValues.length; i++) {
      if (checkBoxValues[i]) {
        labelPicked = true;
        res = res + ' ${checkBoxLabels[i]},';
      }
    }

    if (labelPicked) {
      return res.substring(0, res.length - 1);
    } else {
      return 'Select Labels';
    }
  }

  Widget getSecondForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(9.0),
          decoration: kContainerDecorationDefaultLessonEditor,
          child: Column(
            children: <Widget>[
              Text(
                'Lesson Video Range',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 12.0),
              youtubePlayer,
              SizedBox(height: 16.0),
              VideoRangeSliderNew(
                secondsStartPoint: secondsStartPoint,
                secondsEndPoint: secondsEndPoint,
                secondsLength: secondsLength,
                onChanged: (int start, int end) {
                  setState(() {
                    secondsStartPoint = start;
                    secondsEndPoint = end;
                    currentLesson.setVideoStartPoint(start);
                    currentLesson.setVideoEndPoint(end);
                    youtubePlayerController.pause();
                  });
                  setEditedStep();
                },
              ),
              SizedBox(height: 16.0),
              VideoRangeText(
                formKey: _secondStepFormKey,
                secondsStartPoint: secondsStartPoint,
                secondsEndPoint: secondsEndPoint,
                secondsLength: secondsLength,
                onChanged: (int start, int end) {
                  setState(() {
                    secondsStartPoint = start;
                    secondsEndPoint = end;
                    currentLesson.setVideoStartPoint(start);
                    currentLesson.setVideoEndPoint(end);
                    youtubePlayerController.pause();
                  });
                  setEditedStep();
                },
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget getThirdForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(9.0),
          decoration: kContainerDecorationDefaultLessonEditor,
          child: Form(
            key: _thirdStepFormKey,
            child: FormField<bool>(
              builder: (state) => Column(
                children: <Widget>[
                  Text(
                    'Questions List',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 20.0),
//                  Column(children: _questionsList),
                  Container(
                    height: 380,
                    child: ReorderableListView(
                      onReorder: _onReorder,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      children: updateQuestionListOnScreen(),
                    ),
                  ),
                  SizedBox(height: 15),
                  RoundedIconButton(
                    icon: Icons.add,
                    onPressed: () async {
                      QuestionDB newQuestion = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuestionCreatorScreen(
                                    videoData: currentLesson,
                                  )));
                      if (newQuestion != null && newQuestion is QuestionDB) {
                        newQuestion.questionIndex = currentLesson.questionsList.length;
                        currentLesson.addQuestion(newQuestion);
                        //TODO: here I eliminated sorting code
                        currentLesson.questionsList.sort(questionSortFunc);
                        setState(() {
                          shouldValidateThird = false;
                          _thirdStepFormKey.currentState.validate();
                          updateQuestionListOnScreen();
                        });
                        if (isSaveDraftMode) saveDraftData();
                      }
                    },
                  ),
                  (state.hasError || shouldValidateThird)
                      ? Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            'You should add at least one question',
                            style: TextStyle(color: Colors.red[700], fontSize: 12),
                          ),
                        )
                      : Container(),
                ],
              ),
              validator: (widget) {
                if (currentLesson.questionsList.length == 0) {
                  return 'You should add at least one question';
                } else {
                  return null;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setEditedStep();
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final QuestionDB container = currentLesson.questionsList.removeAt(oldIndex);
      currentLesson.questionsList.insert(newIndex, container);
      for (int i = 0; i < currentLesson.questionsList.length; i++) {
        currentLesson.questionsList[i].questionIndex = i;
      }
    });
  }

  Widget lessonDataStepper() {
    return Stepper(
      steps: generateListOfSteps(currentStep),
      type: StepperType.horizontal,
      currentStep: currentStep,
      onStepContinue: nextStep,
      onStepCancel: cancelStep,
      onStepTapped: (step) => goTo(step),
      controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
          currentStep == 2
              ? Container()
              : Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: RaisedButton(
                    onPressed: onStepContinue,
                    child: Text("Continue"),
                    color: Colors.lightBlueAccent,
                  ),
                ),
    );
  }

  @override
  void initState() {
    super.initState();

    Category tempCatObj = Category();
    checkBoxLabels = tempCatObj.getCategoriesListLessonCreator();
    checkBoxValues = tempCatObj.getIsPressListLessonCreator();

    youtubeHelper = YoutubeNetworkHelper();
    if (widget.videoData == null) {
      currentLesson = LessonDB(labelsList: [], questionsList: []);
      // This code just initializes temp values for youtube player, and controller;
      youtubePlayerController = YoutubePlayerController(initialVideoId: 'ECv4tr0p434');
      youtubePlayer = YoutubePlayer(
        controller: youtubePlayerController,
      );
      // If user creates new lesson, set save draft mode
      isSaveDraftMode = true;
    } else {
      initializeLessonData();
      loadVideo(currentLesson.getVideoURL(), false);
      updateQuestionListOnScreen();
      // If user is editing existing draft, set save draft mode
      if (widget.videoData.isDraft) isSaveDraftMode = true;
    }
  }

  void setEditedStep() {
    isEditedStep = true;
  }

  @override
  void dispose() {
    if (youtubePlayerController != null) youtubePlayerController.dispose();
    super.dispose();
  }

  AppBar generateAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text('Create Lesson'),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (currentStep == 0) {
              if (!isSaveDraftMode || (isSaveDraftMode && isEditedStep)) {
                showAlertDialog();
              } else if (isAlreadySavedAsDraft) {
                Navigator.pop(context, currentLesson);
              } else {
                Navigator.of(context).pop();
              }
            } else {
              cancelStep();
            }
          }),
      actions: widget.videoData == null || widget.videoData.checkIfDraft()
          ? (currentStep < 2
              ? <Widget>[
                  RawMaterialButton(
                    child: Text(
                      'Save draft',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: saveDraftDataAndExit,
                  )
                ]
              : <Widget>[
                  RawMaterialButton(
                    child: Text(
                      'Save draft',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: saveDraftDataAndExit,
                    constraints: BoxConstraints(maxWidth: 60),
                  ),
                  RawMaterialButton(
                    child: Text(
                      'Upload',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: saveDraftAsLesson,
                    constraints: BoxConstraints(maxWidth: 150, minWidth: 60),
                  )
                ])
          : <Widget>[
              RawMaterialButton(
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: saveLessonDataAndExit,
              )
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: generateAppBar(),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: lessonDataStepper(),
      ),
    );
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> loadVideo(String videoURL, bool loadMetaData) async {
    String videoID;
    bool metaDataLoaded;

    if (!videoURL.startsWith('https://')) videoURL = 'https://' + videoURL;
    // first of all, we check whether provided url is legal youtube video url
    videoID = YoutubePlayer.convertUrlToId(videoURL);
    if (videoID == null) {
      loadingVideoFailed = true;
      return;
    } else {
      videoURL = 'https://m.youtube.com/watch?v=' + videoID;
    }

    // if so, we start 'loading' animation
    setState(() => showSpinner = true);

    // if argument provided, we send request with api 3 to grab video meta data,
    // like video length, and set video url and id to 'currentLesson' data object
    if (loadMetaData) {
      currentLesson.setVideoURL(videoURL);
      currentLesson.setVideoID(videoID);
      // #########################################################
      var yt = youtubeMeta.YoutubeExplode();
      var video = await yt.videos.get(videoID);
      yt.close();
      if (video == null || video.duration.inSeconds == 0) {
        loadingProcessFailed = true;
        loadingVideoFailed = true;
        setState(() => showSpinner = false);
        return;
      } else {
        currentLesson.setVideoStartPoint(0);
        currentLesson.setVideoEndPoint(video.duration.inSeconds);
        currentLesson.setOriginalVideoLength(currentLesson.getVideoEndPoint());
        currentLesson.setYoutubeOriginalName(video.title);

        print(currentLesson.getVideoEndPoint());
        print(currentLesson.youtubeOriginalName);
      }
      // #########################################################
//      metaDataLoaded = await youtubeHelper.loadVideoData(currentLesson);
//      if (!metaDataLoaded) {
//        loadingProcessFailed = true;
//        loadingVideoFailed = true;
//        setState(() => showSpinner = false);
//        return;
//      }
    }

    // then, we update video controller, whether there already was loaded video, or not
    try {
      if (youtubePlayerController == null) {
        youtubePlayerController = YoutubePlayerController(initialVideoId: videoID);
      } else {
        youtubePlayerController = YoutubePlayerController(initialVideoId: videoID);
//        youtubePlayerController.load(videoID);
//        youtubePlayerController.reset();
      }
      youtubePlayerController.addListener(playSelectedSegmentListener);
      youtubePlayer = YoutubePlayer(
        controller: youtubePlayerController,
      );
    } catch (e) {
      youtubePlayerController = null;
      youtubePlayer = null;
      loadingProcessFailed = true;
      loadingVideoFailed = true;
      setState(() => showSpinner = false);
      return;
    }

    // after successive loading, we end animation, and return 'true'
    setState(() => showSpinner = false);
    currentLoadedLink = videoURL;
    loadingVideoFailed = false;
    videoSuccessfullyLoaded = true;
    getVideoTimeMarks();
    if (widget.videoData == null) {
      Fluttertoast.showToast(
        msg: "Video Uploaded Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }

    return;
  }

  void getVideoTimeMarks() {
    secondsLength = currentLesson.getOriginalVideoLength();
    secondsStartPoint = currentLesson.getVideoStartPoint();
    secondsEndPoint = currentLesson.getVideoEndPoint();
  }

  void initializeLessonData() {
    currentLesson = widget.videoData;
    lessonNameController.text = currentLesson.getLessonName();
    videoLinkController.text = currentLesson.getVideoURL();
    List<String> lessonInitialLabels = currentLesson.getLabelsList();
    for (String label in lessonInitialLabels) {
      for (int i = 0; i < checkBoxLabels.length; i++) {
        if (label == checkBoxLabels[i]) checkBoxValues[i] = true;
      }
    }
  }

  void playSelectedSegmentListener() {
    if (youtubePlayerController.value.position.inSeconds < secondsStartPoint) {
      youtubePlayerController.seekTo(Duration(seconds: secondsStartPoint));
      youtubePlayerController.pause();
    } else if (youtubePlayerController.value.position.inSeconds > secondsEndPoint) {
      youtubePlayerController.seekTo(Duration(seconds: secondsEndPoint));
      youtubePlayerController.pause();
    }
  }

  void saveDraftDataAndExit() async {
    if (showSpinner) return;
    bool isEdited = false;

    if (currentStep != 0 || _firstStepFormKey.currentState.validate()) {
      currentLesson.setLessonName(lessonNameController.text);
      currentLesson.setVideoURL(currentLoadedLink);
    } else {
      return;
    }

    currentLesson.setVideoStartPoint(secondsStartPoint);
    currentLesson.setVideoEndPoint(secondsEndPoint);
    currentLesson.setIsDraft(true);

    setState(() => showSpinner = true);
    try {
      if (widget.videoData == null && !isAlreadySavedAsDraft) {
        String documentID = await dbHelper.addDraftToDB(currentLesson);
        currentLesson.setDBReference(documentID);
      } else {
        while (!isEdited) {
          isEdited = await dbHelper.editDraftInDB(currentLesson);
        }
      }
      Navigator.pop(context, currentLesson);
    } catch (e) {
      //TODO: add code in case that lesson saving failed
    }
    setState(() => showSpinner = false);
  }

  void saveDraftData() async {
    bool isEdited = false;

    if (currentStep != 0 || _firstStepFormKey.currentState.validate()) {
      currentLesson.setLessonName(lessonNameController.text);
      currentLesson.setVideoURL(currentLoadedLink);
    } else {
      return;
    }

    currentLesson.setVideoStartPoint(secondsStartPoint);
    currentLesson.setVideoEndPoint(secondsEndPoint);
    currentLesson.setIsDraft(true);

    setState(() => showSpinner = true);
    try {
      if (widget.videoData == null && !isAlreadySavedAsDraft) {
        String documentID = await dbHelper.addDraftToDB(currentLesson);
        currentLesson.setDBReference(documentID);
        isAlreadySavedAsDraft = true;
      } else {
        while (!isEdited) {
          isEdited = await dbHelper.editDraftInDB(currentLesson);
        }
      }
    } catch (e) {
      //TODO: add code in case that lesson saving failed
    }
    setState(() => showSpinner = false);
  }

  void saveDraftAsLesson() async {
    if (showSpinner) return;
    if (widget.videoData == null && !isAlreadySavedAsDraft) {
      saveLessonDataAndExit();
    } else {
      if (currentStep == 0 && !_firstStepFormKey.currentState.validate()) {
        return;
      }
      if (currentLesson.questionsList.length == 0 && currentStep == 2) {
        _thirdStepFormKey.currentState.validate();
        shouldValidateThird = false;
        return;
      } else if (currentLesson.questionsList.length == 0 && currentStep != 2) {
        shouldValidateThird = true;
        goTo(2);
        return;
      }
      await dbHelper.deleteDraftFromDB(currentLesson);
      saveLessonDataAndExit();
    }
  }

  void saveLessonDataAndExit() async {
    bool isEdited = false;

    if (currentStep != 0 || _firstStepFormKey.currentState.validate()) {
      currentLesson.setLessonName(lessonNameController.text);
      currentLesson.setVideoURL(currentLoadedLink);
    } else {
      return;
    }

    if (currentLesson.questionsList.length == 0 && currentStep == 2) {
      _thirdStepFormKey.currentState.validate();
      shouldValidateThird = false;
      return;
    } else if (currentLesson.questionsList.length == 0 && currentStep != 2) {
      shouldValidateThird = true;
      goTo(2);
      return;
    }

    currentLesson.setVideoStartPoint(secondsStartPoint);
    currentLesson.setVideoEndPoint(secondsEndPoint);

    setState(() => showSpinner = true);
    try {
      if (widget.videoData == null || currentLesson.checkIfDraft()) {
        currentLesson.setIsDraft(false);
        String documentID = await dbHelper.addLessonToDB(currentLesson);
        currentLesson.setDBReference(documentID);
      } else {
        while (!isEdited) {
          isEdited = await dbHelper.editLessonInDB(currentLesson);
        }
      }
      Navigator.pop(context, currentLesson);
    } catch (e) {
      //TODO: add code in case that lesson saving failed
    }
    setState(() => showSpinner = false);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////

  List<Step> generateListOfSteps(int currentStep) {
    return [
      Step(
        title: const Text(''),
        isActive: true,
        state: (currentStep == 0) ? StepState.editing : StepState.indexed,
        content: getFirstForm(),
      ),
      Step(
        title: const Text(''),
        isActive: true,
        state: (currentStep == 1) ? StepState.editing : StepState.indexed,
        content: getSecondForm(),
      ),
      Step(
        title: const Text(''),
        isActive: true,
        state: (currentStep == 2) ? StepState.editing : StepState.indexed,
        content: getThirdForm(),
      )
    ];
  }

  void nextStep() {
    if (currentStep + 1 != stepLength) {
      goTo(currentStep + 1);
    } else {
      setState(() => stepsCompleted = true);
    }
  }

  void goTo(int step) {
    if (currentStep == 0 && !_firstStepFormKey.currentState.validate()) {
      return;
    }
    if (currentStep == 1 && step != 1) {
      youtubePlayerController.reset();
    } else if (currentStep != 1 && step == 1) {
      youtubePlayerController.pause();
    }

    if (step != currentStep && isSaveDraftMode && isEditedStep) {
      isEditedStep = false;
      saveDraftData();
    }

    setState(() => currentStep = step);
  }

  void cancelStep() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  int questionSortFunc(QuestionDB question2, QuestionDB question1) {
    if (question1.questionIndex < question2.questionIndex) {
      return 1;
    } else if (question1.questionIndex > question2.questionIndex) {
      return -1;
    } else {
      return 0;
    }
  }

  void updateQuestionIndexes() {
    for (int i = 0; i < currentLesson.questionsList.length; i++) {
      currentLesson.questionsList[i].questionIndex = i;
    }
  }

  List<Widget> updateQuestionListOnScreen() {
    _questionsList.clear();
    for (int i = 0; i < currentLesson.questionsList.length; i++) {
      _questionsList.add(QuestionDataContainer(
        key: Key('$i'),
        numberOfQuestion: (i + 1).toString(),
        questionText: currentLesson.questionsList[i].question,
        answerText: currentLesson.questionsList[i].answer,
        onRemove: () {
          currentLesson.questionsList.removeAt(i);
          updateQuestionIndexes();
          setState(() {
            updateQuestionListOnScreen();
          });
          if (isSaveDraftMode) saveDraftData();
        },
        onEdit: () async {
          QuestionDB editedQuestion = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuestionCreatorScreen(
                        videoData: currentLesson,
                        question: currentLesson.questionsList[i],
                      )));
          if (editedQuestion != null && editedQuestion is QuestionDB) {
            //TODO: here is change of questions sorting code
            editedQuestion.questionIndex = i;
            currentLesson.questionsList.removeAt(i);
            currentLesson.questionsList.add(editedQuestion);
            currentLesson.questionsList.sort(questionSortFunc);
            if (isSaveDraftMode) saveDraftData();
          }
          setState(() {
            updateQuestionListOnScreen();
          });
        },
      ));
    }

    return _questionsList;
  }

  void showAlertDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure you want to exit? All changes will not be saved."),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
                child: Text("Exit"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }
}

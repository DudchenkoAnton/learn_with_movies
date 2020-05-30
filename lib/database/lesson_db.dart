import 'question_db.dart';

class LessonDB {
  String videoURL;
  String lessonName;
  String lessonDetails;
  int videoStartPoint;
  int videoEndPoint;
  List<String> labelsList;
  List<QuestionDB> questionsList = [];
  String youtubeOriginalName;
  String videoID;
  String dbDocumentID;
  int numberViews; // amount of views of lesson
  double averageRating;
  int numberReviews; //
  int originalVideoLength;
  String creatorUserID; // amount of users that leaves a rating
  String creationDate;

  LessonDB(
      {this.originalVideoLength,
      this.creationDate,
      this.creatorUserID,
      this.videoURL,
      this.lessonName,
      this.lessonDetails,
      this.videoStartPoint,
      this.videoEndPoint,
      this.labelsList,
      this.youtubeOriginalName,
      this.videoID,
      this.questionsList,
      this.numberViews = 0,
      this.averageRating = 0,
      this.numberReviews = 0});

  int getOriginalVideoLength() {
    return this.originalVideoLength;
  }

  void setOriginalVideoLength(int secondsLength) {
    originalVideoLength = secondsLength;
  }

  String getCreatorUserID() {
    return this.creatorUserID;
  }

  void setCreatorUserID(String userID) {
    creatorUserID = userID;
  }

  String getCreationDate() {
    return this.creationDate;
  }

//  void setCreationDate(String date) {
//    this.creationDate = date;
//  }

  String getVideoID() {
    return this.videoID;
  }

  String getDBReference() {
    return this.dbDocumentID;
  }

  String getVideoURL() {
    return this.videoURL;
  }

  String getLessonName() {
    return this.lessonName;
  }

  String getLessonDetails() {
    return this.lessonDetails;
  }

  int getVideoStartPoint() {
    return this.videoStartPoint;
  }

  int getVideoEndPoint() {
    return this.videoEndPoint;
  }

  int getNumberViews() {
    return this.numberViews;
  }

  int getNumberReviews() {
    return this.numberReviews;
  }

  int getAverageRatingInt() {
    if (this.averageRating == null) {
      return 0;
    }
    print(((this.averageRating).roundToDouble()).toString());
    return (this.averageRating).round();
  }

  double getAverageRating() {
    return this.averageRating;
  }

  String getVideoLenght() {
    var s = this.videoEndPoint - this.videoStartPoint;
    var hrs = (s / 3600).floor();

    var mins = ((s % 3600) / 60).floor();
    var secs = (s % 60).floor();
    var res = '';
    if (hrs > 0) {
      res += "" + hrs.toString() + ":" + (mins < 10 ? "0" : "");
    }
    res += "" + mins.toString() + ":" + (secs < 10 ? "0" : secs.toString());
    return res;
  }

  List<String> getLabelsList() {
    return this.labelsList;
  }

  List<QuestionDB> getQuestionsList() {
    return this.questionsList;
  }

  void setDBReference(var arg) {
    this.dbDocumentID = arg;
  }

  void setVideoURL(String arg) {
    this.videoURL = arg;
  }

  void setLessonName(String arg) {
    this.lessonName = arg;
  }

  void setLessonDetails(String arg) {
    this.lessonDetails = arg;
  }

  void setVideoStartPoint(int arg) {
    this.videoStartPoint = arg;
  }

  void setVideoEndPoint(int arg) {
    this.videoEndPoint = arg;
  }

  void addLabel(String _label) {
    this.labelsList.add(_label);
  }

  void removeLabel(String _label) {
    if (labelsList.indexOf(_label) != -1) {
      labelsList.remove(_label);
    }
  }

  void addQuestion(QuestionDB _question) {
    if (questionsList == null) {
      questionsList = [];
    }
    this.questionsList.add(_question);
  }

  void setYoutubeOriginalName(String name) {
    this.youtubeOriginalName = name;
  }

  void setVideoID(String _videoID) {
    this.videoID = _videoID;
  }

  void setNumberViews(int arg) {
    this.numberViews = arg;
  }

  void setNumberReviews(int arg) {
    this.numberReviews = arg;
  }

  void setAverageRating(double arg) {
    this.averageRating = arg;
  }

  void printData() {
    print('Start debug printing:');
    print(lessonName);
    print(videoURL);
    print(videoStartPoint);
    print(videoEndPoint);
    print(labelsList);
    print(youtubeOriginalName);
  }
}

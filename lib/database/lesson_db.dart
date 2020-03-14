import 'question_db.dart';

class LessonDB {

  String mainVideoURL;
  String mainVideoName;
  String mainVideoDetails;
  double mainVideoStartTime;
  double mainVideoEndTime;

  List<String> labelsList;
  List<QuestionDB> questionsList;

  LessonDB(String _mainVideoURL, String _mainVideoName, String _mainVideoDetails,
      double _mainVideoStartTime, double _mainVideoEndTime, var _labelsList) {

    this.mainVideoURL = _mainVideoURL;
    this.mainVideoName = _mainVideoName;
    this.mainVideoDetails = _mainVideoDetails;
    this.mainVideoStartTime = _mainVideoStartTime;
    this.mainVideoEndTime = _mainVideoEndTime;

    this.questionsList =  new List();
    this.labelsList = _labelsList;
  }

  String getMainVideoURL() {
    return this.mainVideoURL;
  }
  String getMainVideoName() {
    return this.mainVideoName;
  }

  String getMainVideoDetails() {
    return this.mainVideoDetails;
  }

  double getMainVideoStartTime() {
    return this.mainVideoStartTime;
  }

  double getMainVideoEndTime() {
    return this.mainVideoEndTime;
  }

  List<String> getLabelsList() {
    return this.labelsList;
  }

  List<QuestionDB> getQuestionsList() {
    return this.questionsList;
  }

  void setMainVideoURL(String arg) {
    this.mainVideoURL = arg;
  }
  void setMainVideoName(String arg) {
    this.mainVideoName = arg;
  }

  void seMainVideoDetails(String arg) {
    this.mainVideoDetails = arg;
  }

  void setMainVideoStartTime(double arg) {
    this.mainVideoStartTime = arg;
  }

  void setMainVideoEndTime(double arg) {
    this.mainVideoEndTime = arg;
  }

  void addLabel(String _label) {
    this.labelsList.add(_label);
  }

  void addQuestion(QuestionDB _question) {
    this.questionsList.add(_question);
  }

}
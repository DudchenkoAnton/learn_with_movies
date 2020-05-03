class QuestionDB {
  String videoURL;
  String question;
  String answer;
  String americanAnswers; // answer1;answer2;...;answerN
  int videoStartPoint;
  int videoEndPoint;
  int answerStartPoint;
  int answerEndPoint;

  QuestionDB(
      {this.videoURL,
      this.question,
      this.answer,
      this.americanAnswers = "",
      this.videoEndPoint,
      this.videoStartPoint,
      this.answerStartPoint = 0,
      this.answerEndPoint = 0});

  bool isAnswerVideoAdded() {
    if (this.answerStartPoint == 0 && this.answerEndPoint == 0) {
      return false;
    }
    return true;
  }

//  QuestionDB(String _videoURL, String _question, String _answer,
//      double _videoStartTime, double _videoEndTime) {
//    this.videoURL = _videoURL;
//    this.question = _question;
//    this.answer = _answer;
//    this.videoStartTime = _videoStartTime;
//    this.videoEndTime = _videoEndTime;
//  }

  String getVideoURL() {
    return this.videoURL;
  }

  String getQuestion() {
    return this.question;
  }

  String getAnswer() {
    return this.answer;
  }

  String getAmericanAnswers() {
    return this.americanAnswers;
  }

  int getVideoStartTime() {
    return this.videoStartPoint;
  }

  int getVideoEndTime() {
    return this.videoEndPoint;
  }

  int getAnswerStartTime() {
    return this.answerStartPoint;
  }

  int getAnswerEndTime() {
    return this.answerEndPoint;
  }

  void setVideoURL(String arg) {
    this.videoURL = arg;
  }

  void setQuestion(String arg) {
    this.question = arg;
  }

  void setAnswer(String arg) {
    this.answer = arg;
  }

  void setAmericanAnswers(String arg) {
    this.americanAnswers = arg;
  }

  void setVideoStartTime(int arg) {
    this.videoStartPoint = arg;
  }

  void setVideoEndTime(int arg) {
    this.videoEndPoint = arg;
  }

  void setAnsewerStartTime(int arg) {
    this.answerStartPoint = arg;
  }

  void setAnswerEndTime(int arg) {
    this.answerEndPoint = arg;
  }

  Map<String, dynamic> toJson() {
    //return [this.videoURL, this.question, this.answer,
    //this.videoStartTime, this.videoEndTime];
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["videoURL"] = this.videoURL;
    map["question"] = this.question;
    map["answer"] = this.answer;
    map["videoStartTime"] = this.videoStartPoint;
    map["videoEndTime"] = this.videoEndPoint;
    map["answerStartTime"] = this.answerStartPoint;
    map["answerEndTime"] = this.answerEndPoint;
    return map;
  }
}

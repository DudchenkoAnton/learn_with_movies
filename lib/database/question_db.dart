class QuestionDB {

  String videoURL;
  String question;
  String answer;
  double videoStartTime;
  double videoEndTime;

  QuestionDB(String _videoURL, String _question, String _answer,
      double _videoStartTime, double _videoEndTime) {

    this.videoURL = _videoURL;
    this.question = _question;
    this.answer = _answer;
    this.videoStartTime = _videoStartTime;
    this.videoEndTime = _videoEndTime;
  }

  String getVideoURL() {
    return this.videoURL;
  }
  String getQuestion() {
    return this.question;
  }

  String getAnswer() {
    return this.answer;
  }

  double getVideoStartTime() {
    return this.videoStartTime;
  }

  double getVideoEndTime() {
    return this.videoEndTime;
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

  void setVideoStartTime(double arg) {
    this.videoStartTime = arg;
  }

  void setVideoEndTime(double arg) {
    this.videoEndTime = arg;
  }

}
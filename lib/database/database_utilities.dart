import 'lesson_db.dart';
import 'question_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseUtilities {

  final databaseReference = Firestore.instance;
  List<LessonDB> lessonsList = new List<LessonDB>();

  Future<bool> deleteLessonFromDB(LessonDB lesson) async {

    var lesson_ref = lesson.getDBReference();

    if (lesson_ref == null) {
      return false;
    }

    try {
      databaseReference
          .collection('lessons')
          .document(lesson_ref)
          .delete();
      return true;
    } catch (e) {
      print(e.toString());
    }
  }

  void addLessonToDB(LessonDB lesson) async {

    DocumentReference ref = await databaseReference.collection("lessons")
        .add({
      'mainVideoURL': lesson.getMainVideoURL(),
      'mainVideoName': lesson.getMainVideoName(),
      'mainVideoDetails': lesson.getMainVideoDetails(),
      'mainVideoStartTime': lesson.getMainVideoStartTime(),
      'mainVideoEndTime': lesson.getMainVideoEndTime(),
      'labels': lesson.getLabelsList(),
    });

    for (QuestionDB question in lesson.getQuestionsList()) {
      databaseReference.collection('lessons').document(ref.documentID).
      collection('questions').add({
        'videoURL': question.getVideoURL(),
        'question': question.getQuestion(),
        'answer': question.getAnswer(),
        'videoStartTime': question.getVideoStartTime(),
        'videoEndTime': question.getVideoEndTime()
      });
    }
  }

  LessonDB getLessonByString(String str) {

    List<String> labels1 = new List();
    labels1.add("Entertainment");

    LessonDB l1 = new LessonDB("https://www.youtube.com/watch?v=xHcPhdZBngw",
        "Friends: Top 20 Funniest Moments | TBS",
        "Pull up a couch and relax at Central Perk, "
            "where six Friends gather to talk about life "
            "and love. Friends tells the story of siblings "
            "Ross (David Schwimmer) and Monica (Courteney Cox) "
            "Geller, and their friends, Chandler Bing (Matthew Perry), "
            "Phoebe Buffay (Lisa Kudrow), Joey Tribbiani (Matt LeBlanc), "
            "and Rachel Green (Jennifer Aniston).",
        0,
        30,
        labels1);

    l1.addQuestion(
        new QuestionDB("https://www.youtube.com/watch?v=xHcPhdZBngw",
            "Some question ?",
            "Some answer",
            6.19,
            7.20)
    );

    l1.addQuestion(
        new QuestionDB("https://www.youtube.com/watch?v=xHcPhdZBngw",
            "Some question 2 ?",
            "Some answer 2",
            9.33,
            11.56)
    );

    return l1;
  }

  Future<List<LessonDB>>  getLessonsFromDB() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection("lessons").getDocuments();
    var list = querySnapshot.documents;

    this.lessonsList =  new List();
    for (var cur_row in list) {
      var data = Map<String, dynamic>.from(cur_row.data);

      QuerySnapshot querySnapshot = await Firestore.instance.
      collection("lessons").document(cur_row.documentID).
      collection("questions").getDocuments();

      var list = querySnapshot.documents;

      List<String> labels = (data["labels"] as List).map((s) => (s as String)).toList();

      LessonDB lesson = new LessonDB(data["mainVideoURL"],
          data["mainVideoName"], data["mainVideoDetails"],
          data["mainVideoStartTime"], data["mainVideoEndTime"],
          labels);
      lesson.setDBReference(cur_row.documentID);

      for (var elm in list) {
        var data = Map<String, dynamic>.from(elm.data);
        lesson.addQuestion(new QuestionDB(data["videoURL"], data["question"],
            data["answer"], data["videoStartTime"], data["videoEndTime"]));
      }

      this.lessonsList.add(lesson);
    }
    return this.lessonsList;
  }
}
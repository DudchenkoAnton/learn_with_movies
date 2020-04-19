import 'lesson_db.dart';
import 'question_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseUtilities {
  final databaseReference = Firestore.instance;
  List<LessonDB> lessonsList = new List<LessonDB>();

  Future<bool> deleteLessonFromDB(LessonDB lesson) async {
    print(lesson.getDBReference());
    var lessonReference = lesson.getDBReference();

    if (lessonReference == null) {
      return false;
    }

    try {
      databaseReference
          .collection('lessons')
          .document(lessonReference)
          .collection('questions')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
      databaseReference
          .collection('lessons')
          .document(lessonReference)
          .delete();
      return true;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<LessonDB> editLessonInDB(LessonDB lesson) async {
    this.deleteLessonFromDB(lesson);
    String documentID = await this.addLessonToDB(lesson);
    lesson.setDBReference(documentID);

    return lesson;
  }

  Future<String> addLessonToDB(LessonDB lesson) async {
    DocumentReference ref = await databaseReference.collection("lessons").add({
      'videoURL': lesson.getVideoURL(),
      'lessonName': lesson.getLessonName(),
      'videoStartPoint': lesson.getVideoStartPoint(),
      'videoEndPoint': lesson.getVideoEndPoint(),
      'labels': lesson.getLabelsList(),
      'videoID': lesson.getVideoID(),
      'numberViews': lesson.getNumberViews(),
      'averageRating': lesson.getAverageRating(),
      'numberReviews': lesson.getNumberReviews(),
    });

    for (QuestionDB question in lesson.getQuestionsList()) {
      databaseReference
          .collection('lessons')
          .document(ref.documentID)
          .collection('questions')
          .add({
        'videoURL': question.getVideoURL(),
        'question': question.getQuestion(),
        'answer': question.getAnswer(),
        'videoStartPoint': question.getVideoStartTime(),
        'videoEndPoint': question.getVideoEndTime(),
        'answerStartPoint': question.getAnswerStartTime(),
        'answerEndPoint': question.getAnswerEndTime()
      });
    }

    return ref.documentID;
  }

  LessonDB getLessonByString(String str) {
    List<String> labels1 = new List();
    labels1.add("Entertainment");

    LessonDB l1 = LessonDB(
        videoURL: "https://www.youtube.com/watch?v=xHcPhdZBngw",
        lessonName: "Friends: Top 20 Funniest Moments | TBS",
        lessonDetails: 'Pull up a couch and relax at Central Perk,'
            'where six Friends gather to talk about life '
            'and love. Friends tells the story of siblings '
            'Ross (David Schwimmer) and Monica (Courteney Cox) '
            'Geller, and their friends, Chandler Bing (Matthew Perry), '
            'Phoebe Buffay (Lisa Kudrow), Joey Tribbiani (Matt LeBlanc), '
            'and Rachel Green (Jennifer Aniston).',
        videoStartPoint: 0,
        videoEndPoint: 30,
        labelsList: labels1);

    l1.addQuestion(QuestionDB(
        videoURL: "https://www.youtube.com/watch?v=xHcPhdZBngw",
        question: "Some question",
        answer: "some answer",
        videoStartPoint: 6,
        videoEndPoint: 15));

    l1.addQuestion(QuestionDB(
        videoURL: "https://www.youtube.com/watch?v=xHcPhdZBngw",
        question: "Some question 2",
        answer: "Some answer 2",
        videoStartPoint: 18,
        videoEndPoint: 23));

    return l1;
  }

  Future<List<LessonDB>> getLessonsFromDB() async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("lessons").getDocuments();
    var arrivedLessonsList = querySnapshot.documents;

    this.lessonsList = new List();
    for (var currentRow in arrivedLessonsList) {
      var data = Map<String, dynamic>.from(currentRow.data);

      QuerySnapshot querySnapshot = await Firestore.instance
          .collection("lessons")
          .document(currentRow.documentID)
          .collection("questions")
          .getDocuments();

      var arrivedQuestionsList = querySnapshot.documents;

      List<String> labels =
          (data["labels"] as List).map((s) => (s as String)).toList();

      LessonDB lesson = LessonDB(
        videoURL: data['videoURL'],
        lessonName: data['lessonName'],
        videoStartPoint: data['videoStartPoint'],
        videoEndPoint: data['videoEndPoint'],
        labelsList: labels,
        videoID: data['videoID'],
          numberViews: data['numberViews'],
          averageRating: data['averageRating'],
          numberReviews: data['numberReviews']
      );

      lesson.setDBReference(currentRow.documentID);

      for (var elm in arrivedQuestionsList) {
        var data = Map<String, dynamic>.from(elm.data);
        lesson.addQuestion(QuestionDB(
            videoURL: data['videoURL'],
            question: data['question'],
            answer: data['answer'],
            videoStartPoint: data['videoStartPoint'],
            videoEndPoint: data['videoEndPoint'],
            answerStartPoint: data['answerStartPoint'],
            answerEndPoint: data['answerEndPoint']));
      }

      this.lessonsList.add(lesson);
    }
    return this.lessonsList;
  }
}

import 'package:firebase_auth/firebase_auth.dart';

import 'lesson_db.dart';
import 'question_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseUtilities {
  static const String MEDICINE = 'Medicine';
  static const String LAW = 'Law';
  static const String ENTERTAINMENT = 'Entertainment';
  static const String SPORT = 'Sport';
  static const String HISTORY = 'History';

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
        'americanAnswers': question.getAmericanAnswers(),
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
          numberReviews: data['numberReviews']);

      lesson.setDBReference(currentRow.documentID);

      for (var elm in arrivedQuestionsList) {
        var data = Map<String, dynamic>.from(elm.data);
        lesson.addQuestion(QuestionDB(
            videoURL: data['videoURL'],
            question: data['question'],
            answer: data['answer'],
            americanAnswers: data["americanAnswers"],
            videoStartPoint: data['videoStartPoint'],
            videoEndPoint: data['videoEndPoint'],
            answerStartPoint: data['answerStartPoint'],
            answerEndPoint: data['answerEndPoint']));
      }

      this.lessonsList.add(lesson);
    }
    return this.lessonsList;
  }

  Future<List<LessonDB>> getLessonsFromDBByViews(int lessonsNum) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("lessons")
        .orderBy("numberViews")
        .getDocuments();
    var arrivedLessonsList = querySnapshot.documents;

    this.lessonsList = new List();

    int count = 0;

    for (var currentRow in arrivedLessonsList) {
      count += 1;
      if (count > lessonsNum) {
        break;
      }
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
          numberReviews: data['numberReviews']);

      lesson.setDBReference(currentRow.documentID);

      for (var elm in arrivedQuestionsList) {
        var data = Map<String, dynamic>.from(elm.data);
        lesson.addQuestion(QuestionDB(
            videoURL: data['videoURL'],
            question: data['question'],
            answer: data['answer'],
            americanAnswers: data["americanAnswers"],
            videoStartPoint: data['videoStartPoint'],
            videoEndPoint: data['videoEndPoint'],
            answerStartPoint: data['answerStartPoint'],
            answerEndPoint: data['answerEndPoint']));
      }

      this.lessonsList.add(lesson);
    }
    return this.lessonsList;
  }

  Future<List<LessonDB>> getLessonsFromDBByRating(int lessonsNum) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("lessons")
        .orderBy("averageRating")
        .getDocuments();
    var arrivedLessonsList = querySnapshot.documents;

    this.lessonsList = new List();

    int count = 0;

    for (var currentRow in arrivedLessonsList) {
      count += 1;
      if (count > lessonsNum) {
        break;
      }
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
          numberReviews: data['numberReviews']);

      lesson.setDBReference(currentRow.documentID);

      for (var elm in arrivedQuestionsList) {
        var data = Map<String, dynamic>.from(elm.data);
        lesson.addQuestion(QuestionDB(
            videoURL: data['videoURL'],
            question: data['question'],
            answer: data['answer'],
            americanAnswers: data["americanAnswers"],
            videoStartPoint: data['videoStartPoint'],
            videoEndPoint: data['videoEndPoint'],
            answerStartPoint: data['answerStartPoint'],
            answerEndPoint: data['answerEndPoint']));
      }

      this.lessonsList.add(lesson);
    }
    return this.lessonsList;
  }

  Future<List<LessonDB>> getLessonsFromDBByString(
      String str, int lessonsNum) async {
    String lessonsNumBiggestSubstring = str + "\uF7FF";

    QuerySnapshot querySnapshot = await this
        .databaseReference
        .collection("lessons")
        .where("lessonName", isGreaterThanOrEqualTo: str)
        .where("lessonName", isLessThanOrEqualTo: lessonsNumBiggestSubstring)
        .getDocuments();
    var arrivedLessonsList = querySnapshot.documents;

    this.lessonsList = new List();

    int count = 0;

    for (var currentRow in arrivedLessonsList) {
      count += 1;
      if (count > lessonsNum) {
        break;
      }
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
          numberReviews: data['numberReviews']);

      lesson.setDBReference(currentRow.documentID);

      for (var elm in arrivedQuestionsList) {
        var data = Map<String, dynamic>.from(elm.data);
        lesson.addQuestion(QuestionDB(
            videoURL: data['videoURL'],
            question: data['question'],
            answer: data['answer'],
            americanAnswers: data["americanAnswers"],
            videoStartPoint: data['videoStartPoint'],
            videoEndPoint: data['videoEndPoint'],
            answerStartPoint: data['answerStartPoint'],
            answerEndPoint: data['answerEndPoint']));
      }

      this.lessonsList.add(lesson);
    }
    return this.lessonsList;
  }

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////// Anton Current Code - start ////////////////////////
  FirebaseUser currentUser;
  final lessonsNumber = 5;
  DocumentSnapshot lastOrderedDocument;
  DocumentSnapshot lastRecentDocument;
  String currentUserCollectionID;
  Query currentQuery;
  int lastChunkLength = -1;

  Future<bool> createUserDocument() async {
    FirebaseUser newUser = await FirebaseAuth.instance.currentUser();
    if (newUser == null) {
      print('Firebase instance returned null');
      return false;
    }

    try {
      DocumentReference ref = await databaseReference
          .collection('users')
          .add({'userID': newUser.uid});
      return true;
    } catch (e) {
      print('Error in saving the new document to users collection');
      print(e);
      return false;
    }
  }

  void addLessonToUserHistory(LessonDB watchedLesson) async {
    if (currentUser == null) {
      await initiateFirebaseUser();
    }
    await initiateCurrentCollectionID();

    await databaseReference
        .collection('users')
        .document(currentUserCollectionID)
        .collection('finished_lessons')
        .where('lessonName', isEqualTo: watchedLesson.lessonName)
        .where('videoID', isEqualTo: watchedLesson.videoID)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.length == 0) {
        databaseReference
            .collection('users')
            .document(currentUserCollectionID)
            .collection('finished_lessons')
            .add({
          'lessonName': watchedLesson.lessonName,
          'videoID': watchedLesson.videoID,
          'currentTime': DateTime.now(),
        });
      } else if (snapshot.documents.length == 1) {
        snapshot.documents[0].reference.updateData({
          'lessonName': watchedLesson.lessonName,
          'videoID': watchedLesson.videoID,
          'currentTime': DateTime.now(),
        });
      }
    });
  }

  Future<void> initiateCurrentCollectionID() async {
    if (currentUserCollectionID == null || currentUserCollectionID == '') {
      final docs = await databaseReference
          .collection('users')
          .where('userID', isEqualTo: currentUser.uid)
          .getDocuments();
      for (var document in docs.documents) {
        if (document.data['userID'] == currentUser.uid) {
          currentUserCollectionID = document.documentID;
        }
      }
    }
  }

  Future<bool> initiateFirebaseUser() async {
    try {
      currentUser = await FirebaseAuth.instance.currentUser();
      if (currentUser == null) {
        print('Firebase instance returned null');
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

//  Future<List<LessonDB>> getFirstLessonsChunk(
//    String orderBy,
//  ) async {
//    currentQuery = Firestore.instance
//        .collection("lessons")
//        .orderBy(orderBy, descending: true)
//        .limit(lessonsNumber);
//
//    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
//    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
//  }

  Future<List<LessonDB>> getFirstLessonsChunk(
      String orderBy, List<String> categories) async {
    currentQuery = Firestore.instance.collection("lessons");
    for (String category in categories) {
      print('added to query a label ----------- $category');
      currentQuery = currentQuery.where('labels', arrayContains: category);
    }
    currentQuery =
        currentQuery.orderBy(orderBy, descending: true).limit(lessonsNumber);

    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    print(
        'Length of the query snapshot array ----- ${querySnapshot.documents.length}');
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

  Future<List<LessonDB>> getNextLessonsChunk(
      String orderBy, List<String> categories) async {
    if (lastOrderedDocument == null) {
      return [];
    }

    print('A LAST DOCUMENT - ${lastOrderedDocument.data}');
    currentQuery = Firestore.instance.collection("lessons");
    for (String category in categories) {
      print('added to query a label ----------- $category');
      currentQuery = currentQuery.where('labels', arrayContains: category);
    }
    currentQuery = currentQuery
        .orderBy(orderBy, descending: true)
        .limit(lessonsNumber)
        .startAfterDocument(lastOrderedDocument);
    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

  Future<List<LessonDB>> createLessonsList(
      List<DocumentSnapshot> arrivedLessonsList, int lessonsNum) async {
//    var arrivedLessonsList = querySnapshot.documents;
    this.lessonsList = new List();

    int count = 0;

    for (var currentRow in arrivedLessonsList) {
      count += 1;
      if (count > lessonsNum) {
        break;
      }
      if (count == arrivedLessonsList.length) {
        print('got a new last lecture - ${currentRow.data}');
        lastOrderedDocument = currentRow;
      }

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
          numberReviews: data['numberReviews']);

      lesson.setDBReference(currentRow.documentID);

      for (var elm in arrivedQuestionsList) {
        var data = Map<String, dynamic>.from(elm.data);
        lesson.addQuestion(QuestionDB(
            videoURL: data['videoURL'],
            question: data['question'],
            answer: data['answer'],
            americanAnswers: data["americanAnswers"],
            videoStartPoint: data['videoStartPoint'],
            videoEndPoint: data['videoEndPoint'],
            answerStartPoint: data['answerStartPoint'],
            answerEndPoint: data['answerEndPoint']));
      }

      this.lessonsList.add(lesson);
    }
    if (this.lessonsList.length == 0) {
      lastOrderedDocument = null;
    }
    return this.lessonsList;
  }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

  Future<List<LessonDB>> getRecentLessonsChunk(bool refresh) async {
    if (lastChunkLength >= 0 && lastChunkLength < 5 && !refresh) {
      return [];
    }
    if (currentUser == null) {
      await initiateFirebaseUser();
    }
    if (currentUserCollectionID == null) {
      await initiateCurrentCollectionID();
    }
    Query tempQuery = await Firestore.instance
        .collection('users')
        .document(currentUserCollectionID)
        .collection('finished_lessons')
        .orderBy('currentTime');
    if (lastRecentDocument != null && !refresh) {
      tempQuery = tempQuery.startAfterDocument(lastRecentDocument);
    }
    QuerySnapshot finishedLessonsQuerySnapshot =
        await tempQuery.limit(lessonsNumber).getDocuments();

    if (finishedLessonsQuerySnapshot.documents.length > 0) {
      lastRecentDocument = finishedLessonsQuerySnapshot
          .documents[finishedLessonsQuerySnapshot.documents.length - 1];
      lastChunkLength = finishedLessonsQuerySnapshot.documents.length;
      List<DocumentSnapshot> listOfLessons =
          await getHistoryLessonsData(finishedLessonsQuerySnapshot);
      return createLessonsList(listOfLessons, lessonsNumber);
    } else {
      return [];
    }
  }

  Future<List<DocumentSnapshot>> getHistoryLessonsData(
      QuerySnapshot finishedLessonsQuerySnapshot) async {
    List<DocumentSnapshot> listOfLessons = new List<DocumentSnapshot>();
    for (var currentRow in finishedLessonsQuerySnapshot.documents) {
      QuerySnapshot temp = await Firestore.instance
          .collection('lessons')
          .where('lessonName', isEqualTo: currentRow.data['lessonName'])
          .getDocuments();
      listOfLessons.add(temp.documents[0]);
    }
    return listOfLessons;
  }

// Anton Current Code - end
}

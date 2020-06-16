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
  static const String MUSIC = 'Music';
  bool firstChunk = true;
  final databaseReference = Firestore.instance;
  List<LessonDB> lessonsList = new List<LessonDB>();
  FirebaseUser currentUser;
  final lessonsNumber = 5;
  DocumentSnapshot lastOrderedLessonDocument;
  DocumentSnapshot lastOrderedDraftDocument;
  DocumentSnapshot lastRecentLessonDocument;
  String currentUserCollectionID;
  Query currentQuery;
  int lastChunkLength = -1;

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
      databaseReference.collection('lessons').document(lessonReference).delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateLessonRatingAndViews(LessonDB lesson) async {
    DocumentSnapshot snapshot = await databaseReference.collection('lessons').document(lesson.getDBReference()).get();
    if (snapshot != null) {
      snapshot.reference.updateData({
        'averageRating': lesson.getAverageRating(),
        'numberReviews': lesson.getNumberReviews(),
        'numberViews': lesson.getNumberViews(),
      });
    }
  }

  Future<bool> updateNumberViews(LessonDB lesson) async {
    DocumentSnapshot snapshot = await databaseReference.collection('lessons').document(lesson.getDBReference()).get();
    if (snapshot != null) {
      snapshot.reference.updateData({
        'numberViews': lesson.getNumberViews(),
      });
    }
  }

  Future<bool> editLessonInDB(LessonDB lesson) async {
    if (currentUser == null) {
      await initiateFirebaseUser();
    }
    List<String> subStrings = generateSubStrings(lesson.getLessonName());
    DocumentSnapshot snapshot = await databaseReference.collection('lessons').document(lesson.getDBReference()).get();
    if (snapshot != null) {
      snapshot.reference.updateData({
        'videoURL': lesson.getVideoURL(),
        'lessonName': lesson.getLessonName(),
        'videoStartPoint': lesson.getVideoStartPoint(),
        'videoEndPoint': lesson.getVideoEndPoint(),
        'labels': lesson.getLabelsList(),
        'videoID': lesson.getVideoID(),
        'numberViews': lesson.getNumberViews(),
        'averageRating': lesson.getAverageRating(),
        'numberReviews': lesson.getNumberReviews(),
        'originalVideoLength': lesson.getOriginalVideoLength(),
        'searchSubStringsArray': subStrings,
        'searchSubStringsLength': subStrings.length,
      });

      QuerySnapshot existingQuestions = await databaseReference
          .collection('lessons')
          .document(lesson.getDBReference())
          .collection('questions')
          .getDocuments();

      for (var currentRow in existingQuestions.documents) {
        await currentRow.reference.delete();
      }
      for (QuestionDB question in lesson.getQuestionsList()) {
        databaseReference.collection('lessons').document(lesson.getDBReference()).collection('questions').add({
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

      return true;
    } else {
      return false;
    }
  }

  Future<String> addLessonToDB(LessonDB lesson) async {
    if (currentUser == null) {
      bool gotCurrentUser = await initiateFirebaseUser();
      if (!gotCurrentUser) return '';
    }

    String userID = currentUser.uid;
    List<String> subStrings = generateSubStrings(lesson.getLessonName());
    DateTime now = DateTime.now();
    String currentDate = now.toIso8601String();

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
      'originalVideoLength': lesson.getOriginalVideoLength(),
      'creatorUserID': userID,
      'creationDate': currentDate,
      'searchSubStringsArray': subStrings,
      'searchSubStringsLength': subStrings.length,
    });

    for (QuestionDB question in lesson.getQuestionsList()) {
      databaseReference.collection('lessons').document(ref.documentID).collection('questions').add({
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

  List<String> generateSubStrings(String name) {
    List<String> parsedName = name.toLowerCase().split(' ');
    List<String> resultingList = name.toLowerCase().split(' ');
    resultingList.add(generateFormattedName(name));
    for (int i = 0; i < parsedName.length; i++) {
      for (int y = i + 1; y < parsedName.length; y++) {
        resultingList.add('${parsedName[i]} ${parsedName[y]}');
      }
    }
    for (var str in parsedName) {
      for (int i = 2; i < str.length; i++) {
        resultingList.add(str.substring(0, i));
      }
    }

    return resultingList;
  }

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////// Anton Current Code - start ////////////////////////

  Future<bool> createUserDocument() async {
    FirebaseUser newUser = await FirebaseAuth.instance.currentUser();
    if (newUser == null) {
      print('Firebase instance returned null');
      return false;
    }

    try {
      DocumentReference ref = await databaseReference.collection('users').add({'userID': newUser.uid});
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
        databaseReference.collection('users').document(currentUserCollectionID).collection('finished_lessons').add({
          'lessonName': watchedLesson.lessonName,
          'videoID': watchedLesson.videoID,
          'currentTime': DateTime.now(),
          'lessonID': watchedLesson.getDBReference(),
        });
      } else if (snapshot.documents.length == 1) {
        snapshot.documents[0].reference.updateData({
          'lessonName': watchedLesson.lessonName,
          'videoID': watchedLesson.videoID,
          'currentTime': DateTime.now(),
          'lessonID': watchedLesson.getDBReference(),
        });
      }
    });
  }

  Future<void> initiateCurrentCollectionID() async {
    if (currentUserCollectionID == null || currentUserCollectionID == '') {
      final docs =
          await databaseReference.collection('users').where('userID', isEqualTo: currentUser.uid).getDocuments();
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

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

  String generateFormattedName(String lessonName) {
    String formattedName = '';
    List<String> formattedList = lessonName.toLowerCase().split(' ');
    for (int i = 0; i < formattedList.length; i++) {
      if (i == 0) {
        formattedName = formattedList[i];
      } else {
        formattedName = formattedName + ' ' + formattedList[i];
      }
    }

    return formattedName;
  }

  void generateLessonsSearchQuery(String lessonName, List<String> categories, bool onlyUserCreatedLessons) {
    String formattedName = generateFormattedName(lessonName);

    currentQuery = Firestore.instance.collection("lessons");
    if (onlyUserCreatedLessons) currentQuery = currentQuery.where('creatorUserID', isEqualTo: currentUser.uid);
    if (categories.length != 0) currentQuery = currentQuery.where('labels', arrayContains: categories[0]);
    currentQuery = currentQuery.where("searchSubStringsArray", arrayContains: formattedName);
    if (onlyUserCreatedLessons) {
      currentQuery = currentQuery.orderBy('searchSubStringsLength', descending: false).limit(lessonsNumber);
    } else {
      currentQuery = currentQuery.orderBy('averageRating', descending: true).limit(lessonsNumber);
    }
  }

  Future<List<LessonDB>> searchLessonsFirstChunk(String lessonName, List<String> categories) async {
    generateLessonsSearchQuery(lessonName, categories, false);
    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

  Future<List<LessonDB>> searchLessonsNextChunk(String lessonName, List<String> categories) async {
    generateLessonsSearchQuery(lessonName, categories, false);
    currentQuery = currentQuery.startAfterDocument(lastOrderedLessonDocument);

    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

  Future<void> generateDraftsSearchQuery(String lessonName, List<String> categories) async {
    String formattedName = generateFormattedName(lessonName);

    DocumentReference userDocReference = await getUserDocumentReference();
    if (userDocReference == null) return;

    currentQuery = userDocReference.collection("drafts");
    if (categories.length != 0) currentQuery = currentQuery.where('labels', arrayContains: categories[0]);
    currentQuery = currentQuery.where("searchSubStringsArray", arrayContains: formattedName);
    currentQuery = currentQuery.orderBy('searchSubStringsLength', descending: false).limit(lessonsNumber);
  }

  Future<List<LessonDB>> searchUserLessonsFirstChunk(String lessonName, List<String> categories) async {
    if (currentUser == null) {
      bool gotCurrentUser = await initiateFirebaseUser();
      if (!gotCurrentUser) return [];
    }

    generateLessonsSearchQuery(lessonName, categories, true);
    QuerySnapshot lessonsQuerySnapshot = await currentQuery.getDocuments();
//    return (await createLessonsList(lessonsQuerySnapshot.documents, lessonsNumber));

    await generateDraftsSearchQuery(lessonName, categories);
    QuerySnapshot draftsQuerySnapshot = await currentQuery.getDocuments();

    return (await generateUserLessonsList(lessonsQuerySnapshot.documents, draftsQuerySnapshot.documents));
  }

  Future<List<LessonDB>> searchUserLessonsNextChunk(String lessonName, List<String> categories) async {
    generateLessonsSearchQuery(lessonName, categories, true);
    if (lastOrderedLessonDocument != null) currentQuery = currentQuery.startAfterDocument(lastOrderedLessonDocument);
    QuerySnapshot querySnapshot = await currentQuery.getDocuments();

    await generateDraftsSearchQuery(lessonName, categories);
    if (lastOrderedDraftDocument != null) currentQuery = currentQuery.startAfterDocument(lastOrderedDraftDocument);
    QuerySnapshot draftsQuerySnapshot = await currentQuery.getDocuments();

    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

  Future<List<LessonDB>> generateUserLessonsList(List<DocumentSnapshot> lessons, List<DocumentSnapshot> drafts) async {
    int length = 0, i = 0, j = 0;
    List<LessonDB> lessonsList = await createLessonsList(lessons, lessonsNumber);
    List<LessonDB> draftsList = await createLessonsList(drafts, lessonsNumber);
    List<LessonDB> resultingList = new List();

    while (length < lessonsNumber) {
      if (i < lessonsList.length && j < draftsList.length) {
        if (lessonsList[i].searchArrayLength > draftsList[j].searchArrayLength) {
          resultingList.add(lessonsList[i]);
          i++;
        } else {
          draftsList[j].isDraft = true;
          resultingList.add(draftsList[j]);
          j++;
        }
      } else if (i >= lessonsList.length && j < draftsList.length) {
        draftsList[j].isDraft = true;
        resultingList.add(draftsList[j]);
        j++;
      } else if (i < lessonsList.length && j >= draftsList.length) {
        resultingList.add(lessonsList[i]);
        i++;
      }
      length++;
    }

    if (lessons.length > 0) {
      i < lessons.length
          ? lastOrderedLessonDocument = lessons[i]
          : lastOrderedLessonDocument = lessons[lessons.length - 1];
    } else {
      lastOrderedLessonDocument = null;
    }
    if (drafts.length > 0) {
      j < drafts.length ? lastOrderedDraftDocument = drafts[j] : lastOrderedDraftDocument = drafts[drafts.length - 1];
    } else {
      lastOrderedDraftDocument = null;
    }

    return resultingList;
  }

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

  void generateUserCreatorQuery(String orderBy, List<String> categories) {
    currentQuery = Firestore.instance.collection("lessons").where('creatorUserID', isEqualTo: currentUser.uid);
    if (categories.length != 0) currentQuery = currentQuery.where('labels', arrayContains: categories[0]);
    currentQuery = currentQuery.orderBy(orderBy, descending: true).limit(lessonsNumber);
  }

  Future<List<LessonDB>> getFirstUserLessonsChunk(String orderBy, List<String> categories) async {
    if (currentUser == null) {
      bool gotCurrentUser = await initiateFirebaseUser();
      if (!gotCurrentUser) return [];
    }

    generateUserCreatorQuery(orderBy, categories);
    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

  Future<List<LessonDB>> getNextUserLessonsChunk(String orderBy, List<String> categories) async {
    if (lastOrderedLessonDocument == null) {
      return [];
    }

    generateUserCreatorQuery(orderBy, categories);
    currentQuery = currentQuery.startAfterDocument(lastOrderedLessonDocument);
    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

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

  Future<List<LessonDB>> getFirstLessonsChunk(String orderBy, List<String> categories) async {
    currentQuery = Firestore.instance.collection("lessons");
    if (categories.length != 0) currentQuery = currentQuery.where('labels', arrayContains: categories[0]);
    currentQuery = currentQuery.orderBy(orderBy, descending: true).limit(lessonsNumber);

    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

  Future<List<LessonDB>> getNextLessonsChunk(String orderBy, List<String> categories) async {
    if (lastOrderedLessonDocument == null) {
      return [];
    }

    currentQuery = Firestore.instance.collection("lessons");
    if (categories.length != 0) currentQuery = currentQuery.where('labels', arrayContains: categories[0]);
    currentQuery = currentQuery
        .orderBy(orderBy, descending: true)
        .limit(lessonsNumber)
        .startAfterDocument(lastOrderedLessonDocument);
    QuerySnapshot querySnapshot = await currentQuery.getDocuments();
    return (await createLessonsList(querySnapshot.documents, lessonsNumber));
  }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

  Future<List<LessonDB>> createLessonsList(List<DocumentSnapshot> arrivedLessonsList, int lessonsNum) async {
//    var arrivedLessonsList = querySnapshot.documents;
    List<LessonDB> lessonsList = new List();

    int count = 0;

    for (var currentRow in arrivedLessonsList) {
      count += 1;
      if (count > lessonsNum) {
        break;
      }
      if (count == arrivedLessonsList.length) {
        lastOrderedLessonDocument = currentRow;
      }

      var data = Map<String, dynamic>.from(currentRow.data);
      QuerySnapshot querySnapshot = await Firestore.instance
          .collection("lessons")
          .document(currentRow.documentID)
          .collection("questions")
          .getDocuments();

      var arrivedQuestionsList = querySnapshot.documents;

      List<String> labels = (data["labels"] as List).map((s) => (s as String)).toList();

      LessonDB lesson = LessonDB(
        videoURL: data['videoURL'],
        lessonName: data['lessonName'],
        videoStartPoint: data['videoStartPoint'],
        videoEndPoint: data['videoEndPoint'],
        labelsList: labels,
        videoID: data['videoID'],
        numberViews: data['numberViews'],
        averageRating: data['averageRating'],
        numberReviews: data['numberReviews'],
        originalVideoLength: data['originalVideoLength'],
        creationDate: data['creationDate'],
      );

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

      lessonsList.add(lesson);
    }
    if (lessonsList.length == 0) {
      lastOrderedLessonDocument = null;
    }
    return lessonsList;
  }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

  Future<List<LessonDB>> getRecentLessonsChunk(bool refresh) async {
    if (lastChunkLength >= 0 && lastChunkLength < lessonsNumber && !refresh) {
      return [];
    }

    Query tempQuery = await generateFinishedLessonsQuery();
    if (lastRecentLessonDocument != null && !refresh) {
      tempQuery = tempQuery.startAfterDocument(lastRecentLessonDocument);
    }
    QuerySnapshot finishedLessonsQuerySnapshot = await tempQuery.limit(lessonsNumber).getDocuments();
    int finishedLength = finishedLessonsQuerySnapshot.documents.length;

    if (finishedLessonsQuerySnapshot.documents.length == 0) return [];

    List<DocumentSnapshot> listOfLessons = await getHistoryLessonsData(finishedLessonsQuerySnapshot);
    if (listOfLessons.length < finishedLength) {
      listOfLessons.addAll(await getMissedLessons(finishedLength - listOfLessons.length));
    }

    lastChunkLength = listOfLessons.length;
    return createLessonsList(listOfLessons, lessonsNumber);
  }

  Future<Query> generateFinishedLessonsQuery() async {
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

    return tempQuery;
  }

  Future<List<DocumentSnapshot>> getMissedLessons(int numberOfLessons) async {
    Query tempQuery = await generateFinishedLessonsQuery();
    if (lastRecentLessonDocument != null) {
      tempQuery = tempQuery.startAfterDocument(lastRecentLessonDocument);
    }
    QuerySnapshot tempSnapshot = await tempQuery.limit(lessonsNumber * 2).getDocuments();
    List<DocumentSnapshot> listOfLessons = await getHistoryLessonsData(tempSnapshot);
    if (listOfLessons.length < numberOfLessons) {
      listOfLessons.addAll(await getMissedLessons(numberOfLessons - listOfLessons.length));
    }

    return listOfLessons;
  }

  Future<List<DocumentSnapshot>> getHistoryLessonsData(QuerySnapshot finishedLessonsQuerySnapshot) async {
    List<DocumentSnapshot> listOfLessons = new List<DocumentSnapshot>();
    List<String> historyToDelete = new List<String>();

    for (int i = 0; i < finishedLessonsQuerySnapshot.documents.length; i++) {
      var currentRow = finishedLessonsQuerySnapshot.documents[i];
      QuerySnapshot temp = await Firestore.instance
          .collection('lessons')
          .where('lessonName', isEqualTo: currentRow.data['lessonName'])
          .getDocuments();
      if (temp.documents.length > 0) {
        lastRecentLessonDocument = currentRow;
        listOfLessons.add(temp.documents[0]);
      } else {
        historyToDelete.add(currentRow.documentID);
      }
    }

    deleteRedundantHistory(historyToDelete);
    return listOfLessons;
  }

  void deleteRedundantHistory(List<String> historyToDelete) async {
    for (String id in historyToDelete) {
      await databaseReference
          .collection('users')
          .document(currentUserCollectionID)
          .collection('finished_lessons')
          .document(id)
          .delete();
    }
  }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

  Future<List<String>> getWatchedLessonIDs() async {
    List<String> lessonsIDsArray = List<String>();
    Query tempQuery = await generateFinishedLessonsQuery();
    QuerySnapshot finishedLessonsQuerySnapshot = await tempQuery.getDocuments();
    for (var currentRow in finishedLessonsQuerySnapshot.documents) {
      lessonsIDsArray.add(currentRow.data['lessonID']);
    }

    return lessonsIDsArray;
  }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

  Future<DocumentReference> getUserDocumentReference() async {
    if (currentUser == null) await initiateFirebaseUser();

    QuerySnapshot querySnapshot =
        await databaseReference.collection("users").where('userID', isEqualTo: currentUser.uid).getDocuments();
    if (querySnapshot.documents.length == 0) return null;

    DocumentReference userDocumentRef = querySnapshot.documents[0].reference;

    return userDocumentRef;
  }

  Future<String> addDraftToDB(LessonDB lesson) async {
    if (currentUser == null) {
      bool gotCurrentUser = await initiateFirebaseUser();
      if (!gotCurrentUser) return '';
    }

    String userID = currentUser.uid;
    List<String> subStrings = generateSubStrings(lesson.getLessonName());
    DateTime now = DateTime.now();
    String currentDate = now.toIso8601String();

    DocumentReference userDocReference = await getUserDocumentReference();
    if (userDocReference == null) return null;

    DocumentReference ref = await userDocReference.collection('drafts').add({
      'videoURL': lesson.getVideoURL(),
      'lessonName': lesson.getLessonName(),
      'videoStartPoint': lesson.getVideoStartPoint(),
      'videoEndPoint': lesson.getVideoEndPoint(),
      'labels': lesson.getLabelsList(),
      'videoID': lesson.getVideoID(),
      'originalVideoLength': lesson.getOriginalVideoLength(),
      'creationDate': currentDate,
      'searchSubStringsArray': subStrings,
      'searchSubStringsLength': subStrings.length,
    });

    for (QuestionDB question in lesson.getQuestionsList()) {
      userDocReference.collection('drafts').document(ref.documentID).collection('questions').add({
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

  Future<bool> deleteDraftFromDB(LessonDB lesson) async {
    print(lesson.getDBReference());
    var lessonReference = lesson.getDBReference();
    DocumentReference userDocReference = await getUserDocumentReference();

    if (lessonReference == null) return false;
    if (userDocReference == null) return null;

    try {
      userDocReference
          .collection('drafts')
          .document(lessonReference)
          .collection('questions')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
      userDocReference.collection('drafts').document(lessonReference).delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> editDraftInDB(LessonDB lesson) async {
    DocumentReference userDocReference = await getUserDocumentReference();
    if (userDocReference == null) return null;

    List<String> subStrings = generateSubStrings(lesson.getLessonName());

    DocumentSnapshot snapshot = await userDocReference.collection('drafts').document(lesson.getDBReference()).get();
    if (snapshot != null) {
      snapshot.reference.updateData({
        'videoURL': lesson.getVideoURL(),
        'lessonName': lesson.getLessonName(),
        'videoStartPoint': lesson.getVideoStartPoint(),
        'videoEndPoint': lesson.getVideoEndPoint(),
        'labels': lesson.getLabelsList(),
        'videoID': lesson.getVideoID(),
        'originalVideoLength': lesson.getOriginalVideoLength(),
        'searchSubStringsArray': subStrings,
        'searchSubStringsLength': subStrings.length,
      });

      QuerySnapshot existingQuestions = await userDocReference
          .collection('drafts')
          .document(lesson.getDBReference())
          .collection('questions')
          .getDocuments();

      for (var currentRow in existingQuestions.documents) {
        await currentRow.reference.delete();
      }
      for (QuestionDB question in lesson.getQuestionsList()) {
        userDocReference.collection('drafts').document(lesson.getDBReference()).collection('questions').add({
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

      return true;
    } else {
      return false;
    }
  }

  Future<List<LessonDB>> getDraftsFromDB() async {
    DocumentReference userDocReference = await getUserDocumentReference();
    if (userDocReference == null) return null;

    QuerySnapshot querySnapshot = await userDocReference.collection('drafts').getDocuments();
    var arrivedLessonsList = querySnapshot.documents;

    List<LessonDB> lessonsList = new List();
    for (var currentRow in arrivedLessonsList) {
      var data = Map<String, dynamic>.from(currentRow.data);

      QuerySnapshot querySnapshot = await userDocReference
          .collection('drafts')
          .document(currentRow.documentID)
          .collection("questions")
          .getDocuments();

      var arrivedQuestionsList = querySnapshot.documents;

      List<String> labels = (data["labels"] as List).map((s) => (s as String)).toList();

      LessonDB lesson = LessonDB(
        videoURL: data['videoURL'],
        lessonName: data['lessonName'],
        videoStartPoint: data['videoStartPoint'],
        videoEndPoint: data['videoEndPoint'],
        labelsList: labels,
        videoID: data['videoID'],
        originalVideoLength: data['originalVideoLength'],
        isDraft: true,
        questionsList: [],
      );

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

      lessonsList.add(lesson);
    }
    return lessonsList;
  }

// Anton Current Code - end
}

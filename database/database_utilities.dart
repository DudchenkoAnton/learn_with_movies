import 'lesson_db.dart';
import 'question_db.dart';

class DatabaseUtilities {

  void addLessonToDB(LessonDB lesson) {
    // implementation shall be supplied in advance.
  }

  List<LessonDB> getLessonsFromDB() {
    List<LessonDB> lessonsList =  new List();

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

    LessonDB l2 = new LessonDB("https://www.youtube.com/watch?v=Xvv4JB3rXsA",
        "Best Comebacks | House M.D.",
        "Some of the best comebacks, replies and insults dealt "
            "by Dr. Gregory House!",
        1,
        5,
        labels1);

    l2.addQuestion(
        new QuestionDB("https://www.youtube.com/watch?v=Xvv4JB3rXsA",
            "Some question ?",
            "Some answer",
            1.32,
            2.42)
    );

    l2.addQuestion(
        new QuestionDB("https://www.youtube.com/watch?v=Xvv4JB3rXsA",
            "Some question 2 ?",
            "Some answer 2",
            3.11,
            4.47)
    );

    lessonsList.add(l1);
    lessonsList.add(l2);
    
    return lessonsList;
  }

}
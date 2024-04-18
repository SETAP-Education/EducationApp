import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Quizzes/quiz.dart';

// Quizzes are stored under the quizzes collection in the database

class QuizManager {
  // Searches for quizzes with the specified tags
  // Returns an empty list if none exist
  Future<List<Quiz>> getQuizzesWithTags(List<String> tags) {
    return Future(() => List.empty());
  }

  // Returns the quiz with the specified ID
  // Returns null if the quiz is not found
  Future<Quiz?> getQuizWithId(String id) async {
    var db = FirebaseFirestore.instance;

    // Grab the object with a converter
    var quizRef = await db
        .collection("quizzes")
        .doc(id)
        .withConverter(
            fromFirestore: Quiz.fromFirestore,
            toFirestore: (Quiz quiz, _) => quiz.toFirestore())
        .get();

    // Test if the quiz exists
    // If it doesn't return null
    if (!quizRef.exists) {
      return Future(() => null);
    }

    return Future(() => quizRef.data());
  }

  // Returns the quiz from the sharecode.
  // Returns null if the quiz does not exist
  Future<Quiz?> getQuizFromShareCode(String shareCode) async {
    var db = FirebaseFirestore.instance;

    // This is a simple query
    var quiz = await db
        .collection("quizzes")
        .where("shareCode", isEqualTo: shareCode)
        .withConverter(
            fromFirestore: Quiz.fromFirestore,
            toFirestore: (Quiz quiz, _) => quiz.toFirestore())
        .get();

    if (quiz.docs.isNotEmpty) {
      // We found a quiz with this sharecode

      // It should only get 1 so return the first in the array
      return quiz.docs[0].data();
    }

    // If we reach this point just return null
    return Future(() => null);
  }

  // Returns the question with a specific ID
  // Returns null if the question doesn't exist
  Future<QuizQuestion?> getQuizQuestionById(String id) async {
    var db = FirebaseFirestore.instance;

    var questionRef = await db
        .collection("questions")
        .doc(id)
        .withConverter(
            fromFirestore: QuizQuestion.fromFirestore,
            toFirestore: (QuizQuestion q, _) => q.toFirestore())
        .get();

    if (!questionRef.exists) {
      return null;
    }

    return questionRef.data();
  }

  // Returns a list of questions with tags matching the specified tags
  Future<List<QuizQuestion>> getQuizQuestionsByTags(List<String> tags) async {
    var db = FirebaseFirestore.instance;

    var questionRef = await db
        .collection("questions")
        .where("tags", arrayContainsAny: tags)
        .withConverter(
            fromFirestore: QuizQuestion.fromFirestore,
            toFirestore: (QuizQuestion q, _) => q.toFirestore())
        .get();

    return List.generate(
        questionRef.docs.length, (index) => questionRef.docs[index].data());
  }


  // Returns an empty list if no questions that match are found
  // Warning: Don't use this unless you absolutely must
  // This returns all quiz questions in the database
  // AND IS SLOW
  Future<List<QuizQuestion>> getQuizQuestions() async {
    var db = FirebaseFirestore.instance;

    var questionRef = await db
        .collection("questions")
        .withConverter(
            fromFirestore: QuizQuestion.fromFirestore,
            toFirestore: (QuizQuestion q, _) => q.toFirestore())
        .get();

    return List.generate(
        questionRef.docs.length, (index) => questionRef.docs[index].data());
  }

  static void addQuizQuestionToDatabase(QuizQuestion question) {
    var db = FirebaseFirestore.instance;

    db.collection("questions").doc().set(question.toFirestore());
  }

  static Future<String> addQuizToDatabase(String name, String creator, List<String> questionIds) async {

    var db = FirebaseFirestore.instance;

    Quiz quiz = Quiz();
    quiz.creator = creator; 
    quiz.questionIds = questionIds;
    quiz.name = name;
    
    var doc = db.collection("quizzes").doc();
    quiz.shareCode = doc.path;

    await doc.set(quiz.toFirestore());

    return doc.id;

  }

  

   Future<String> generateQuiz(List<String> tags, int userLevel, int range, int questionCount) async {

    print("Quiz Generating...");

    String outputQuizId = "";

    var db = FirebaseFirestore.instance;

    // This returns all questions that fit 
    var questionRef = await db
        .collection("questions")
        .where("tags", arrayContainsAny: tags)
        .where("difficulty", isGreaterThan: (userLevel - range))
        .where("difficulty", isLessThan: (userLevel + range))
        .withConverter(
            fromFirestore: QuizQuestion.fromFirestore,
            toFirestore: (QuizQuestion q, _) => q.toFirestore())
        .get();

    // TODO: make this more efficient
    var questions = List.generate(
        questionRef.docs.length, (index) => questionRef.docs[index].data());

   

    print("Number of questions found: ${questions.length}");

    // we have a list of questions that match the parameters 
    // We want to get a random questions from this list

    List<int> questionNumbers = List.empty(growable: true);

    if (questions.length < questionCount) {
      // If the questions that match are less than the questionCount we just want to return 
      // all the questions from the query 

      print("Not enough questions found, just adding the ones we have");

      for (int i = 0; i < questions.length; i++) {
        questionNumbers.add(i);
      }

      // Shuffle the questions 
      questionNumbers.shuffle();

    }
    else {

      print("Randomly picking Questions");
      
      var rng = Random();
      for (int i = 0; i < questionCount; i++) {
        var j = rng.nextInt(questions.length);

        while (questionNumbers.contains(j)) {
          j = rng.nextInt(questions.length);
        }

        print("Added question ${j}");
        questionNumbers.add(j);
      }
    }

    List<String> questionIds = List.generate(questionNumbers.length, (index) {
      return questions[questionNumbers[index]].questionId;
    });

    //print(l.map((e) => e.debugPrint()));

    outputQuizId = await addQuizToDatabase("", "System", questionIds);

    print(outputQuizId);

    return outputQuizId;
  }

}

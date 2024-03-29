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

  void writeQuizQuestionToDb(QuizQuestion question) {
    
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
}

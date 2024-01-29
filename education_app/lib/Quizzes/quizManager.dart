

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
    var quizRef = await db.collection("quizzes").doc(id)
      .withConverter(fromFirestore: Quiz.fromFirestore, toFirestore: (Quiz quiz, _) => quiz.toFirestore())
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
  Future<Quiz?> getQuizFromShareCode(String shareCode) {

    return Future(() => null);
  }
  
}
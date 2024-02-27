import 'package:flutter/material.dart';

class QuizSummaryPage extends StatelessWidget {
  final Map<String, dynamic> quizSummary;

  QuizSummaryPage({required this.quizSummary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Summary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quiz Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            for (var entry in quizSummary.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question ID: ${entry.key}"),
                  Text("Correct/Incorrect: ${entry.value['correctIncorrect']}"),
                  Text("User Response: ${entry.value['userResponse']}"),
                  SizedBox(height: 16),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

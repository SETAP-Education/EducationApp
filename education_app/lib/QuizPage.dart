import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(30.0),
              width: MediaQuery.of(context).size.width * 0.4,
              color: Colors.grey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      //margin: const EdgeInsets.symmetric(vertical: 220.0),
                      child: const Text(
                        'Available: ',
                      )
                  ),
                  Container(
                      //margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                      child: const Text(
                        'Test 1',
                      )
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30.0),
              width: MediaQuery.of(context).size.width * 0.4,
              color: Colors.grey,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Test 2'),
                  Text('Test 3'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
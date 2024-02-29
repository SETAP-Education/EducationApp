
import 'package:flutter/material.dart';

class QuizBuilder extends StatefulWidget {

  const QuizBuilder({ super.key });

  @override 
  State<QuizBuilder> createState() => QuizBuilderState(); 

}

class QuizBuilderState extends State<QuizBuilder> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(onPressed: (){}, child: Text("Add to Database"))
            ],)
        )
      )
    );
  }
}
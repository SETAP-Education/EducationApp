
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Widgets/QuestionCard.dart';
import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quizManager.dart';

class QuizBuilder extends StatefulWidget {

  const QuizBuilder({ super.key });

  @override 
  State<QuizBuilder> createState() => QuizBuilderState(); 

}

class QuizBuilderState extends State<QuizBuilder> {

  QuizManager quizManager = QuizManager();

  Quiz currentQuiz = Quiz(); 

  @override
  void initState() {
    super.initState();

    loadQuestionCards("");
  }

  void loadQuestionCards(String tags) {
    
    quizManager.getQuizQuestions().then((value) {
      questionWidgets = List.generate(value.length, (index) {
        print("Loaded Question: ${value[index].questionText}");
        return QuestionCard(question: value[index]);
      });

      setState(() {
        
      });
    });
  }

  List<Widget> questionWidgets = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 243, 242, 242),
            borderRadius: BorderRadius.circular(15)
          ),
          width: double.infinity,
          child: Row(
            children: [

              SizedBox(
                width: 50, 
                height: double.infinity,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  const SizedBox(height: 8.0),

                  Tooltip(
                    verticalOffset: 10,
                    message: "Create a new Quiz",
                    child: IconButton(
                      onPressed: (){},
                      icon: Icon(Icons.quiz),
                    )
                  ),

                  const SizedBox(height: 16), 

                  Tooltip(
                    verticalOffset: 10,
                    message: "Add a new question",
                    child: IconButton(
                      onPressed: (){},
                      icon: Icon(Icons.add),
                    )
                  )
                ],
              )),

              const VerticalDivider(
                width: 0,
                thickness: 2,
              ),

              SizedBox(
                width: 300, 
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Scrollbar( 
                    child: SingleChildScrollView(
                      child: Column(
                        children: questionWidgets 
                      )
                    )
                  )
                )
              ),

              const VerticalDivider(
                width: 0,
                thickness: 2,
              ),
            ],
          )
        )
      )
    
    );
  }
}
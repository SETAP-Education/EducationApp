
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Widgets/QuestionCard.dart';
import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quizManager.dart';

// Yes I know this is long... 
// TODO: Now make as long
class MultipleChoiceQuestionAnswerBuilder extends StatefulWidget {

  MultipleChoiceQuestionAnswerBuilder({ super.key, required this.controller, required this.onChanged, required this.remove  });

  final TextEditingController controller; 
  final Function(bool) onChanged;
  final Function remove; 

  @override 
  State<MultipleChoiceQuestionAnswerBuilder> createState() => MultipleChoiceQuestionAnswerBuilderState(); 
}

class MultipleChoiceQuestionAnswerBuilderState extends State<MultipleChoiceQuestionAnswerBuilder> {

  bool correctAnswer = false; 

  @override
  Widget build(BuildContext) {
    return  Row(children: [
        SizedBox(
          width: 200,
          height: 50,
          child: TextField(
            controller: widget.controller,
        )),
        Checkbox(value: correctAnswer, onChanged: (value) { setState(() {
          correctAnswer = value!; 
          widget.onChanged(correctAnswer);
        }); }),
        IconButton(onPressed: () { widget.remove(); }, icon: Icon(Icons.close))
      ],
      );
  }
}

class QuestionBuilder extends StatefulWidget {

  @override
  State<QuestionBuilder> createState() => QuestionBuilderState(); 
}

class Tuple<T1, T2> {
   T1 item1;
   T2 item2;

  Tuple(this.item1, this.item2);
}


class QuestionBuilderState extends State<QuestionBuilder> {

  TextEditingController questionController = TextEditingController();
  QuestionType selectedItem = QuestionType.none;

  List<Tuple<TextEditingController, bool>> multipleChoiceAnswers = List.empty(growable: true);

  List<Widget> buildMultipleChoiceAnswers() {
  return List.generate(multipleChoiceAnswers.length, (index) {

    return MultipleChoiceQuestionAnswerBuilder(
      controller: multipleChoiceAnswers[index].item1,
      onChanged: (v) { multipleChoiceAnswers[index].item2 = v; },
      remove: () { 
        setState(() {
          multipleChoiceAnswers.removeAt(index);
        });
      },
    );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 600, 
            height: 50,
            child:  TextField(
              controller: questionController,
              decoration: InputDecoration(
                hintText: "Question",
              ),
            ),
          ),

          const SizedBox(height: 16),
        
          DropdownButton<QuestionType>(
          value: selectedItem,
          onChanged: (QuestionType? newValue) {
            setState(() {
              selectedItem = newValue!;
            });
          },
          items: QuestionType.values
              .map<DropdownMenuItem<QuestionType>>((QuestionType value) {
            return DropdownMenuItem<QuestionType>(
              value: value,
              child: Text(value.toString().split('.')[1]), // Display enum value without the enum class name
            );
          }).toList(),
        ),

          const SizedBox(height: 16),

          TextButton(onPressed: () {
            setState(() {
              multipleChoiceAnswers.add(Tuple<TextEditingController, bool>(TextEditingController(), false));
            });
          }, child: Text("Add Answer")),

          ...buildMultipleChoiceAnswers(),

          TextButton(
            onPressed: () {}, 
            child: Text("Add to database"))
        ],
      ) 
    );
  }
}
 

class QuizBuilder extends StatefulWidget {

  const QuizBuilder({ super.key });

  @override 
  State<QuizBuilder> createState() => QuizBuilderState(); 

}

class QuizBuilderState extends State<QuizBuilder> {

  QuizManager quizManager = QuizManager();

  Quiz currentQuiz = Quiz(); 
  List<QuizQuestion> questionsInQuiz = List.empty(growable: true); 

  @override
  void initState() {
    super.initState();

    loadQuestionCards("");
  }

  void loadQuestionCards(String tags) {
    
    quizManager.getQuizQuestions().then((value) {
      questionWidgets = List.generate(value.length, (index) {
        print("Loaded Question: ${value[index].questionText}");
        return QuestionCard(question: value[index],
        onRightArrow: (){
          setState(() {
            questionsInQuiz.add(value[index]);
          });
        },);
      });

      setState(() {
        
      });
    });
  }

  Widget quizBuilder() {
    return SizedBox(
      child: Row(
        children: [
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
                ),
              )
        ],
      )
    );
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

              QuestionBuilder()
            ],
          )
        )
      )
    
    );
  }
}
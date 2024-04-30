import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:google_fonts/google_fonts.dart';


class QuestionCard extends StatelessWidget {
  const QuestionCard({ super.key, required this.question, this.onRightArrow, this.onLeftArrow });

  final QuizQuestion question;
  final Function? onRightArrow;
  final Function? onLeftArrow;  

  Widget buildTypeTag() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.4),
        borderRadius: BorderRadius.circular(100)
      ),
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0, left: 12.0, right: 12.0),
      child: Text(questionTypeToString(question.type))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
              [
                Text(
                question.questionText, 
                style: GoogleFonts.nunito(
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                )
                ,
                ),
                buildTypeTag(),
                
                if (onRightArrow != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () => onRightArrow,
                    ),
                  ),

                if (onLeftArrow != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () => onLeftArrow,
                    ),
                  ),
              ]
            )
        )
        )
      )
    );
  }
}
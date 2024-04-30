import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Quizzes/xpLogic.dart';
import 'package:education_app/Widgets/RecentQuizzes.dart';
import 'package:education_app/Widgets/TabBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserInfoWidget extends StatefulWidget {

  UserInfoWidget({ super.key, required this.userId });
  final String userId; 

   @override
  State<UserInfoWidget> createState() => UserInfoWidgetState(); 
}

class UserInfoWidgetState extends State<UserInfoWidget> {
  int currentXpOverall = 0; 
  int currentLevel = 0;
  int currentLevelProgress = 10;
  int currentLevelMax = 20; 
  int prevLevelMax = 0; 

  @override
  void initState() {
    super.initState();

    getUserData();
  }

  void getUserData() async {
    var db = FirebaseFirestore.instance;
    var collection = await db.collection("users").doc(widget.userId).get();
    var data = collection.data();

    if (data == null ) {
      return; 
    }

    if (data.containsKey("xpLvl")) {
      setState(() {
        currentXpOverall = data["xpLvl"];
        print(currentXpOverall);
        currentLevel = XpInterface.getLevel(currentXpOverall);

        if (XpInterface.rankList[currentLevel] == "Emerald") {
          currentLevelProgress = currentXpOverall - prevLevelMax;
        }
        else {
          currentLevelMax = XpInterface.rankThesholds[currentLevel];
          if (currentLevel > 0) {
            prevLevelMax = XpInterface.rankThesholds[currentLevel - 1];
          }
          else {
            prevLevelMax = 0;
          }
          currentLevelProgress = currentXpOverall - prevLevelMax;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1 / 3,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Theme.of(context).colorScheme.primary,
              ),
              padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
            Image.asset("assets/images/${XpInterface.getRank(currentXpOverall).toLowerCase()}.png", width: 128, height: 128),
            
            const SizedBox(height: 16.0),

            Text(XpInterface.getRank(currentXpOverall), style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 30)),

            if (XpInterface.getRank(currentXpOverall) != "Emerald")
              SizedBox(
                width: double.infinity,
                child: RichText(
                  text: TextSpan(
                    text: currentLevelProgress.toString(),
                    style: GoogleFonts.nunito(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontSize: 22, 
                      fontWeight: FontWeight.bold
                    ),
                    children: [
                      TextSpan(
                        text: " / ${currentLevelMax - prevLevelMax}",
                        style: GoogleFonts.nunito(
                          color: Colors.black.withOpacity(0.3),
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        )
                      ),

                      TextSpan(
                        text: " xp",
                        style: GoogleFonts.nunito(
                          color:  Theme.of(context).textTheme.bodyMedium!.color,
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic
                        )
                      ),
                    ]
                  )
                ),
              ),
            if (XpInterface.getRank(currentXpOverall) == "Emerald")
              SizedBox(
                  width: double.infinity,
                  child: RichText(
                    text: TextSpan(
                      text: "${currentLevelProgress.toString()} ",
                      style: GoogleFonts.nunito(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                      children: [
                        TextSpan(
                        text: " xp",
                        style: GoogleFonts.nunito(
                          color:  Theme.of(context).textTheme.bodyMedium!.color,
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic
                        )
                      ),
                      ]
                    )
                  ),
                ),
            const SizedBox(height: 6.0),

            Container(
              width: double.infinity,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(20)
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                  widthFactor: currentLevelProgress / currentLevelMax,
                  child: Container(
                      decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: BorderRadius.circular(20),
                      ),
                  ),
              ),
            ),

            ])),

            // End of XP box and rank box

            const SizedBox(height: 16),
            TabBarCustom(options: const ["Recent" /*, "Milestones" */],),
            const SizedBox(height: 16),
            const Expanded(
              child: SizedBox(
                child: SingleChildScrollView(
                  child:  RecentQuizzes()
                )
              )
            )
          ],
        )
      )
    );
  }
}
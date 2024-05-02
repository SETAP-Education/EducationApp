import 'package:flutter/material.dart';

// xp needs to be taken from users account - but don't know how to access that db rn
int xp = 0;
int level = 0;
String rank = '';
// max level is 10
bool reachedMaxLevel = false;

// function to be ran at the beginning of the program, takes xp and sets level and rank
void setUpLevelAndRank(){
  level = getLevel();
}

class XpInterface {

  static List<String> rankList = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Emerald'];
  static List<int> rankThesholds = [ 20, 40, 60, 80, 100 ];

  static int getLevel(int xp) {
     for (int i = 0; i < rankThesholds.length; i++) {
      if (xp < rankThesholds[i]) {
        return i;
      }
    }

    return 0;
  }

  static String getRank(int xp) {
    
    for (int i = 0; i < rankList.length; i++) {
      if (xp < rankThesholds[i]) {
        return rankList[i];
      }
    }

    return rankList[0];
  }
}

// adds gained xp from quiz to total xp - called after user completes a quiz
void setXp(BuildContext context, int quizXp){
  xp += quizXp;

  // check if level has changed
  if(checkIfLeveledUp() == true){
    // only need to set level and rank if user has leveled up, otherwise just wasting time
    level = getLevel();
    //rank = getRank();
    if(reachedMaxLevel == true){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Congratulations you have reached the maximum level! You are now at level ${level} and rank ${rank}'),
        ),
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Congratulations you leveled up! You are now at level ${level} and rank ${rank}'),
        ),
      );
    }
  }

  // need to add a function that updates xp to users db - needs to happen everytime the user completes a quiz
}

// sets the level variable based on users xp
// setLevel() used in leveledUp() & leveledUp() used whenever xp is altered - means that only xp is altered when a user completes a quiz, makes everything simpler.
int getLevel(){
  List<int> levels = [100,300,500,1000,1500,2250,3000,4000,5000,7000];
  int currentLevel = 0;
  for(int i=0;i<=9;i++){
    if(xp < levels[i]){
      currentLevel = i;
      break;
    }
    else{
      currentLevel = 10;
      reachedMaxLevel = true;
    }
  }
  return currentLevel;
}

// function to detect if user has changed level - if so, need to display message <- need to create this function, decide on a way of displaying this congrats message etc
bool checkIfLeveledUp(){
  // compare level before and after xp from completed quiz is added
  int prevLevel = level;
  int newLevel = getLevel();
  if(prevLevel != newLevel){
    return true;
  }
  else{
    return false;
  }
}

// returns the rank based on users level
String getRank(int xp){
  List<String> rankList = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Emerald'];
  String rank = '';
  for(int i=0;i<=9;i++){
    if(xp == i){
      rank = rankList[i];
    }
  }
  return rank;
}

// function to calculate xp gained from completing a quiz
void xpGained(BuildContext context){
  int xpGained = 0;

  // get total number of questions answered correctly
  // add up difficulty for each question answered correctly
  // divide this by the average difficulty of the quiz - xpGained = this value

  setXp(context, xpGained);
}
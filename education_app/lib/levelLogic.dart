// xp needs to be taken from users account - but don't know how to access that db rn
int xp = 10;
int level = 0;
String rank = '';
// max level is 10
bool reachedMaxLevel = false;

// function to be ran at the beginning of the program, takes xp and sets level and rank
void setUpLevelAndRank(){
  level = setLevel();
  rank = setRank();
}

// adds gained xp from quiz to total xp - called after user completes a quiz
void setXp(int quizXp){
  xp += quizXp;

  // check if level has changed
  if(checkIfLeveledUp() == true){
    if(reachedMaxLevel == true){
      // print 'congrats! you have leveled up as far as possible' message
    }
    else{
      // print 'congrats! you leveled up' message
    }
  }

  level = setLevel();
  rank = setRank();

  // need to add a function that sets xp to users db - needs to happen everytime the user completes a quiz
}

// sets the level variable based on users xp
// setLevel() used in leveledUp() & leveledUp() used whenever xp is altered - means that only xp is altered when a user completes a quiz, makes everything simpler.
int setLevel(){
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
  int newLevel = setLevel();
  if(prevLevel != newLevel){
    return true;
  }
  else{
    return false;
  }
}

// returns the rank based on users level
String setRank(){
  List<String> rankList = ['Copper', 'Silver', 'Gold', 'Pearl', 'Jade', 'Ruby', 'Sapphire', 'Emerald', 'Opal', 'Diamond'];
  String rank = '';
  for(int i=0;i<=9;i++){
    if(level == i){
      rank = rankList[i];
    }
  }
  return rank;
}

// create these functions; checkIfLeveledUp(), levelUp(), getRank(), reachedMaxLevel(), some sort of xp function to add new, gained xp to overall xp.

// xp and level needs to be taken from users account - but don't know how to access that db rn
int xp = 10;
int level = 0;
// max level is 10
bool reachedMaxLevel = false;

// adds gained xp from quiz to total xp
void setXp(int quizXp){
  xp += quizXp;
  // need to add a function that sets xp to users account - needs to happen everytime the user completes a quiz
}

// sets the level variable based on users xp
// getLevel() used in leveledUp() & leveledUp() used whenever xp is altered - means that only xp is altered when a user completes a quiz, makes everything simpler.
void getLevel(){
  List<int> levels = [100,300,500,1000,1500,2250,3000,4000,5000,7000];
  for(int i=0;i<=9;i++){
    if(xp < levels[i]){
      level = i;
      break;
    }
    else{
      level = 10;
    }
  }
}

// function to detect if user has changed level - if so, need to display message <- need to create this function, decide on a way of displaying this congrats message etc
bool leveledUp(){
  // compare level before and after xp from completed quiz is added
  int prevLevel = level;
  getLevel();
  int newLevel = level;
  if(prevLevel != newLevel){
    return true;
  }
  else{
    return false;
  }
}
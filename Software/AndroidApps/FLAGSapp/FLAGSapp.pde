import apwidgets.*;

public final int SPANISH = 1;
public final int ENGLISH = 2;
public final int PORTUGUESE = 3;
public final int GERMAN = 4;
public final int FRENCH = 5;
public final int ITALIAN = 6;

public final int LION = 1;
public final int ELEPHANT = 2;
public final int PIG = 3;
public final int GIRAFFE= 4;
public final int HORSE = 5;
public final int FOX = 6;


int BUT_WIDTH;
int BUT_HEIGHT;

LanguageManager lm;
PFont font;
Button [] buttons;
PImage bg;

APMediaPlayer player;
int [] tokenList;
int latestToken=0;



void setup() 
{
  orientation(LANDSCAPE);
  size(displayWidth, displayHeight);
  initList();
  bg= loadImage ("bg.png");

  BUT_WIDTH = 86;
  BUT_HEIGHT= 65;

  int x= BUT_WIDTH;
  int y= BUT_HEIGHT;
  font = loadFont("font.vlw");
  buttons= new Button [6];
//  buttons[0]= new Button ("flags/spanish.png", width/2 -x, height/2-y, BUT_WIDTH, BUT_HEIGHT);
//  buttons[1]= new Button ("flags/english.png", width/2, height/2-y, BUT_WIDTH, BUT_HEIGHT);
//  buttons[2]= new Button ("flags/portuguese.png", width/2 +x, height/2-y, BUT_WIDTH, BUT_HEIGHT);
//  buttons[3]= new Button ("flags/german.png", width/2 -x, height/2+y, BUT_WIDTH, BUT_HEIGHT);
//  buttons[4]= new Button ("flags/french.png", width/2, height/2+y, BUT_WIDTH, BUT_HEIGHT);
//  buttons[5]= new Button ("flags/italian.png", width/2 +x, height/2+y, BUT_WIDTH, BUT_HEIGHT);
  buttons[0]= new Button ("flags/spanish.png", x, height/4, BUT_WIDTH, BUT_HEIGHT);
  buttons[1]= new Button ("flags/english.png", width-x, height/4, BUT_WIDTH, BUT_HEIGHT);
  buttons[2]= new Button ("flags/portuguese.png", x, 3*height/4, BUT_WIDTH, BUT_HEIGHT);
  buttons[3]= new Button ("flags/german.png", width-x, 3*height/4, BUT_WIDTH, BUT_HEIGHT);
 
  buttons[4]= new Button ("flags/french.png", -width, -height, BUT_WIDTH, BUT_HEIGHT);
  buttons[5]= new Button ("flags/italian.png", -width, -height, BUT_WIDTH, BUT_HEIGHT);
  
  lm= new LanguageManager(width, height);
  player = new APMediaPlayer(this);

  connect();
}


void mousePressed()
{
  String output="";
  for (int i=1; i<tokenList.length;i++)
  {
    output= output+ tokenList[i]+"   ";
  }
  println(output);

  int language= 0;
  if (buttons[0].isPressed()) language= SPANISH;
  if (buttons[1].isPressed()) language= ENGLISH;
  if (buttons[2].isPressed()) language= PORTUGUESE;
  if (buttons[3].isPressed()) language= GERMAN;
  //if (buttons[4].isPressed()) language= FRENCH;
  //if (buttons[5].isPressed()) language= ITALIAN;

  if (language==0) return;


  int tokenID=0;
  for (int i=0; i<tokenList.length; i++)
  {
    if ( tokenList[i] == language )
    {
      tokenID= i;
      break;
    }
  }
  if (tokenID==0) return;

  lm.play (tokenID, language);
}


void draw() 
{
  //background(200);
  imageMode (CORNER);
  image (bg, 0, 0, displayWidth, displayHeight);

  textAlign(CENTER, CENTER);
  fill (0);
  //textSize(40);
  //text ("Choose a language!\nTap anywhere to play!", width/2, height/2);

  for (int i=0; i<buttons.length;i++)
  {
     buttons[i].draw();
  }

  lm.draw();
}


void onTokenDetection (int tokenID, int value)
{
  latestToken= value;
  if (tokenID<0 || tokenID>=tokenList.length) return;

  // remove if it was used for other languages
  for (int i=0; i<tokenList.length; i++)
  {
    if ( tokenList[i] == value )
    {
      tokenList[i] =0;
    }
  }

  tokenList[tokenID]= value;


  for (int i=0; i<buttons.length; i++)
  {
    buttons[i].deselect();
  }

  for (int i=0; i<tokenList.length; i++)
  {
    int v=  tokenList[i] -1;
    if (v<0) continue;
    buttons[v].select();
  }
}


void initList()
{
  tokenList= new int [7];
  tokenList[0]=0;
  tokenList[LION]=0;
  tokenList[ELEPHANT]=0;
  tokenList[PIG]=0;
  tokenList[GIRAFFE]=0;
  tokenList[HORSE]=0;
  tokenList[FOX]=0;
}


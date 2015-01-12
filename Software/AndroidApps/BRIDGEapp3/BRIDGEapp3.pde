PImage bg;
Game game;

public int SPRITE_SIZE= 130;
public final int SPEED= 5;

public int TOP= 0;
public int BOTTOM= 0;
public int LEFT= 0;
public int MIDDLE= 0;


void setup() 
{
  orientation(LANDSCAPE);
  //size(800, 600);
  size(displayWidth, displayHeight);
  SPRITE_SIZE = height/4; 
  connect();

  // init locations
  TOP= SPRITE_SIZE/2;
  BOTTOM= height-TOP;
  MIDDLE= width/2;
  LEFT= MIDDLE-SPRITE_SIZE;

  game= new Game();
  bg= loadImage ("bg.png");
}


void draw() 
{
  if (bg!=null)
  { 
    imageMode(CORNER);
    image(bg, 0, 0, width, height);
  }

  game.draw();
}


void keyPressed()
{
  if (key=='1')game.moveUp(FOX);
  if (key=='2')game.moveUp(CHICKEN);
  if (key=='3')game.moveUp(WHEAT);
  if (key=='4')game.moveDown(FOX);
  if (key=='5')game.moveDown(CHICKEN);
  if (key=='6')game.moveDown(WHEAT);
}


void onTokenDetection (int tokenID, int value)
{ 
   println(tokenID+"   "+value);
   if (value ==0) return;
  if (value >=4)
  {
    if (tokenID==2) game.moveUp(FOX);
    if (tokenID==3) game.moveUp(CHICKEN);
    if (tokenID==4) game.moveUp(WHEAT);
  }
  else {

    if (tokenID==2) game.moveDown(FOX);
    if (tokenID==3) game.moveDown(CHICKEN);
    if (tokenID==4) game.moveDown(WHEAT);
  }
}

void mousePressed()
{
  game= new Game();
}




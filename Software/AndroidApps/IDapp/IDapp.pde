PImage bg, cage, lion, elephant, giraffe, horse, pig;
boolean blion, belephant, bgiraffe, bhorse, bpig;
final int THRESHOLD= 20;

void setup() 
{
  orientation(LANDSCAPE);
  size(displayWidth, displayHeight);
  connect();
  
  bg= loadImage("imgs/bg.png");
  cage= loadImage("imgs/empty.png");
  lion= loadImage("imgs/lion.png");
  elephant= loadImage("imgs/elephant.png");
  giraffe= loadImage("imgs/giraffe.png");
  horse= loadImage("imgs/horse.png");
  pig= loadImage("imgs/pig.png");
}



void draw() 
{
  background(0);
  image(bg, 0, 0, displayWidth, displayHeight);
  if (blion) image (lion, 0, 0, displayWidth, displayHeight);
  if (belephant) image (elephant, 0, 0, displayWidth, displayHeight);
  if(bgiraffe) image (giraffe, 0, 0, displayWidth, displayHeight);
  if (bhorse) image (horse, 0, 0, displayWidth, displayHeight);
  if (bpig) image (pig, 0, 0, displayWidth, displayHeight);
  image(cage, 0, 0, displayWidth, displayHeight);
}


void setSpriteVisible (int tokenID, boolean vis)
{
   switch (tokenID)
  {
     case 1: blion= vis; break;
     case 2: belephant= vis; break;
     case 4: bgiraffe= vis; break;
     case 5: bhorse= vis; break;
     case 3: bpig= vis; break;
  } 
}



void onTokenDetection (String tokenID, char tokenType, float value)
{ 
  if (tokenType!='i') return;
  try{
    int id= Integer.parseInt(tokenID);
    setSpriteVisible (id, value >= THRESHOLD);
  }catch (Exception e){}
}



void onTokenDetection (String tokenID, char tokenType, float value, float x, float y, float z)
{
  // just ignore the x y z in this case
  onTokenDetection (tokenID, tokenType, value);
}

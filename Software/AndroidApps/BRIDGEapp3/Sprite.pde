int FOX= 0;
int CHICKEN= 1;
int WHEAT=2;
int FARMER=3;

int POS2=2;
int BRIDGE=1;
int POS1= 0;

int followUpCmd;
int followUpID;

class Game implements Runnable 
{
  Game()
  {
    reset();
    font = loadFont("font.vlw");
    textFont(font, 80);
  }

  void reset()
  {
    sprites= new Sprite[4];
    sprites[0]= new Sprite (FOX);
    sprites[1]= new Sprite (CHICKEN);
    sprites[2]= new Sprite (WHEAT);
    sprites[3]= new Sprite (FARMER);
    gameActive= true;
    state= new int [] {
      POS1, POS1, POS1, POS1
    };
    if (runner!=null)
    {
      runner.stop();
      runner=null;
      runningSprite=null;
    }
  }

  void draw()
  {
    if (!gameActive)
    {
      textAlign(CENTER);
      fill(255, 0, 0);
      text("Game over", width/2, height/2);
      return;
    }
    
        // WIN
    if (state[FOX]==POS2 && state[WHEAT]==POS2 && state[CHICKEN]==POS2)
    {
      textAlign(CENTER);
      fill(255, 255, 255);
      text("YOU WIN", width/2, height/2);
      return;
    }

    for (int i=0; i<state.length; i++)
    {
      if (state[i] == POS2)
      {
        sprites[i].setXY (LEFT+i*SPRITE_SIZE, TOP);
      }
      else if (state[i] == POS1) 
      {
        sprites[i].setXY (LEFT+i*SPRITE_SIZE, BOTTOM);
      }
      sprites[i].draw();
    }
    
    if (runningSprite!=null)
      {
      runningSprite.draw();
      sprites[FARMER].draw(); 
      }
  }


  void moveUp (int id)
  { 
    if (!gameActive) return;
    if (state[id] == POS2) return; //already up
    if (state[id] == BRIDGE) return; //travelling
    
    // check where the farmer is
    if (id!=FARMER && state[FARMER] != POS1) // no farmer, so move him
       {
       followUpCmd = 2; 
       followUpID = id;
       moveDown(FARMER);
       return; 
       }    

    if (runner == null) {
      this.id=id;
      state[id]=BRIDGE;
      state[FARMER]=BRIDGE;

      // prepare for animation
      runningSprite= new Sprite (id);
      runningSprite.setXY (MIDDLE, BOTTOM);
      sprites[id].setVisible(false);
      speed= -SPEED;
      target= TOP;
      destination= POS2;

      runner = new Thread(this);
      runner.start();
    }
  }

  void moveDown (int id)
  {
    if (!gameActive) return;
    if (state[id] == POS1) return; //already down
    if (state[id] == BRIDGE) return; //travelling

    // check where the farmer is
    if (id!=FARMER && state[FARMER] != POS2) 
       {
       followUpCmd = 1; 
       followUpID = id;
       moveUp(FARMER);
       return; 
       } 

    if (runner == null) {
      this.id=id;
      state[id]=BRIDGE;
      state[FARMER]=BRIDGE;

      // prepare for animation
      runningSprite= new Sprite (id);
      runningSprite.setXY (MIDDLE, TOP);
      sprites[id].setVisible(false);
      speed= SPEED;
      target= BOTTOM;
      destination= POS1;

      runner = new Thread(this);
      runner.start();
    }
  }


  void endMove()
  {    
    sprites[id].setVisible(true);
    state[id]= destination;
    state[FARMER] = destination; // possible repeat
    runningSprite= null;
    runner=null;

    //print(state[3]); 

   if (id==FARMER && followUpCmd==1)
     {
       followUpCmd = 0;
       moveDown(followUpID);
       return;
     } 
   if (id==FARMER && followUpCmd==2)
     {
       followUpCmd = 0;
       moveUp(followUpID);
       return;
     } 
     

    // WIN
    if (state[FOX]==POS2 && state[WHEAT]==POS2 && state[CHICKEN]==POS2)
    {
      (new Thread() {
        public void run() {
          try {
            Thread.sleep(2000);
            // new game
            reset();
          }
          catch (Exception e) {
          }
        }
      }
      ).start();
    }
  }


  void validate()
  {
    // game over conditions
    // FOX n CHICKEN
    if (state[FOX]==state[CHICKEN] && state[FOX] != state[WHEAT]) gameOver();
    // CHICKEN n WHEAT
    if (state[WHEAT]==state[CHICKEN] && state[WHEAT] != state[FOX]) gameOver();
  }

  void gameOver()
  {
    gameActive= false;

    (new Thread() {
      public void run() {
        try {
          Thread.sleep(3000);
          // new game
         // reset();
        }
        catch (Exception e) {
        }
      }
    }
    ).start();
  }


  void run() 
  {    
    //animate
    int y= runningSprite.getY();
    while (abs (target - y) >= ERR)
    {
      y+= speed;
      runningSprite.setXY (MIDDLE, y);
      
      if (runningSprite.ID!=FARMER)
        {
          sprites[FARMER].setXY (MIDDLE, y-SPRITE_SIZE); // MAGIC NUMBER
        }
          
      try {Thread.sleep(25);} catch (Exception e) {}
      
    }
    validate();
    endMove();
  }


  // FOX, CHIKEN, WHEAT (POS1 = bottom, BRIDGE= travel, POS2 = top)
  int [] state;
  Sprite [] sprites;
  Thread runner, validatingThread;
  int id;
  int speed;
  int destination;
  int target;
  Sprite runningSprite;
  public final int ERR = 4;
  boolean gameActive;
  PFont font;
}



class Sprite
{

  Sprite (int id)
  {
    x=y=0;
    ID = id; 
    if (id==FOX) img= loadImage("fox.png");
    if (id==CHICKEN) img= loadImage("chicken.png");
    if (id==WHEAT) img= loadImage("wheat.png");
    if (id==FARMER) img= loadImage("farmer.png");
    visible=true;
  }

  void setXY (int x, int y)
  {
    this.x= x;
    this.y= y;
  }

  int getX() { 
    return x;
  }
  int getY() { 
    return y;
  }
  
  void draw()
  {
    if (!visible) return;
    imageMode(CENTER);
    image (img, x, y, SPRITE_SIZE, SPRITE_SIZE);
  }

  void setVisible(boolean b) {
    visible=b;
  }

  boolean visible;
  int x, y;
  PImage img;
  PFont font;
  int ID;
}


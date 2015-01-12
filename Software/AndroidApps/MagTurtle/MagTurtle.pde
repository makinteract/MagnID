Terrapin terrapin;
final int CLEAR_BUT_SIZE=100;
final int DIAM=20;
Action a;

void setup() 
{
  orientation(LANDSCAPE);
  //size(640, (int)(640.0*0.5625)); 
  size(displayWidth, displayHeight);

  background(200);

  // size of the terrapin's drawing zone, start point for the terrapin
  terrapin = new Terrapin(width, height, width/3, height/3);

  a= new Action();
  connect();
} 



void draw()
{
  // draw clear button
  // clear button
  fill(255);
  rectMode(CORNER);
  rect(width-CLEAR_BUT_SIZE, 0, CLEAR_BUT_SIZE, CLEAR_BUT_SIZE);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Clear", width-CLEAR_BUT_SIZE/2, CLEAR_BUT_SIZE/2);


  a.draw();
  terrapin.drawTerrapin();
}

void keyPressed()
{
  processShapeCommand(key);
}



void processShapeCommand(char k)
{
  //    // add some tokens (see functions below)
  //    switch (k)
  //      {
  //        case '1' : circleTurtle(); break;
  //        case '2' : triangleTurtle(); break;
  //        case '3' : squareTurtle(); break;
  //        case '4' : starTurtle(); break;
  //        case '5' : flowerTurtle(); break; 
  //      }
}

void mousePressed()
{
  background(200); // blank screen

  // blt some UI instructions
  //fill(0); 
  //text("Put the tokens in place and touch the screen to draw", width/2, (int)((float)height*0.95));


  if (mouseX > width-CLEAR_BUT_SIZE && mouseY < CLEAR_BUT_SIZE) 
  {
    terrapin.resetTerrapin(); //reset drawing, position and tokens/commands
    a.clear();
    return;
  }
  // else
  // compose terrapin blocks
  
  a.makeActions (terrapin);
  
  if (terrapin.isBlocks()) // if we have any tokens/commands, then start
    terrapin.startRunning();
}



void onTokenDetection (int tokenID, int value)
{
  // println(tokenID+"  "+value);  
  value--;
  
  a.addAction (value, tokenID);
}






// samples shapes for the terrapin - this will be done by mag blocks in the end
// there are three possible move tokens (small, med, large) and five possible rotate tokens (1, 2, 3, 4, 5)
// a maximum of four blocks in play at one time and the order (e.g. location) of these blocks can be determined
void circleTurtle()
{
  terrapin.addBlock(TERRAPIN_CMD_MOVE, TERRAPIN_MOVE_SMALL);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_1);
}

void triangleTurtle()
{
  terrapin.addBlock(TERRAPIN_CMD_MOVE, TERRAPIN_MOVE_LARGE);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_4); 
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_2);
}

void squareTurtle()
{
  terrapin.addBlock(TERRAPIN_CMD_MOVE, TERRAPIN_MOVE_MEDIUM);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_4);
}

void starTurtle()
{
  terrapin.addBlock(TERRAPIN_CMD_MOVE, TERRAPIN_MOVE_LARGE);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_4);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_3);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_1);
}  

void flowerTurtle()
{
  terrapin.addBlock(TERRAPIN_CMD_MOVE, TERRAPIN_MOVE_LARGE);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_5); 
  terrapin.addBlock(TERRAPIN_CMD_MOVE, TERRAPIN_MOVE_MEDIUM);
  terrapin.addBlock(TERRAPIN_CMD_ROTATE, TERRAPIN_ROTATE_3);
}




class Action
{
  Action()
  {
   clear();
  }

  void addAction(int position, int tokenID)
  {
    switch (tokenID)
    {
    case 0: commands.put (tokenID, TERRAPIN_CMD_NONE); break; 
    case 1: commands.put (tokenID, TERRAPIN_MOVE_SMALL); break; 
    case 2: commands.put (tokenID, TERRAPIN_MOVE_MEDIUM); break; 
    case 3: commands.put (tokenID, TERRAPIN_MOVE_LARGE); break; 
    case 4: commands.put (tokenID, TERRAPIN_ROTATE_5); break; 
    case 5: commands.put (tokenID, TERRAPIN_ROTATE_4); break; 
    case 6: commands.put (tokenID, TERRAPIN_ROTATE_3); break; 
    case 8: commands.put (tokenID, TERRAPIN_ROTATE_2); break; 
    case 7: commands.put (tokenID, TERRAPIN_ROTATE_1); break; 
    }
    
    // remove the same tokenID if anyoneElse have it
    for (int i=0; i<actions.length; i++)
    {
       if (actions[i] == tokenID)
       {
          actions[i]= 0; 
       }
    }
    // put the correct action
    actions[position]= tokenID; 
    
    
  }
  
  void draw()
  {
    // cicrles for tokens
    fill(255);
    noStroke();
    rectMode(CORNER);
    rect(0, height-DIAM*2, width, DIAM*2);
  
    ellipseMode(CENTER);
    for (int i =0; i<actions.length; i++)
    {
      stroke(0);
      if (actions[i] == 0)
      {
        fill(255);
      }
      else {
        fill(0);
      }
      ellipse(width/2-3*DIAM+i*DIAM*2, height-DIAM, DIAM, DIAM);
    }
  }
  
  
  void makeActions (Terrapin terrapin)
  {    
    println(TERRAPIN_MOVE_MEDIUM);
    int [] blocks= new int [actions.length];
    for (int i=0; i<actions.length; i++)
    {
       blocks[i]=  commands.get(actions[i]).intValue();
    }
   
    for (int i=0; i<blocks.length; i++)
    {
      if (blocks[i] == TERRAPIN_CMD_NONE) continue;
      if (blocks[i] ==  TERRAPIN_MOVE_LARGE || blocks[i] ==  TERRAPIN_MOVE_MEDIUM || blocks[i] ==  TERRAPIN_MOVE_SMALL)
      {
        terrapin.addBlock(TERRAPIN_CMD_MOVE, blocks[i]);
        println("Move "+blocks[i]);
      }
      else if (blocks[i] == TERRAPIN_ROTATE_1 || 
        blocks[i] == TERRAPIN_ROTATE_2 ||
        blocks[i] == TERRAPIN_ROTATE_3 ||
        blocks[i] == TERRAPIN_ROTATE_4 ||
        blocks[i] == TERRAPIN_ROTATE_5 ) {
        terrapin.addBlock(TERRAPIN_CMD_ROTATE, blocks[i]);
        println("Rot "+blocks[i]);
      }
    }
    clear();
  }
  
  void clear()
  {
     commands= new HashMap<Integer, Integer> ();
    commands.put (0, TERRAPIN_CMD_NONE);    
    
    actions= new int[] {
      TERRAPIN_CMD_NONE, TERRAPIN_CMD_NONE, TERRAPIN_CMD_NONE, TERRAPIN_CMD_NONE
    };
  }
  
  HashMap<Integer, Integer> commands;
  int []actions;
}


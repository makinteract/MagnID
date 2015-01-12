final int TERRAPIN_CMD_NONE     = 0;
final int TERRAPIN_CMD_MOVE     = 1;
final int TERRAPIN_CMD_ROTATE   = 2;

int TERRAPIN_MOVE_SMALL   = 15; // used for circle
int TERRAPIN_MOVE_MEDIUM  = 75; // used for small shapes or shapes with two lines (small move is to tiny for most purposes)
int TERRAPIN_MOVE_LARGE   = 200; // used for most shapes

final int TERRAPIN_ROTATE_1     = 9; // used for circle, star - bit of a wierd choice.... 
final int TERRAPIN_ROTATE_2     = 30; // used for triangle
final int TERRAPIN_ROTATE_3     = 45; // used for flower
final int TERRAPIN_ROTATE_4     = 90; // used for square, triangle
final int TERRAPIN_ROTATE_5     = 155; // used for flower - this angle is a wierd choice, but makes the flower.... 

// how fast we move and turn
float moveRate = 3; // we have a bug here. If the move rate is low the whole thing gets screwed up. Why? God knows. 
float turnRate = 3; // this is in degrees 

class terrapinCommand
  {
  int type; 
  int value;
  float progress;
  int totalAdj; 
  
  public terrapinCommand(int t, int v) 
    {
    type = t;
    value = v;   
    progress = 0; // no progress
    totalAdj = 0; 
    }  
    
  int evaluateCommand()
    {
    if (progress>=1.0)
      return 0;   
      
    int oldProg = (int)(progress*(float)value);
    if (type == TERRAPIN_CMD_MOVE) progress += (float)moveRate / (float)value;
    else progress += (float)turnRate / (float)value; //rotationrate by default
    int newProg = (int)(progress*(float)value);
        
    int adj = newProg-oldProg;
    int newTotalAdj=totalAdj+newProg-oldProg; 
    if (newTotalAdj>abs(value))
      adj=value-totalAdj;
    totalAdj += adj;  
      
    if (type == TERRAPIN_CMD_ROTATE && value<0)
      adj*=-1; // this is left rotation
      
    return adj; 
    }
    
    
  };








public class Terrapin 
  {
    
  public float x;
  public float y;
  public float rotation;
  
  float sx;
  float sy;
  float sr;
  
  public boolean drawing = true;
  public int drawColor;
    
  PGraphics buffer;
  
  ArrayList<terrapinCommand> moves;
  boolean running;// whether we are processing the moves. 
  
  PShape turtle;
  
  public Terrapin(int w, int h, int xp, int yp) 
    {
    buffer = createGraphics(w, h);
    beginDrawing();
      clearDrawing();
    endDrawing();
    
    configMovement();
    x = xp;
    y = yp;
    rotation = 0;
    sx=x;
    sy=y;
    sr=rotation;
    drawColor = color(0, 0, 255);
    moves = new ArrayList(); 
    running = false;
    
    // load the turtle icon
    turtle = loadShape("turtle.svg");
    }
 
 void configMovement()
  {
      TERRAPIN_MOVE_SMALL = buffer.width/40; 
      TERRAPIN_MOVE_MEDIUM = TERRAPIN_MOVE_SMALL*5;
      TERRAPIN_MOVE_LARGE = (int)((float)TERRAPIN_MOVE_MEDIUM*2.25); 
      
      moveRate = buffer.width/200; 
      //println(moveRate); 
  } 
    
 void clearBlocks()
   {moves.clear(); running=false;}
   
 void addBlock(int t, int v)
     {moves.add(new terrapinCommand(t, v));} 
     
 boolean isBlocks()
   {return moves.size()>0;}
  
 // reset everything 
 void resetTerrapin()
  {
  clearBlocks(); // empty previous tokens
  clearDrawing(); // blank the previous drawing 
  resetPosition(); // go back to start pos/angle 
  } 
  
 void startRunning()
   {running = true;}
 
 boolean atStartPoint() 
   {
   //println(x +","+ y +","+ rotation%360); 
   return (round(x)==round(sx) && round(y)==round(sy) && round(rotation%360)==round(sr%360));
   }
   
 void resetPosition()
   {
     x=sx;
     y=sy;
     rotation=sr; 
   } 
   
   
  void beginDrawing()     {buffer.beginDraw();}
  void endDrawing()       {buffer.endDraw();}
  void clearDrawing()     {buffer.background(200);}
  PImage getBuffer()      {return buffer.get(0,0,buffer.width,buffer.height);}
  int getBufferWidth()    {return buffer.width;}
  int getBufferHeight()   {return buffer.height;}
  
  PImage getBufferTurtle()
    {
      int startx = (int)x-buffer.width/32-10; 
      int starty = (int)y-buffer.width/32-10; 
      return buffer.get(startx,starty,buffer.width/16+20,buffer.width/16+20);
    }
  
  
  public void setLocation(int x, int y) {this.x = x; this.y = y;}
  
  public void left(int amount) {rotation -= amount;}
  public void right(int amount) {rotation += amount;}
 
  public void backward(int amount) {forward(-amount);}
  public void forward(int amount) 
    {
    float newX, newY;
    float rotRad = radians(rotation);
    newX = x + amount * cos(rotRad);
    newY = y + amount * sin(rotRad);
    moveTo(newX, newY);
    }
    
  public float getRotation() {return rotation;}
  public void setRotation(int rotation) {this.rotation = rotation;}
  
  public void strafeLeft(int amount) {left(90);forward(amount);right(90);}
  public void strafeRight(int amount) {right(90);forward(amount);left(90);}
  
  protected void moveTo(float x, float y) 
    {
      if (drawing) 
        {
          //println("Draw " +x); 
        buffer.stroke(drawColor);
        buffer.strokeWeight(1);
        int rMax = buffer.width/60;
        int rMaxHalf = rMax/2;
        for ( int i=0;i<10;i++) // draw a fat, messed up line 
          buffer.line((int)this.x+random(rMax)-rMaxHalf, (int)this.y+random(rMax)-rMaxHalf, (int)x+random(rMax)-rMaxHalf, (int)y+random(rMax)-rMaxHalf);  
        }
    this.x = x;
    this.y = y;
    }
  
  
  public void setPenColor(color c) {drawColor = c;}
  public void setPenColor(int r, int g, int b) {drawColor = color(r, g, b);}
  
  
  public void drawTerrapinLines()
    {
    if (running)
      {
      buffer.beginDraw();
  
      // execute current drawing command
      boolean searching = true;
      int index = 0;
      while (searching && index<moves.size())
        {
        terrapinCommand t = (terrapinCommand)moves.get(index); 
        
        if (t.progress<1.0)
          {
          if (t.type==TERRAPIN_CMD_MOVE)
            forward(t.evaluateCommand());
          else if (t.type==TERRAPIN_CMD_ROTATE)
            right(t.evaluateCommand());
          searching = false;  
          }          
        else
          index++; 
        }
  
      // if we return to the start of the turtle's movement, stop
      if (atStartPoint()) 
        running=false;
      // otherwise check if we are at the end of the list of actions and reset them for repeating.
      else if (index-1 == moves.size()-1 && ((terrapinCommand)moves.get(index-1)).progress>=1.0)
        {
        for (int i=0;i<moves.size();i++)
          {
          terrapinCommand tC = (terrapinCommand)moves.get(i);
          tC.progress = 0.0; 
          tC.totalAdj = 0; 
          }
        }
      }
  
  // finish drawing turtle
  terrapin.endDrawing();
  }
  
  void drawTerrapinIcon()
    {
    pushMatrix(); 
    translate(x, y); 
    rotate(radians(rotation)+radians(90));
    shapeMode(CENTER);
    shape(turtle, 0, 0, buffer.width/16, buffer.width/16);  // Draw at at size 50x50
    //imageMode(CENTER);
    //image(turtle, 0,0, buffer.width/16, buffer.width/16);  // Draw at at size 50x50
    popMatrix();
    }
    
  void drawTerrapin()
    {
    drawTerrapinLines();
    //image(getBuffer(), 0, 0); // draw whole buffer to screen - slow on android
    image(getBufferTurtle(), (int)x-buffer.width/32-10, (int)y-buffer.width/32-10); 
    drawTerrapinIcon(); // draw icon
    }  
  
  @Override
  public String toString() {return "Terrapin at " + x + "," + y;}
  }


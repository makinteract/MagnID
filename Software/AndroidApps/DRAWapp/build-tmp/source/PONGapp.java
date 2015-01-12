import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PONGapp extends PApplet {

Ball ball;
Pong p1, p2;

public void setup() 
{
  //orientation(LANDSCAPE);
  size(1000, 600);
  connect();

  ball= new Ball ();
  p1= new Pong (50);
  p2= new Pong (width-50);
}



public void draw() 
{
  background(0);
  ball.update();
  ball.draw();
  if(ball.isHittingBounds()) ball.bounceY();

  p1.draw();
  p2.draw();

  // interaction
  p1.update(ball);
  p2.update(ball);

  p1.setY (mouseY);
  p2.setY (mouseY);
}



public void onTokenDetection (String tokenID, char tokenType, float value)
{ 
  if (tokenType!='s') return;
  try{
   // int id= Integer.parseInt(tokenID);
   //  setSpriteVisible (id, value >= THRESHOLD);
  }catch (Exception e){}
}



public void onTokenDetection (String tokenID, char tokenType, float value, float x, float y, float z)
{
  // just ignore the x y z in this case
  onTokenDetection (tokenID, tokenType, value);
}
public final int BALL_SIZE= 20;
public final int BALL_SPEED= 5;
public final int PONG_HEIGHT= 100;
public final int PONG_WIDTH= 5;

class Ball
{
   Ball ()
   {
     this.x= width/2;
     this.y= height/2; 
     dx= BALL_SPEED*random(-1, -.1f);
     dy= BALL_SPEED*random(-1, 1);
   } 


   public void draw()
   {
   		ellipseMode(CENTER);
   		fill (255, 0, 0);
   		ellipse ((int)x, (int)y, BALL_SIZE, BALL_SIZE);
   }

   public void update ()
   {
   		x+= dx;
   		y+= dy;
   }

   public boolean isHittingBounds ()
   {
   	return y-BALL_SIZE/2 < 0 || y+BALL_SIZE/2 > height;
   }

   public void bounceY()
   {
   	dy= -dy;
   }

   public void bounceX()
   {
   	dx= -dx;
   }

   public float getX(){ return x;}
   public float getY(){ return y;}


    private float x, y;
    private float dx, dy;
}


class Pong 
{
	Pong (int x)
	{
		this.x= x;
		this.y= height/2;
	}


	public void setY(float y)
	{
		if (y-PONG_HEIGHT/2 < 0) y= PONG_HEIGHT/2;
		if (y+PONG_HEIGHT/2 > height) y= height-PONG_HEIGHT/2;
		this.y= y;
	}

	public void draw()
	{
		rectMode(CENTER);
		fill(255,255,0);
		rect (x, y,PONG_WIDTH, PONG_HEIGHT);
	}

	public void update (Ball b)
	{
		float bx= b.getX();
		float by= b.getY();

		// left pong
		if (by>= y-PONG_HEIGHT/2 && by<= y+PONG_HEIGHT/2)
		{
			if (bx-BALL_SIZE/2 <= x+PONG_WIDTH/2) b.bounceX();
			if (bx+BALL_SIZE/2 >= x-PONG_WIDTH/2) b.bounceX();
		}

	}


	float x, y;
}






OscP5 oscP5;
String MULTICAST_ADDRESS= "239.0.0.1";
int OSC_PORT= 5204;


public void connect()
{
  oscP5 = new OscP5(this, MULTICAST_ADDRESS, OSC_PORT);
}

public void sendOscMessage (OscMessage message)
{
  if (oscP5==null) return;
  oscP5.send(message);
}

public void sendOscMessage (String id, char type, float value, float [] xyz)
{
  if (oscP5==null) return ; 

  OscMessage message = new OscMessage("/MagID/token");
  message.add(id); 
  message.add(type); 
  message.add(value); 
  message.add(xyz); 
  sendOscMessage (message);
}


public void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/MagID/token")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("scffff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      String id = theOscMessage.get(0).stringValue();  
      char type = theOscMessage.get(1).charValue();  
      float val = theOscMessage.get(2).floatValue();
      float x = theOscMessage.get(3).floatValue();
      float y = theOscMessage.get(4).floatValue();
      float z = theOscMessage.get(5).floatValue();


      onTokenDetection (id, type, val, x, y, z);
    }
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PONGapp" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

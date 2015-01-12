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

public class FLAGSapp extends PApplet {

//import apwidgets.*;

public final int SPANISH = 1;
public final int ENGLISH = 2;
public final int PORTUGUESE = 3;
public final int GERMAN = 4;
public final int FRENCH = 5;
public final int ITALIAN = 6;

public final int LION = 1;
public final int ELEPHANT = 2;
public final int PIG = 3;

public  int BUT_WIDTH= 380;
public  int BUT_HEIGHT= 240;

LanguageManager lm;
PFont font;
Button [] buttons;


//APMediaPlayer player;





public void setup() 
{
  orientation(LANDSCAPE);
  size(displayWidth, displayHeight);
  println(displayWidth+"  "+displayHeight);
  connect();

  BUT_WIDTH = displayWidth/3;
  //BUT_HEIGHT= displayHeight/2-20;

  font = loadFont("font.vlw");
  buttons= new Button [6];
  buttons[0]= new Button ("flags/spanish.png", BUT_WIDTH/2, BUT_HEIGHT, BUT_WIDTH, BUT_HEIGHT);
  buttons[1]= new Button ("flags/english.png", BUT_WIDTH+BUT_WIDTH/2, BUT_HEIGHT/2, BUT_WIDTH, BUT_HEIGHT);
  buttons[2]= new Button ("flags/portuguese.png", 2*BUT_WIDTH+BUT_WIDTH/2, BUT_HEIGHT, BUT_WIDTH, BUT_HEIGHT);
  buttons[3]= new Button ("flags/german.png", BUT_WIDTH/2, displayHeight-BUT_HEIGHT, BUT_WIDTH, BUT_HEIGHT);
  buttons[4]= new Button ("flags/french.png", BUT_WIDTH+BUT_WIDTH/2, displayHeight-BUT_HEIGHT/2, BUT_WIDTH, BUT_HEIGHT);
  buttons[5]= new Button ("flags/italian.png", 2*BUT_WIDTH+BUT_WIDTH/2, displayHeight-BUT_HEIGHT, BUT_WIDTH, BUT_HEIGHT);


  lm= new LanguageManager(width, height);
  //player = new APMediaPlayer(this);
}


public void mousePressed()
{
  if (buttons[0].isPressed()) println("spanish");
  if (buttons[1].isPressed()) println("english");
  if (buttons[2].isPressed()) println("portuguese");
  if (buttons[3].isPressed()) println("german");
  if (buttons[4].isPressed()) println("french");
  if (buttons[5].isPressed()) println("italian");
}


public void draw() 
{
  background(200);

  for (int i=0; i<buttons.length;i++)
  {
    buttons[i].draw();
  }
 // lm.draw();
}


public void onTokenDetection (int tokenID, int value)
{
  println(tokenID+"  "+value);  
  //lm.play (tokenID, value);
}




OscP5 oscP5;
String MULTICAST_ADDRESS= "239.0.0.1";
int OSC_PORT= 5204;

HashMap <Integer, Integer> map= new HashMap <Integer, Integer>();



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

      // if the language manager is speaking, skip input
      if (type!='p') return;

      int ID=0;
      int value=0;
      try 
      {
        ID= Integer.parseInt(id);
        value= (int) val;
      } 
      catch (Exception e) {
      }

      if (value==0) return;

      if (ID==2)
      {
        println(elephant);
        elephant[value]++;
        for (int i=0; i< elephant.length; i++)
        {
          if (elephant[i]>=5)
          {
            onTokenDetection (ID, i);
            elephant= new int[] {
              0, 0, 0, 0, 0, 0
            };
          }
        }
      }
      /* prev= value;
       
       if (!map.containsKey(ID))
       {
       map.put (ID, value);
       onTokenDetection (ID, value);
       }
       else {
       int v= map.get(ID).intValue();
       if (v==value) return;
       map.put (ID, value);
       onTokenDetection (ID, value);
       }*/
    }
  }
}

int [] elephant= {
  0, 0, 0, 0, 0, 0, 0
};

class Language implements Runnable
{

	Language (int id, int w, int h, String img)
	{
		this.id= id;
		this.w= w;
		this.h= h;
		flagImage= loadImage (img);
		active= false;
		runner=null;
		wordText="";
	}

	public boolean isActive(){ return active;}

	public void play (Word w)
	{
		if (active)
                {
                   //player.pause(); 
                   runner.stop();
                   runner=null;
                }
		if (w==null) return;

		//player.setMediaFile(w.getSound(id));
  		//player.start();
		wordText= w.getText(id);

		active = true;
		runner= new Thread (this);
		runner.start();
	}

	public void run()
	{
		try {
			Thread.sleep (DURATION);
		} catch (Exception e) {}

		active= false;
		runner=null;
		wordText="";
	}

	public void draw()
	{
		if (!active) return;

		image (flagImage, 0,0,w,h);
		fill(0,0,0,200);
		rectMode(CORNER);
		rect(0, h-FONT_HEIGHT, w, FONT_HEIGHT);
		fill(255);
		textAlign(CENTER);
		textFont(font, FONT_HEIGHT);			
		text (wordText, w/2, h-5);
	}

	Thread runner;	
	int id, w, h;
	volatile boolean active;
	PImage flagImage;
	String wordText;
 	public final int DURATION = 3000; //ms
 	public final int FONT_HEIGHT= 64;
 }




 class Word
 {
 	Word ()
 	{
 		word= new ArrayList<String>();
 		sounds= new ArrayList<String>();
 	}


 	public void add (String str, String audioFile)
 	{
 		word.add (str);
 		sounds.add (audioFile);
 	}

	// I do not check indices!
	// id starts from 1
	public String getSound (int languageId) { return sounds.get(languageId-1); }
	public String getText (int languageId) { return word.get(languageId-1);}

	ArrayList<String> word;
	ArrayList<String> sounds;
}




class LanguageManager 
{
	LanguageManager(int width, int height)
	{
		lan= new ArrayList<Language>();
                // order is important
		lan.add (new Language (SPANISH, width, height, "flags/spanish.png"));
                lan.add (new Language (ENGLISH, width, height, "flags/english.png"));
		lan.add (new Language (PORTUGUESE,  width, height, "flags/portuguese.png"));
		lan.add (new Language (GERMAN,   width, height, "flags/german.png"));
                lan.add (new Language (FRENCH, 	width, height, "flags/french.png"));
		lan.add (new Language (ITALIAN, width, height, "flags/italian.png"));

		words= new ArrayList<Word>();
		initWords();
		currentLanguage=null;
	}


	public void play (int wordNumber, int languageNumber)
	{
		if (currentLanguage!=null)
		{
			if (currentLanguage.isActive()) { return;}
		}
		Word w= words.get(wordNumber-1);
		currentLanguage= lan.get(languageNumber-1);
		currentLanguage.play (w);
	}

        public boolean isActive(){ 
          if (currentLanguage==null) return false;
          return currentLanguage.isActive();
        }
  
	public void draw()
	{
		for (Language l: lan)
		{	
			l.draw();
		}
	}


	public void initWords()
	{
                // ORDER IS IMPORTANT
		// LION
		Word lion= new Word ();
                lion.add ("Le\u00f3n", "sounds/slion.mp3"); // Spanish
		lion.add ("Lion", "sounds/ilion.mp3"); // English
		lion.add ("Le\u00e3o", "sounds/plion.mp3"); // Portuguese
		lion.add ("L\u00f6we", "sounds/glion.mp3"); // German
		lion.add ("Lion", "sounds/flion.mp3"); // French
		lion.add ("Leone", "sounds/ilion.mp3"); // Italian
		words.add (lion);

		// ELEPHANT
		Word elephant= new Word ();
		elephant.add ("Elefante", "sounds/selephant.mp3"); // Spanish
                elephant.add ("Elephant", "sounds/eelephant.mp3"); // English
		elephant.add ("Elefante", "sounds/pelephant.mp3"); // Portuguese
		elephant.add ("Elefant", "sounds/gelephant.mp3"); // German
                elephant.add ("El\u00e9phant", "sounds/felephant.mp3"); // French
		elephant.add ("Elefante", "sounds/ielephant.mp3"); // Italian
		words.add (elephant);

		// PIG
		Word pig= new Word ();
		pig.add ("Cerdo", "sounds/spig.mp3"); // Spanish
                pig.add ("Pig", "sounds/epig.mp3"); // English
		pig.add ("Porco", "sounds/ppig.mp3"); // Portuguese
		pig.add ("Schwein", "sounds/gpig.mp3"); // German
                pig.add ("Cochon", "sounds/fpig.mp3"); // French
		pig.add ("Maiale", "sounds/ipig.mp3"); // Italian
		words.add (pig);
	}


	ArrayList<Language> lan;
	ArrayList<Word> words;
	Language currentLanguage;

}


class Button
{
	Button (String i, int x, int y, int width, int height)
	{
		img= loadImage (i);
		this.x=x;
		this.y= y;
		this.width= width;
		this.height= height;
	}


	public void draw()
	{
		imageMode(CENTER);
		image (img, x, y, width, height);
	}

	public boolean isPressed()
	{		
		return mouseX>x-width/2 && mouseX<x+width/2 && mouseY >y-height/2 && mouseY <y+height/2;
	}

	PImage img;
	private int x, y, width, height;
}


  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "FLAGSapp" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

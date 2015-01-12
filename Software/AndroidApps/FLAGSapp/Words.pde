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

  boolean isActive() { 
    return active;
  }

  void play (Word w)
  {
    if (active)
    {
      player.pause(); 
      runner.stop();
      runner=null;
    }
    if (w==null) return;

    player.setMediaFile(w.getSound(id));
    player.start();
    wordText= w.getText(id);

    active = true;
    runner= new Thread (this);
    runner.start();
  }

  void run()
  {
    try {
      Thread.sleep (DURATION);
    } 
    catch (Exception e) {
    }

    active= false;
    runner=null;
    wordText="";
  }

  void draw()
  {
    if (!active) return;
    noStroke();
    imageMode(CORNER);
    image (flagImage, 0, 0, w, h);
    fill(0, 0, 0, 200);
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


  void add (String str, String audioFile)
  {
    word.add (str);
    sounds.add (audioFile);
  }

  // I do not check indices!
  // id starts from 1
  String getSound (int languageId) { 
    return sounds.get(languageId-1);
  }
  String getText (int languageId) { 
    return word.get(languageId-1);
  }

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
    lan.add (new Language (PORTUGUESE, width, height, "flags/portuguese.png"));
    lan.add (new Language (GERMAN, width, height, "flags/german.png"));
    lan.add (new Language (FRENCH, 	width, height, "flags/french.png"));
    lan.add (new Language (ITALIAN, width, height, "flags/italian.png"));

    words= new ArrayList<Word>();
    initWords();
    currentLanguage=null;
  }


  void play (int wordNumber, int languageNumber)
  {
    if (currentLanguage!=null)
    {
      if (currentLanguage.isActive()) { 
        return;
      }
    }
    Word w= words.get(wordNumber-1);
    currentLanguage= lan.get(languageNumber-1);
    currentLanguage.play (w);
  }

  boolean isActive() { 
    if (currentLanguage==null) return false;
    return currentLanguage.isActive();
  }

  void draw()
  {
    for (Language l: lan)
    {	
      l.draw();
    }
  }


  void initWords()
  {
    // ORDER IS IMPORTANT
    // LION
    Word lion= new Word ();
    lion.add ("León", "sounds/slion.mp3"); // Spanish
    lion.add ("Lion", "sounds/elion.mp3"); // English
    lion.add ("Leão", "sounds/plion.mp3"); // Portuguese
    lion.add ("Löwe", "sounds/glion.mp3"); // German
    lion.add ("Lion", "sounds/flion.mp3"); // French
    lion.add ("Leone", "sounds/ilion.mp3"); // Italian
    words.add (lion);

    // ELEPHANT
    Word elephant= new Word ();
    elephant.add ("Elefante", "sounds/selephant.mp3"); // Spanish
    elephant.add ("Elephant", "sounds/eelephant.mp3"); // English
    elephant.add ("Elefante", "sounds/pelephant.mp3"); // Portuguese
    elephant.add ("Elefant", "sounds/gelephant.mp3"); // German
    elephant.add ("Eléphant", "sounds/felephant.mp3"); // French
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

    // GIRAFFE
    Word giraffe= new Word ();
    giraffe.add ("Jirafa", "sounds/sgiraffe.mp3"); // Spanish
    giraffe.add ("Giraffe", "sounds/egiraffe.mp3"); // English
    giraffe.add ("Girafa", "sounds/pgiraffe.mp3"); // Portuguese
    giraffe.add ("Giraffe", "sounds/ggiraffe.mp3"); // German
    giraffe.add ("Girafe", "sounds/fgiraffe.mp3"); // French
    giraffe.add ("Giraffa", "sounds/igiraffe.mp3"); // Italian
    words.add (giraffe);

    // HORSE
    Word horse= new Word ();
    horse.add ("Caballo", "sounds/shorse.mp3"); // Spanish
    horse.add ("Horse", "sounds/ehorse.mp3"); // English
    horse.add ("Cavalo", "sounds/phorse.mp3"); // Portuguese
    horse.add ("Pferd", "sounds/ghorse.mp3"); // German
    horse.add ("Cheval", "sounds/fhorse.mp3"); // French
    horse.add ("Cavallo", "sounds/ihorse.mp3"); // Italian
    words.add (horse);

    // FOX
    Word fox= new Word ();
    fox.add ("Zorro", "sounds/sfox.mp3"); // Spanish
    fox.add ("Fox", "sounds/efox.mp3"); // English
    fox.add ("Raposa", "sounds/pfox.mp3"); // Portuguese
    fox.add ("Fuchs", "sounds/gfox.mp3"); // German
    fox.add ("Renard", "sounds/ffox.mp3"); // French
    fox.add ("Volpe", "sounds/ifox.mp3"); // Italian
    words.add (fox);
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
    selected=false;
  }


  void draw()
  {      
    rectMode (CENTER);
    stroke(0);
    strokeWeight(10);
    if (selected) stroke(255,255,0);
    rect(x,y,width,height);
    
    imageMode(CENTER);
    image (img, x, y, width, height);
  }

  void select(){selected=true;}
  void deselect(){selected=false;}
  
  boolean isPressed()
  {		
    return mouseX>x-width/2 && mouseX<x+width/2 && mouseY >y-height/2 && mouseY <y+height/2;
  }

  PImage img;
  private int x, y, width, height;
  boolean selected;
}


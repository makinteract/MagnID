/***************************************************
Buttons
****************************************************/

interface ButtonListener
{
  void buttonPressed (Button b);
}


abstract class Button
{
  Button (PApplet app, ButtonListener listener, int width, int height)
  {
    hnd= app;
    this.listener= listener;
    this.width= width;
    this.height= height;
  }

  Button (PApplet app, ButtonListener listener)
  {
    hnd= app;
    this.listener= listener;
    this.width= 0;
    this.height= 0;
  }

  Button (PApplet app)
  {
    hnd= app;
    this.listener= null;
    this.width= 0;
    this.height= 0;
  }

  Button (PApplet app, int width, int height)
  {
    hnd= app;
    this.listener= null;
    this.width= width;
    this.height= height;
  }

  void setSize (int w, int h)
  {
    width=w;
    height=h;
  }

  int height() {
    return height;
  }

  int width() {
    return width;
  }

  void draw(int x, int y)
  {
    update(x, y);
    // draw
    hnd.pushMatrix();
    hnd.translate(x, y);
    drawContent();
    hnd.popMatrix();
  }


  abstract void drawContent ();
  void press() {
  }


  // private 
  private void update(int x, int y)
  {
    if (isOver(x, y) && hnd.mousePressed && !pressed)
    {
      if (listener!= null)
      {
        listener.buttonPressed (this);
      } 
      pressed^= true;
      press();
    }

    if (!hnd.mousePressed) pressed=false;
  }

  private boolean isOver(int x, int y)
  {
    return hnd.mouseX-x>=0 && hnd.mouseX-x<= width && hnd.mouseY-y>=0 && hnd.mouseY-y <= height;
  }



  protected int width, height;
  protected boolean pressed;
  private ButtonListener listener;
  protected PApplet hnd;
}




class SimpleButton extends Button
{
  SimpleButton (PApplet app, ButtonListener listener, int width, int height, String image)
  {
    super (app, listener, width, height);
    img=loadImage(image);
  }

  SimpleButton (PApplet app, ButtonListener listener, String normalImg)
  {
    super (app, listener);
    img=loadImage(normalImg);
    setSize(img.width, img.height);
  }

  void drawContent()
  {
    hnd.image(img, 0, 0, width, height);
  }

  private PImage img;
}






class ToggleButton extends Button
{
  ToggleButton (PApplet app, ButtonListener listener, int width, int height, String imageOne, String imageTwo)
  {
    super (app, listener, width, height);
    img1=loadImage(imageOne);
    img2=loadImage(imageTwo);
  }

  ToggleButton (PApplet app, ButtonListener listener, String imageOne, String imageTwo)
  {
    super (app, listener);
    img1=loadImage(imageOne);
    img2=loadImage(imageTwo);
    setSize(img1.width, img1.height);
  }

  void setState (boolean b) {
    down=b;
  }

  void press()
  {
    down^= true;
  }

  void drawContent()
  {
    if (down) hnd.image(img1, 0, 0, width, height);
    else hnd.image(img2, 0, 0, width, height);
  }

  
  private PImage img1, img2;
  private boolean down;
}





class MultistateButton extends Button
{
  MultistateButton (PApplet app, ButtonListener listener, int width, int height, String [] images)
  {
    super (app, listener, width, height);
    loadImages (images);
    currentState=0;
  }

  MultistateButton (PApplet app, ButtonListener listener, String [] images)
  {
    super (app, listener);
    loadImages (images);
    currentState=0;
    setSize(img[currentState].width, img[currentState].height);
  }

  int getState() { 
    return currentState;
  }

  void setState(int s)
  {
    if (s<0 || s> states) return;
    currentState= s;
  }

  void next() { 
    currentState= (currentState+1)%states;
  }

  void drawContent()
  {
    hnd.image(img[currentState], 0, 0, width, height);
  }

  private void loadImages (String [] images)
  {
    states= images.length;
    img= new PImage [states];

    for (int i=0; i<states; i++)
    {
      img[i]= loadImage(images[i]);
    }
  }


  private PImage [] img;
  private int states, currentState;
  private boolean down;
}


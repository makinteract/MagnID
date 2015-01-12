import java.util.*;

BrushWidget brush;
ColorBar colors;

final int PANEL_HEIGHT= 120;

int prevX, prevY;
color brushColor= color(0);
int pos=0;


void setup() 
{
  //size(800,600);
  size(displayWidth, displayHeight);
  connect();
  smooth();
  background(255);

  brush= new BrushWidget (width-PANEL_HEIGHT, 0, PANEL_HEIGHT);  
  colors= new ColorBar (0, PANEL_HEIGHT/4, 600, PANEL_HEIGHT/2);
}



void draw() 
{
  ellipseMode(CENTER);

  // panel
  noStroke();
  fill (200);
  rect (0, 0, displayWidth, PANEL_HEIGHT);

  // drawing
  
  color selectedColor= colors.getSelectedColor();
  brush.setBrushColor(selectedColor);
  brush.draw();
  colors.draw();
  
  strokeWeight(brush.getBrushSize());
  stroke(selectedColor);
  



  if (prevX==0 || prevY==0)
  {
    prevX= mouseX;
    prevY= mouseY;
  }

  int y= mouseY;
  if (y<PANEL_HEIGHT) y= PANEL_HEIGHT;
  line(prevX, prevY, mouseX, mouseY);
  prevX= mouseX;
  prevY= mouseY;
}


void mousePressed()
{
  prevX= mouseX;
  prevY= mouseY;
}



void onTokenDetection (String tokenID, char tokenType, float value)
{ 
  try {
    int id= Integer.parseInt(tokenID);
    int val= (int) value;

    int min= 1;
    int max= 2;

    float perc= (value-min)/(max-min);
    if (perc<0) perc= 0;
    if(perc>1) perc=1;
    float correctedPerc= -0.4*log(1-perc);   


    if (id==2)
    {
      colors.selectColor(correctedPerc);
    }
    else if (id==3)
    {
      brush.setSize (correctedPerc);
    }
  }
  catch (Exception e) {
  }
}






void onTokenDetection (String tokenID, char tokenType, float value, float x, float y, float z)
{
  // just ignore the x y z in this case
  onTokenDetection (tokenID, tokenType, value);
}



class BrushWidget
{
  BrushWidget (int x, int y, int size)
  {
    this.x=x;
    this.y=y;
    this.size= size;
    brushScale= size-10; // any number for deciding the max size of the brush
    col= color(0);
    brushSize= MIN_BRUSHSIZE;
  }
  
  void setSize (float p)
  {
    brushSize= (int)(p*brushScale);
    // round to the 5
    brushSize= brushSize/10*10;
    if (brushSize<MIN_BRUSHSIZE)  brushSize=MIN_BRUSHSIZE;
    if (brushSize>MAX_BRUSHSIZE) brushSize= MAX_BRUSHSIZE;
  }

  int getBrushSize()
  {
    return brushSize;
  }
  
  void setBrushColor(color c)
  {
     col= c; 
  }

  void draw()
  {
    strokeWeight(1);
    stroke(0);
    fill(col);
    ellipseMode(CENTER);
    ellipse(x+size/2, y+size/2, brushSize, brushSize);
  }



  int x, y, size;
  int brushScale;
  int brushSize;
  color col;

  int MIN_BRUSHSIZE=10;
  int MAX_BRUSHSIZE=100;
}










class ColorBar
{
  ColorBar(int x, int y, int width, int height)
  {
    this.x= x;
    this.y=y;
    this.width=width;
    this.height=height;

    colors= new color[6];
    colors[0]= color(255, 255, 255); 
    colors[1]= color(255, 255, 0);
    colors[2]= color(255, 0, 255);
    colors[3]= color(255, 0, 0); 
    colors[4]= color(0, 255, 0); 
    colors[5]= color(0, 0, 255);  
      
    selectedColor= color(0);
  }

  void draw()
  {
    noFill();
    stroke(0);
    strokeWeight(2);
    rect(x, y, width, height);
    for (int i = 0; i < width; i++) {
      color c= getColor (i);
      stroke(c);
      line(x+i, y, x+i, y+height);
    }

    int w= (int)(perc*width); 
    stroke(0);
    strokeWeight(3);
    line(x+w, y, x+w, y+height);
  }

  color getColor (int w)
  {
    int n= colors.length;
    int portion= width/n;

    int curr= w/portion;
    color A= colors[curr];
    color B= color(0);
    if (curr!=n-1)
    {
      B= colors[curr+1];
    }
    return  lerpColor (A, B, (float)(w%portion)/portion);
  }

  void selectColor (float p)
  {
    // a number from 0 to 1
    perc= p;
    if (perc<0) perc=0;
    if (perc>1) perc=1;
    int w= (int)(perc*width); 
    selectedColor= getColor (w);
  }

  color getSelectedColor() { 
    return selectedColor;
  }


  float perc;
  color selectedColor;
  color [] colors;
  int width, height, x, y;
}


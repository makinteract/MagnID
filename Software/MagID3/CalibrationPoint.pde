/***************************************************
Calibration Item
****************************************************/

interface CalibrationPointListener
{
  void onSelect (CalibrationPoint cpoint);
  void onDeselect (CalibrationPoint cpoint);
  void onCalibrationDone (CalibrationPoint cpoint);
}




abstract class CalibrationPoint
{
  CalibrationPoint (String id)
  {
    this.id= id;
    size= CALIBRATION_POINT_SIZE;
    selected=false;
    click= false;
    dx=dy=0;
    x=y=0;
    itemColor= GREY; // default color parent class
    calibrating=false;

    font = loadFont(dataPath("basicFont48.vlw"));
    textFont(font, FONT_HEIGHT);


    // Token init: choose the token for calibration
    Token t= AppManager.Instance().getCalibrationToken();

    String tid= t.getID();
    int freq= t.getFrequency();
    String filtername= AppManager.Instance().getFilterByFreq(freq);

    token= new CalibrationToken (tid, freq, filtername);
    AppManager.Instance().listenMagnet(token);
    calibrationData= new ArrayList<PVector>();
  }


  void setListener (CalibrationPointListener listener)
  {
    this.listener= listener;
  }


  XML getXmlDescriptor()
  {
    XML token= new XML ("CalibrationPoint");
    token.setString("type", this.getClass().getSimpleName());
    token.setString("id", id);
    token.setInt("x", x);
    token.setInt("y", y);
    return token;
  }


  String getID() { 
    return id;
  }

  String getCalibrationTokenID()
  {
    return token.getID();
  }

  void setXY (int x, int y)
  {
    this.x=x;
    this.y=y;
  }

  boolean isSelected()
  {
    return selected;
  }

  void deselect()
  {
    selected=false;
  }

  void select()
  {
    selected=true;
  }

  void draw (PApplet window)
  {
    update(window);

    window.pushMatrix();
    window.translate(x, y);

    window.stroke(BLACK);
    window.strokeWeight(1);

    if (selected)
    {
      window.strokeWeight(2);
      window.stroke(RED);
    }

    window.fill (itemColor);
    window.rect(0, 0, size, size);

    if (!isCalibrated()) {
      window.fill(DARK_GREY, 220);
      window.rect(0, 0, size, size);
    }

    // loading bar
    if (calibrating)
    {
      float perc= (float)(calibrationData.size())/TOT_CALIBRATION_POINTS;
      window.stroke(BLACK);
      window.fill(WHITE);
      window.rect (0, size-2*LOADING_HEIGHT, size, LOADING_HEIGHT);
      window.fill(RED);
      window.rect (0, size-2*LOADING_HEIGHT, size*perc, LOADING_HEIGHT);
    }

    window.fill(WHITE);
    window.textAlign(CENTER);
    window.textFont(font, FONT_HEIGHT);
    window.text(id, size/2, 2*size/3);

    window.popMatrix();
  }


  private void update(PApplet window)
  {
    if (calibrating && !isCalibrated())
    {
      PVector v= token.getData();
      calibrationData.add (v);

      if (isCalibrated())
      {
        onCalibrationDone();
      }
    }


    if (window.mousePressed)
    {
      if (!click)
      {
        click= true;

        if (isOver(window))
        {
          if (!selected)
          {
            selected= true;
            selected= true;
            dx= window.mouseX-x;
            dy= window.mouseY-y;
            onSelect();
          }
        }
        else {
          if (selected)
          {
            selected= false;
            onDeselect();
          }
        }
      }
    }
    else { // if clicked
      click=false;
    }

    if (selected && click)
    {
      // move
      x= window.mouseX-dx;
      y= window.mouseY-dy;
      //block
      if (x<=0) x=0;
      if (x> window.width-HOME_BUTTON_WIDTH-size) x= window.width-HOME_BUTTON_WIDTH-size;
      if (y<=0) y=0;
      if (y> window.height-size) y= window.height-size;
    }
  }

  void onSelect()
  {
    if (listener!=null) listener.onSelect (this);
  }

  void onDeselect()
  {
    if (listener!=null) listener.onDeselect (this);
  }

  void onCalibrationDone()
  {
    if (listener!=null) listener.onCalibrationDone (this);
    calibrating=false;
  }

  void calibrate ()
  { 
    calibrating=true;
    calibrationData= new ArrayList<PVector>();
  }

  boolean isCalibrated()
  {
    return calibrationData.size() == TOT_CALIBRATION_POINTS;
  }

  String getCalibrationData ()
  {
    String res="";
    for (PVector data: calibrationData)
    {
      res+= id +","+ data.x +","+ data.y +","+ data.z +"\n";
    }
    return res;
  }



  private boolean isOver (PApplet window)
  {
    if (window.mouseX<x || window.mouseX>x+size) return false;
    if (window.mouseY<y || window.mouseY>y+size) return false;
    return true;
  }

  int CALIBRATION_POINT_SIZE= 50;
  int CALIBRATION_TIME_MS=1000;


  public final int FONT_HEIGHT=30;


  int x, y, size;
  PFont font;

  boolean selected, click;
  int dx, dy;

  String id;
  CalibrationPointListener listener;
  protected color itemColor;

  boolean calibrating;
  CalibrationToken token;
  ArrayList <PVector> calibrationData;
  public final int LOADING_HEIGHT= 2;
}




class PositionCalibrationPoint extends CalibrationPoint
{
  PositionCalibrationPoint (String id)
  {
    super (id);
    itemColor= BLUE;
  }
}


class SliderCalibrationPoint extends CalibrationPoint
{
  SliderCalibrationPoint (String id)
  {
    super (id);
    itemColor= DARK_GREEN;
  }
}


class RotationCalibrationPoint extends CalibrationPoint
{
  RotationCalibrationPoint (String id)
  {
    super (id);
    itemColor= PURPLE;
  }
}

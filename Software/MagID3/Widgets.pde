/***************************************************
PFrame
****************************************************/

public class PFrame extends JFrame {
  PApplet hnd;

  public PFrame(PApplet content, int w, int h, String title) {
    init(content, w, h, title, null);
  }

  public PFrame(PApplet content, int w, int h, String title, WidgetListener listener) {
    init(content, w, h, title, listener);
  }


  public void init(PApplet content, int w, int h, String title, WidgetListener listener) {
    hnd=content;

    ((Widget)(hnd)).initializeSize(w, h, sketchPath(""));

    if (listener!=null) // add an optional listener
    { 
      ((Widget)(hnd)).setListener(listener);
    }

    add(hnd);
    hnd.init();
    show();
    setBounds(0, 0, w, h);
    setResizable(false);
    setTitle(title);
    this.addWindowListener(new java.awt.event.WindowAdapter() {
      public void windowClosing(java.awt.event.WindowEvent windowEvent) {
        hnd.stop();
      }
    }
    );
  }
}


/***************************************************
Widget superclass
****************************************************/


interface WidgetListener
{
  public void onWidgetClose (PApplet app);
}


abstract public class Widget extends PApplet
{

  void initializeSize (int w, int h, String path)
  {
    width= w;
    height=h;
    sketchpath= path;
    datapath= sketchpath+"data/";
  }

  void setListener (WidgetListener ctr)
  {
    listener=ctr;
  }

  void stop()
  {
    if (listener!=null) listener.onWidgetClose (this);
    super.stop();
  }

  String dataPath (String path)
  {
    return datapath+path;
  }

  String sketchPath (String path)
  {
    return sketchpath+path;
  }

  String getRelativeDataPath (String path)
  {
    return "data/"+path;
  }

  protected int width, height; // override the default ones
  protected String sketchpath, datapath;
  protected WidgetListener listener;
}


/***************************************************
Raw Signal Widget
****************************************************/


public class SignalWidget extends Widget {

  public void setup() 
  {
    index=0;
    drawx= new float[width];
    drawy= new float[width];
    drawz= new float[width];   

    setZoom(1000);

    plus= new SimpleButton (this, new ButtonListener() {
      public void buttonPressed(Button b) {
        handleButtonEvents(b);
      }
    } 
    , dataPath("/Widgets/plus.png"));

    minus= new SimpleButton (this, new ButtonListener() {
      public void buttonPressed(Button b) {
        handleButtonEvents(b);
      }
    } 
    , dataPath("/Widgets/minus.png"));

    font = loadFont(dataPath("basicFont12.vlw"));
    textFont(font, FONT_HEIGHT);
  }



  void setZoom (int val)
  {
    if (2*abs(val) <= MIN_DELTA) return;
    if (2*abs(val) >= MAX_DELTA) return;
    miny= -abs(val);
    maxy=  abs(val);
  }

  public void draw() 
  {
    background(0);
    // draw the 0 line
    stroke(LIGHT_GREY);
    line(0, height/2, width, height/2);

    for (int i=1; i<index; i++)
    {
      stroke(RED);
      line(i-1, scaleY(prevx), i, scaleY(drawx[i]));
      prevx= (int)drawx[i];

      stroke(GREEN);
      line(i-1, scaleY(prevy), i, scaleY(drawy[i]));
      prevy= (int)drawy[i];

      stroke(BLUE);
      line(i-1, scaleY(prevz), i, scaleY(drawz[i]));
      prevz= (int)drawz[i];
    }

    // draw the h line
    stroke(YELLOW);
    fill(YELLOW);
    line(0, mouseY, width, mouseY);
    int y= mouseY;
    if (mouseY < height/2)
      y= mouseY+FONT_HEIGHT;

    text(getValueAtY(mouseY), width-20, y); 

    // buttons
    plus.draw(width-2*BUTTON_SIZE, BUTTON_SIZE);
    minus.draw(width-2*BUTTON_SIZE, 3*BUTTON_SIZE);
  }


  int scaleY (float y)
  {
    int ret= height-(int)(((y-miny)/((float)maxy-miny))*height);

    if (ret<0) return 0;
    if (ret>height) return height;
    return ret;
  }

  int getValueAtY (int y)
  {
    return 2*(height/2-y)*maxy/height;
  }



  void setSignal (float x, float y, float z)
  {
    if (drawx==null || drawy==null || drawz==null) return;
    drawx[index]= x;
    drawy[index]= y;
    drawz[index++]= z;

    if (index>=width) {
      index=0;
      drawx= new float[800];
      drawy= new float[800];
      drawz= new float[800];
    }
  }

  void handleButtonEvents(Button button) {
    if (button == plus)
    {
      if (maxy-miny <= MIN_DELTA) return;
      miny+= ZOOM_FACTOR;
      maxy-= ZOOM_FACTOR;
    } 
    else if (button == minus)
    {
      if (maxy-miny >= MAX_DELTA) return;
      miny-= ZOOM_FACTOR;
      maxy+= ZOOM_FACTOR;
    }
  }


  // private 
  private int index, prevx, prevy, prevz;
  private float[] drawx;
  private float[] drawy;
  private float[] drawz;

  private int miny, maxy;
  private PFont font;
  // Buttons
  private SimpleButton plus, minus;


  public final int BUTTON_SIZE=20;
  public final int MIN_DELTA=50;
  public final int MAX_DELTA=4000;
  public final int ZOOM_FACTOR=50;

  public final int FONT_HEIGHT=12;
}


/***************************************************
Magnetic signal widget
****************************************************/


public class MagneticSignalWidget extends SignalWidget implements Observer {

  MagneticSignalWidget()
  {
    super();
  }

  public void update(Observable obs, Object arg)
  {
    MagData data= (MagData)obs;
    if (data!=null) setSignal(data.x(), data.y(), data.z());
  }
}



/***************************************************
Console widget
****************************************************/


public class ConsoleWidget extends Widget {

  public void setup() 
  {
    font = loadFont(dataPath("basicFont20.vlw"));
    textFont(font, FONT_HEIGHT);
    maxLines= height/FONT_HEIGHT-1;
    msgHistory= new ArrayList<Message>();
  }

  public void draw() 
  {
    background(BLACK);

    for (int i=0; i<msgHistory.size(); i++)
    {
      Message m=msgHistory.get(i);
      fill(YELLOW);
      text(m.timeStamp, 10, i*FONT_HEIGHT);
      fill(GREEN);
      text(m.packet, 100, i*FONT_HEIGHT);
    }
  }

  public void write (String message)
  {
    if (msgHistory==null) return;

    if (msgHistory.size()==maxLines)
    {
      msgHistory.remove(maxLines-1);
    }
    String timeStamp= hour()+":"+minute()+":"+second()+"    ";
    msgHistory.add(0, new Message(timeStamp, message)); // add in front
  }

  class Message
  {
    Message (String ts, String ms)
    {
      timeStamp=ts;
      packet=ms;
    }

    String timeStamp;
    String packet;
  }

  // PRIVATE 
  private ArrayList<Message> msgHistory;
  private PFont font;
  private int maxLines;
  public final int FONT_HEIGHT=15;
}



/***************************************************
FFT (Frequency spectrum) widget
****************************************************/


class FrequencyWidget extends Widget implements Observer {

  void setup()
  {
    if (!isPowerOfTwo(FFT_SIZE)) throw new RuntimeException ("Not a power of two");
    this.fftSize= FFT_SIZE;
    this.fs= SAMPLIG_FREQ;
    reset();
    setChannel(0); // default X channel

    // for drawing
    zoom= 5;
    step= (int)((float)(2*width)/fftSize);
    font = loadFont(dataPath("basicFont12.vlw"));
    textFont(font, FONT_HEIGHT);

    plus= new SimpleButton (this, new ButtonListener() {
      public void buttonPressed(Button b) {
        zoomIn();
      }
    } 
    , dataPath("/Widgets/plus.png"));

    minus= new SimpleButton (this, new ButtonListener() {
      public void buttonPressed(Button b) {
        zoomOut();
      }
    } 
    , dataPath("/Widgets/minus.png"));

    channelButton= new SimpleButton (this, new ButtonListener() {
      public void buttonPressed(Button b) {
        nextChannel();
      }
    } 
    , dataPath("/Widgets/channel.png"));
  }


  void zoomIn() { 
    if (zoom<MAX_ZOOM) zoom++;
  }
  void zoomOut() { 
    if (zoom>MIN_ZOOM) zoom--;
  }

  void setChannel (int c)
  {
    channel= c;
    if (channel==0) defaultColor= RED;
    if (channel==1) defaultColor= GREEN;
    if (channel==2) defaultColor= BLUE;
  }

  void nextChannel()
  {
    setChannel((channel+1)%3);
  }

  public void add (Complex x, Complex y, Complex z)
  {
    if (fftArrX==null || fftArrY==null || fftArrZ==null) return;

    fftArrX[index] = x;
    fftArrY[index] = y;
    fftArrZ[index++] = z;

    if (index==fftSize) {
      if (channel==0)
        displayedChannel= FFT.fft(fftArrX);
      else if (channel==1)
        displayedChannel= FFT.fft(fftArrY);
      else
        displayedChannel= FFT.fft(fftArrZ);

      index=0;
    }
  }

  public void update(Observable obs, Object arg)
  {
    MagData data= (MagData)obs;
    if (data!=null)
    {
      add (new Complex(data.x(), 0), new Complex(data.y(), 0), new Complex(data.z(), 0));
    }
  }


  void draw ()
  { 
    background(0);

    if (displayedChannel!=null)
    { 
      fill(defaultColor);
      stroke(defaultColor);

      int h=step;
      for (int i=1; i<displayedChannel.length/2; i++)
      {
        int val= (int)(zoom*(((float)displayedChannel[i].abs())/fftSize));
        rect (h, height-val, step, height);
        h+= step;
      }
    }

    // vertical line
    stroke(YELLOW);
    fill(YELLOW);
    line (mouseX, 0, mouseX, height);
    if (mouseX <= width/2) {
      text((int)xcoordToFreq(mouseX)+"Hz", mouseX+FONT_HEIGHT, FONT_HEIGHT);
    }
    else {
      text((int)xcoordToFreq(mouseX)+"Hz", mouseX-3*FONT_HEIGHT, FONT_HEIGHT);
    }

    // horizontal line
    stroke(PURPLE);
    fill(PURPLE);
    line (0, mouseY, width, mouseY);
    if (mouseY <= height/2) {
      text((int)ycoordToValue(mouseY), width-2*FONT_HEIGHT, mouseY+FONT_HEIGHT);
    }
    else {
      text((int)ycoordToValue(mouseY), width-2*FONT_HEIGHT, mouseY-FONT_HEIGHT);
    }

    // text
    if (channel==0) {
      fill(RED); 
      text("X", FONT_HEIGHT, FONT_HEIGHT);
    }
    if (channel==1) {
      fill(GREEN); 
      text("Y", FONT_HEIGHT, FONT_HEIGHT);
    }
    if (channel==2) {
      fill(WHITE); 
      text("Z", FONT_HEIGHT, FONT_HEIGHT);
    }


    // buttons
    if (plus==null || minus==null) return;
    plus.draw(width-2*BUTTON_SIZE, BUTTON_SIZE);
    minus.draw(width-2*BUTTON_SIZE, 3*BUTTON_SIZE);
    channelButton.draw(width-2*BUTTON_SIZE, 6*BUTTON_SIZE);
  }


  private boolean isPowerOfTwo (int x)
  {
    return (x != 0) && ((x & (x - 1)) == 0);
  }

  private  void reset()
  {
    fftArrX= new Complex[fftSize];
    fftArrY= new Complex[fftSize];
    fftArrZ= new Complex[fftSize];
    for (int i=0; i<fftSize; i++)
    {
      fftArrX[i]= new Complex(0, 0);
      fftArrY[i]= new Complex(0, 0);
      fftArrZ[i]= new Complex(0, 0);
    }
    index=0;
  }


  private float xcoordToFreq (int x)
  {
    x= x/step;
    return (float)((float)x*fs)/fftSize;
  }

  private float ycoordToValue (int y)
  {
    return (height-y)/zoom;
  }


  // PRIVATE 
  private Complex []fftArrX;
  private Complex []fftArrY;
  private Complex []fftArrZ;
  private FreqVal [] frequencies;
  private Complex [] displayedChannel;

  private int index;
  private int fftSize;
  private float fs; // fs is samplig freq
  private int step, channel;
  private color defaultColor;
  private int zoom;
  private PFont font;

  // Buttons
  private SimpleButton plus, minus, channelButton;

  public final int FONT_HEIGHT=12;
  public final int MAX_ZOOM=10;
  public final int MIN_ZOOM=1;
  public final int BUTTON_SIZE=20;


  // INNER CLASS

  class FreqVal
  {
    FreqVal (int a) {
      freq=a;
    }

    void show() {
      println(freq+"  "+amp);
    }

    int freq;
    double amp;
  }


  public class FreqValComparator implements Comparator<FreqVal> {
    @Override
      // sort from largest to smallest
    public int compare(FreqVal o1, FreqVal o2) {
      return (int)(o2.amp-o1.amp);
    }
  }
}




/***************************************************
New File Window
****************************************************/


public class NewFileWindow extends JFrame
{
  public NewFileWindow()
  {
    getContentPane().setLayout(null);
    setupGUI();
  }


  void setupGUI()
  {
    cancelButton = new JButton();
    cancelButton.setLocation(15, 52);
    cancelButton.setSize(90, 32);
    cancelButton.setText("Cancel");
    cancelButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e)
      {
        dispose();
      }
    }
    ); 

    getContentPane().add(cancelButton);

    okButton = new JButton();
    okButton.setLocation(110, 52);
    okButton.setSize(90, 32);
    okButton.setText("Ok");
    okButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e)
      {
        AppManager.Instance().newWorkSpace(text.getText());
        dispose();
      }
    }
    ); 

    getContentPane().add(okButton);

    text = new JTextArea();
    text.setLocation(16, 17);
    text.setSize(182, 25);
    text.setText("FileName_workspace");
    text.setRows(5);
    text.setColumns(5);
    getContentPane().add(text);

    setTitle("New File");
    setSize(226, 120);
    setVisible(true);
    setResizable(false);
  }

  private JButton cancelButton;
  private JButton okButton;
  private JTextArea text;
}  



/***************************************************
Calibration widget
****************************************************/



class CalibrationWidget extends Widget implements CalibrationPointListener
{
  public void setup() 
  {
    font = loadFont(dataPath("basicFont48.vlw"));
    textFont(font, FONT_HEIGHT);

    calibrationPoints= AppManager.Instance().getCalibrationPoints();

    // init for drawing
    // also init the rotaitonPoint if you find a calinbration point with ID 0
    for (CalibrationPoint cp : calibrationPoints)
    {
      cp.setListener(this);
      if (cp.getID().equals("0"))
      {
        rotationPoint= (RotationCalibrationPoint)cp; // we found a rotation point initialized
      }
    }

    selectedPoint= null;


    // Buttons
    ButtonListener bl= new ButtonListener() {
      public void buttonPressed(Button b) {
        pressButton(b);
      }
    };

    posBut= new SimpleButton (this, bl, dataPath("Widgets/calibrationPos.png")); 
    sliderBut= new SimpleButton (this, bl, dataPath("Widgets/calibrationSlider.png")); 
    rotationBut= new SimpleButton (this, bl, dataPath("Widgets/calibrationRotation.png")); 
    calibrateBut= new SimpleButton (this, bl, dataPath("Widgets/calibrationCalibrate.png")); 
    deleteBut= new SimpleButton (this, bl, dataPath("Widgets/calibrationDelete.png")); 
    saveBut= new SimpleButton (this, bl, dataPath("Widgets/calibrationSave.png"));
  }

  public void draw() 
  {
    background(GREY);

    if (AppManager.Instance().getNumberOfTokens() ==0) return;
    
    // Write text with instructions
    fill(YELLOW);
    textFont(font, FONT_HEIGHT);
    String s= AppManager.Instance().getCalibrationToken().getID();
    textAlign (LEFT);
    text("Calibrate using token with ID: "+s, 20, 20);

    // draw semaphore with signal strength
    Token t= AppManager.Instance().getCalibrationToken();
    float strength= t.getSignalStrength();
    stroke (WHITE);
    if (strength>=HIGH_STRENGHT_SIGNAL)
    {  
      fill(GREEN);
    }
    else if (strength>=LOW_STRENGHT_SIGNAL)
    {
      fill(YELLOW);
    }
    else {
      //LOW
      fill(RED);
    }
    ellipseMode(CENTER);
    ellipse(10, 15, 10, 10);


    // buttons
    int x= width-HOME_BUTTON_WIDTH;
    int y=0;
    posBut.draw(x, y);
    sliderBut.draw (x, y+HOME_BUTTON_HEIGHT);
    rotationBut.draw (x, y+HOME_BUTTON_HEIGHT*2);
    calibrateBut.draw (x, y+HOME_BUTTON_HEIGHT*3);
    deleteBut.draw (x, y+HOME_BUTTON_HEIGHT*4);
    saveBut.draw (x, y+HOME_BUTTON_HEIGHT*5); 

    // draw points
    for (CalibrationPoint cp : calibrationPoints) 
      cp.draw(this);
  }





  void pressButton (Button button)
  {
    if (button == posBut)
    {
      // add position point
      CalibrationPoint cp= new PositionCalibrationPoint (AppManager.Instance().getCalibrationID());
      cp.setListener (this);
      cp.setXY(0, 0);
      calibrationPoints.add (cp);
    }
    else if (button == sliderBut) {
      // add slider point
      CalibrationPoint cp= new SliderCalibrationPoint (AppManager.Instance().getCalibrationID());
      cp.setListener (this);
      cp.setXY(0, 0);
      calibrationPoints.add (cp);
    }
    else if (button == rotationBut)
    {
      if (rotationPoint==null)
      {
        rotationPoint= new RotationCalibrationPoint ("0"); // 0 -> id is not important for rotation
        rotationPoint.setListener (this);
        rotationPoint.setXY(0, 0);
        calibrationPoints.add (0, rotationPoint); // add at the beginning of the list
        // Rotation id is 0 so it always go at the beginning of the list!
      } 
    }
    else if (button == saveBut)
    {
      saveTrainingFiles();
    }
    else if (button == calibrateBut)
    {
      if (selectedPoint != null) {
        selectedPoint.calibrate();
      }
    }
    else if (button == deleteBut)
    {
      // try to remove from each of hashmaps
      if (selectedPoint != null)
      {
        calibrationPoints.remove (selectedPoint);
        if (rotationPoint==selectedPoint) rotationPoint=null;
        selectedPoint=null;
      }
    }
  }


  void saveTrainingFiles()
  {
    try {
      // POSITION AND SLIDER
      File fpos= new File(AppManager.Instance().getPositionTrainingFile());
      File fslider= new File(AppManager.Instance().getSliderTrainingFile());
      PrintWriter pos= new PrintWriter (fpos);
      PrintWriter slider= new PrintWriter (fslider);

      // make attributes
      String attributesPos="@attribute id {";
      for (CalibrationPoint cp : calibrationPoints) {
        if (cp.getClass().getSimpleName().equals("PositionCalibrationPoint"))
          attributesPos+= cp.getID()+",";
      }
      attributesPos+="0}\n";// close

      // print the header of the arff file
      pos.println("@relation magnetic\n");
      pos.println(attributesPos);
      pos.println("@attribute x numeric\n@attribute y numeric\n@attribute z numeric\n@data\n");
     
      slider.println("@relation magnetic\n");
      slider.println("@attribute id numeric\n@attribute x numeric\n@attribute y numeric\n@attribute z numeric\n@data\n");
     

      for (CalibrationPoint cp : calibrationPoints) {
        if (cp.getClass().getSimpleName().equals("PositionCalibrationPoint")){
          pos.println(cp.getCalibrationData());
        }else if (cp.getClass().getSimpleName().equals("SliderCalibrationPoint")){
          slider.println(cp.getCalibrationData());
        }
      }

      // default values
      // NOTE: in case the file is empty
      // you do not need default values as the exception will take care
      pos.println("0,0,0,0"); // set 0 position as default
      
      
      pos.close();
      slider.close();

      // ROTATION FILE
      File frot= new File(AppManager.Instance().getRotationTrainingFile());
      PrintWriter rot= new PrintWriter (frot);

      if (rotationPoint!=null)
      {
        rot.println(rotationPoint.getCalibrationData());
      }else{
        rot.println("0,0,0,0");
      }
      rot.close();
    }
    catch (Exception e) {
    }
  }


    



  void onSelect(CalibrationPoint cpoint)
  { 
    //deselect all
    for (CalibrationPoint cp : calibrationPoints)
      cp.deselect();

    selectedPoint= cpoint;
    selectedPoint.select();
  }

  void onDeselect(CalibrationPoint cpoint)
  {
    selectedPoint=null;
  }

  void onCalibrationDone(CalibrationPoint cpoint) {
  }


  // private 
  private PFont font;
  
  private SimpleButton posBut, sliderBut, rotationBut, saveBut, deleteBut, calibrateBut;
  private ArrayList<CalibrationPoint> calibrationPoints;

  private CalibrationPoint selectedPoint;
  private RotationCalibrationPoint rotationPoint;

  public final int FONT_HEIGHT=20;
}

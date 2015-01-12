/***************************************************
MAIN GUI
****************************************************/

class MainGUI
{
  MainGUI(PApplet window)
  {
    hnd= window;

    ButtonListener bl= new ButtonListener() {
      public void buttonPressed(Button b) {
        pressButton(b);
      }
    };

    rawSignalButton= new SimpleButton (hnd, bl, dataPath("MainInterface/raw.png"));   
    fftButton= new SimpleButton (hnd, bl, dataPath("MainInterface/fft.png")); 
    consoleButton=new SimpleButton (hnd, bl, dataPath("MainInterface/console.png")); 
    calibrationButton=new SimpleButton (hnd, bl, dataPath("MainInterface/calibration.png")); 
    newButton= new SimpleButton (hnd, bl, dataPath("MainInterface/new.png"));
    loadButton= new SimpleButton (hnd, bl, dataPath("MainInterface/load.png"));

    networkButton= new ToggleButton (hnd, bl, dataPath("MainInterface/pause.png"), dataPath("MainInterface/start.png"));

    bar= new StatusBar (STATUS_BAR_HEIGHT);

    setupTokenGUI();
  }

  void draw()
  {
    background(GREY);
    drawButtons (width-HOME_BUTTON_WIDTH, 0);
    drawTokenGUI (0, (height-TOKEN_SIZE*2)/2);
  }


  void drawButtons  (int x, int y)
  {
  // status bar
  bar.draw();

  // draw buttons
  rawSignalButton.draw(x, y);
  fftButton.draw(x, y+HOME_BUTTON_HEIGHT);
  consoleButton.draw(x, y+HOME_BUTTON_HEIGHT*2);
  calibrationButton.draw(x, y+HOME_BUTTON_HEIGHT*3);
  newButton.draw(x, y+HOME_BUTTON_HEIGHT*4);
  loadButton.draw(x, y+HOME_BUTTON_HEIGHT*5);

  networkButton.draw(0, 0);
}


void setupTokenGUI ()
{
  Set<String> tokenIds= AppManager.Instance().getTokenIdSet();
  int i=0;
  tokens= new ArrayList <TokenGUI>();
  for (String id : tokenIds)
  {
    tokens.add (new TokenGUI (hnd, id, TOKEN_SIZE));
  }
}

void drawTokenGUI (int x, int y)
{
  for (int i=0; i<tokens.size(); i++)
  {
    int row= i/4;
    int col= i%4;
    tokens.get(i).draw(x+col*TOKEN_SIZE, y+row*TOKEN_SIZE);
  }
}

void pressButton (Button button) { 
  if (button ==rawSignalButton) AppManager.Instance().showRowSignal();
  else if (button ==fftButton) AppManager.Instance().showFFT();
  else if (button ==consoleButton) AppManager.Instance().startNetworkConsole();
  else if (button ==calibrationButton) AppManager.Instance().startCalibration();
  else if (button ==loadButton) {
    AppManager.Instance().loadFile("mt"); 
    setupTokenGUI();
  }
  else if (button ==newButton)  new NewFileWindow();
  else if (button ==networkButton) AppManager.Instance().toggleNetworkActivityStatus();
}


private PApplet hnd;
private SimpleButton rawSignalButton, consoleButton, calibrationButton;
private SimpleButton newButton, loadButton, fftButton;
private ToggleButton networkButton;
private ArrayList<TokenGUI> tokens;
private StatusBar bar;
}



/***************************************************
TOKEN GUI
****************************************************/

class TokenGUI implements ButtonListener, WidgetListener
{
  TokenGUI (PApplet app, String tokenID, int size)
  {
    token= AppManager.Instance().getTokenById(tokenID);

    this.size=size;
    mainButtonSize= size/2;
    smallButtonSize= size/5;
    margin=smallButtonSize/3;
    ballSize= margin;
    fontSize= smallButtonSize/2;

    onoff= new ToggleButton (app, this, smallButtonSize, smallButtonSize, dataPath("Token/on.png"), dataPath("Token/off.png"));
    onoff.setState(token.isActive());

    explorer= new SimpleButton (app, this, smallButtonSize, smallButtonSize, dataPath("Token/explorer.png"));
    mainButton= new MultistateButton (app, this, mainButtonSize, mainButtonSize, new String[] {
      dataPath("Token/position.png"), dataPath("Token/identity.png"), dataPath("Token/slider.png"), dataPath("Token/rotation.png")
    }
    );

    // set correct image
    if (token.getClass() == PositionToken.class) {
      mainButton.setState (0);
    }
    else if (token.getClass() == IdentificationToken.class) {
      mainButton.setState (1);
    }
    else if (token.getClass() == SliderToken.class) {
      mainButton.setState (2);
    }
    else {
      mainButton.setState (3);
    }


    font = loadFont(dataPath("basicFont48.vlw"));
    textFont(font, fontSize);
  }  


  void draw (int x, int y)
  {    

    pushMatrix();
    translate(x, y);

    stroke(WHITE);
    strokeWeight(1);
    fill (LIGHT_GREY);
    rect(0, 0, size, size);

    // signal strength
    float strength= token.getSignalStrength();
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
    ellipse(size-margin, margin, ballSize, ballSize);


    // text
    textAlign(RIGHT);
    fill(YELLOW);
    text("ID: "+token.getID(), size-margin, size-fontSize-margin);
    fill(RED);
    text("Freq: "+token.getFrequency()+" Hz", size-margin, size-margin);
    popMatrix();

    // main button + explorer
    mainButton.draw(x+size/4, y+size/4);
    explorer.draw(x+margin, y+size-margin-smallButtonSize);

    pushMatrix();
    translate(x, y);
    if (!token.isActive())
    {
      fill(DARK_GREY, 200);
      rect(0, 0, size, size);
    }
    popMatrix();

    // on off button
    onoff.draw(x+margin, y+margin);
  }



  void buttonPressed (Button b)
  {
    if (b==onoff)
    {
      token.toggle();
      token.reload();
    }
    if (!token.isActive()) return;

    if (b==explorer)
    {      
      // if (token.getClass() != RotationToken.class)
      // {
      if (filterWindow!=null) {
        return; // already open
      }

      filterWindow= new MagneticSignalWidget(); 
      new PFrame (filterWindow, 800, 400, "Filtered Signal: "+token.getFrequency()+" Hz");
      filterWindow.setZoom(100);
      filterWindow.setListener(this);
      ((FixFrequencyToken)token).listenFilteredSignal(filterWindow);
      // }
      // else {
      //   AppManager.Instance().showFFT();
      // }
    }

    if (b==mainButton)
    {
      MultistateButton but= (MultistateButton)(mainButton);
      but.next();
      String tokenID= token.getID();

      switch (but.getState())
      {
        case 0: 
        AppManager.Instance().changeToken(token.getID(), PositionToken.class); 
        break;
        case 1: 
        AppManager.Instance().changeToken(token.getID(), IdentificationToken.class);
        break;
        case 2: 
        AppManager.Instance().changeToken(token.getID(), SliderToken.class);
        break;
        case 3:         
        AppManager.Instance().changeToken(token.getID(), RotationToken.class);
      
        // START HACK - REMOVE THIS LINES TO REPRISTINATE ROTATION TOKENS
        but.next();
        AppManager.Instance().changeToken(token.getID(), PositionToken.class);
        //  END HACK 
        break;
      }

      // replace the token instance, as we just substituted it
      token= AppManager.Instance().getTokenById(tokenID);
    }
  }


  void onWidgetClose (PApplet widget)
  {
    if (widget==filterWindow) filterWindow=null;
  }


  private ToggleButton onoff;
  private SimpleButton explorer; 
  private MultistateButton mainButton;

  private Token token;
  private PFont font;
  private int size, smallButtonSize, mainButtonSize, margin, fontSize, ballSize;
  private MagneticSignalWidget filterWindow;
}



/***************************************************
Status BAR
****************************************************/

class StatusBar
{
  StatusBar(int h)
  {
    this.y= height-h;
    this.h= h;

    font = loadFont(dataPath("basicFont48.vlw"));
  } 

  void draw ()
  {
    noStroke();
    textFont(font, h);
    fill(DARK_GREY);
    rect (0, y, width, h);

    fill(YELLOW);
    textAlign(LEFT);
    text(AppManager.Instance().getStatusMessage(), MARGIN, height-2);
  }


  private int y, h;
  private PFont font;
  public final int MARGIN=10;
}



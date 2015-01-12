static class AppManager implements WidgetListener
{
  // access singleton
  public static AppManager Instance() {
    return SingletonHolder.INSTANCE;
  }  

  void init (PApplet app)
  {
    hnd= (MagID3)app;
    magnet= hnd.new MagData();


    // Widgets (raw magnetic signal and network)
    raw=null; 
    console=null;
    fft=null;
    calibrationWindow=null;

    // variables
    statusMessage="";
    totalTokens=0;

    // Load Workspace
    trainPositionFile="";
    trainSliderFile="";
    trainRotationFile="";

    try {
      loadConfigurations (hnd.dataPath("config.xml"));
      loadWorkspace (getWorkspaceFilePath("default_workspace.mt"));
    }
    catch (Exception e) 
    {
      JOptionPane.showMessageDialog (hnd.frame, "An error occurred reading the xml files.");
      System.exit(0);
    }

    setupNetwork();
  }


  // status message
  String getStatusMessage()
  {
    return statusMessage;
  }


  void setStatusMessage(String m)
  {
    statusMessage= m;
  }



  // network

  void setupNetwork ()
  {
    oscP5= new OscP5(hnd,MULTICAST_ADDRESS, OSC_PORT);
    networkActive= false;
  }


  void sendOscMessage (OscMessage message, String msg)
  {
    if (oscP5==null) return;
    if (!networkActive) return;
    oscP5.send(message);
    if (console!=null) console.write(msg);
  }

  void sendOscMessage (String id, char type, float value, float [] xyz)
  {
    if (oscP5==null) return ; 
    if (!networkActive) return;

    OscMessage message = new OscMessage("/MagID/token");
    message.add(id); 
    message.add(type); 
    message.add(value); 
    message.add(xyz); 
    String msg= id+", "+type+", "+value+", "+xyz[0]+", "+xyz[1]+", "+xyz[2];
    sendOscMessage (message, msg);
  }

  void toggleNetworkActivityStatus ()
  {
    networkActive^= true;
  }

           
  void oscStatus(OscStatus theStatus) {}



  // Widget Control
  void showRowSignal()
  {
    if (raw==null) {
      raw= hnd.new MagneticSignalWidget();
      listenMagnet(raw);
      hnd.new PFrame (raw, 800, 400, "Raw Signal", Instance());
    }
  }

  void showFFT()
  {
    if (fft==null) {
      fft= hnd.new FrequencyWidget();
      listenMagnet(fft);
      hnd.new PFrame (fft, FFT_WINDOW, 400, "Frequency Spectrum (FFT)", Instance());
    }
  }

  void startNetworkConsole()
  {
    if (console==null){
      console= hnd.new ConsoleWidget();
      hnd.new PFrame (console, 900, 400, "Console", Instance());
    }
  }

  void startCalibration ()
  {
    if (calibrationWindow==null) {
      calibrationWindow= hnd.new CalibrationWidget();
      hnd.new PFrame (calibrationWindow, 1000, 500, "Calibration", Instance());
    }
  }


  void onWidgetClose (PApplet content)
  {
    if (content==raw) raw= null;
    if (content==console) {
      console= null;
    }
    if (content==fft) fft=null;
    if (content==calibrationWindow)
    {
      calibrationWindow=null;
      // reload tokens
      for (Token token : tokens.values())
        token.reload();
    }
  }



  // Files
  void loadFile (String extention)
  {
    // set system look and feel 
    try { 
      UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
    } 
    catch (Exception e) { 
      e.printStackTrace();
    } 

    // create a file chooser 
    final JFileChooser fc = new JFileChooser(); 
    FileNameExtensionFilter filter = new FileNameExtensionFilter("MagnID Document (mt)", extention);
    fc.setFileFilter(filter);
    // in response to a button click: 
    int returnVal = fc.showOpenDialog(hnd); 

    if (returnVal == JFileChooser.APPROVE_OPTION) { 
      File file = fc.getSelectedFile(); 
      try {
        loadWorkspace (file.getAbsolutePath());
      }
      catch (IOException e) { 
        setStatusMessage("Error");
      }
    }
  }


  private void loadConfigurations (String fileName) throws IOException
  {
    XML xml = hnd.loadXML(fileName);
    XML[] constants = xml.getChildren("Constant");

    for (int i = 0; i < constants.length; i++) 
    {
      String id = constants[i].getString("id");

      if (id.equals("FFT_SIZE")) FFT_SIZE= constants[i].getInt("value");
      if (id.equals("SAMPLIG_FREQ")) SAMPLIG_FREQ= constants[i].getInt("value");
      if (id.equals("FIX_FREQ_TOKEN_TIME_FILTER_WINDOW_MS")) 
        FIX_FREQ_TOKEN_TIME_FILTER_WINDOW_MS= constants[i].getInt("value");

      if (id.equals("LOW_STRENGHT_SIGNAL")) LOW_STRENGHT_SIGNAL= constants[i].getFloat("value");
      if (id.equals("HIGH_STRENGHT_SIGNAL")) HIGH_STRENGHT_SIGNAL= constants[i].getInt("value");

      if (id.equals("SERIAL_PORT")) SERIAL_PORT= constants[i].getInt("value");
      if (id.equals("OSC_PORT")) OSC_PORT= constants[i].getInt("value");
      if (id.equals("MULTICAST_ADDRESS")) MULTICAST_ADDRESS= constants[i].getString("value");

      if (id.equals("WORKSPACE_DIR")) WORKSPACE_DIR= constants[i].getString("value");
      if (id.equals("FILTERS_DIR")) FILTERS_DIR= constants[i].getString("value");
      if (id.equals("CALIBRATION_TOKEN")) CALIBRATION_TOKEN= constants[i].getInt("value");
    }

    xml = xml.getChild("Filters");
    if (xml == null) throw new IOException ("No filters specified in xml file");
    XML[] filters= xml.getChildren("Filter");

    this.filters= new HashMap<String, String>();

    for (int i = 0; i < filters.length; i++) 
    {
      String frequency = filters[i].getString("frequency");
      String file = filters[i].getString("file");
      this.filters.put (frequency, file);
    }
  }



  private void loadWorkspace (String fileName) throws IOException
  {
    currentWorkspace= fileName;
    tokens= new HashMap<String, Token>(); // clean Tokens
    resetCalibration();

    setStatusMessage ("Workspace:  "+ fileName); // set status bar
    totalTokens=0;

    XML xml = hnd.loadXML(fileName);

    if (!xml.hasAttribute("position")) throw new IOException();
    if (!xml.hasAttribute("slider")) throw new IOException();
    if (!xml.hasAttribute("rotation")) throw new IOException();
    trainPositionFile= xml.getString("position");
    trainSliderFile= xml.getString("slider");
    trainRotationFile= xml.getString("rotation");

    // Tokens
    XML firstChild = xml.getChild("Tokens");
    if (firstChild==null) throw new IOException();
    loadTokens (firstChild);

    // Calibraiton points
    XML secondChild = xml.getChild("CalibrationPoints");
    loadCalibrationPoints(secondChild);
  }


  void loadTokens (XML tokenxml) throws IOException
  {
    XML[] tokenDescriptions= tokenxml.getChildren("Token");
    if (tokenDescriptions==null) throw new IOException(); 

    // tokens
    for (int i = 0; i < tokenDescriptions.length; i++) {
      if (totalTokens++ > hnd.NUMBER_OF_TOKENS) return;

      String id= tokenDescriptions[i].getString("id");
      String type= tokenDescriptions[i].getString("type");
      int freq= tokenDescriptions[i].getInt("frequency");
      boolean active= tokenDescriptions[i].getString("status").equals("on");
      String filterFile= getFiltersFilePath (filters.get(""+freq));

      Token t= null;
      if (type.equals(PositionToken.class.getSimpleName())) {
        t= hnd.new PositionToken (id, freq, filterFile);
      }
      else if (type.equals(IdentificationToken.class.getSimpleName())) {
        t= hnd.new IdentificationToken (id, freq, filterFile);
      } 
      else if (type.equals(SliderToken.class.getSimpleName())) {
        t= hnd.new SliderToken (id, freq, filterFile);
      } 
      else if (type.equals(RotationToken.class.getSimpleName())) {
        t= hnd.new RotationToken (id, freq, filterFile);
      } 
      else {
        throw new IOException();
      }

      if (t==null) throw new IOException(); 
      t.setActive(active);
      tokens.put (id, t);
      listenMagnet(t);
    }
  }

  void loadCalibrationPoints (XML secondChild) throws IOException
  {
    if (secondChild==null) return;

    XML[] calibrationData= secondChild.getChildren("CalibrationPoint");
    for (int i = 0; i < calibrationData.length; i++) {
      int id= calibrationData[i].getInt("id");
      String type= calibrationData[i].getString("type");
      int x= calibrationData[i].getInt("x");
      int y= calibrationData[i].getInt("y");

      CalibrationPoint cp=null;
      if (type.equals("PositionCalibrationPoint"))
      {
        cp= hnd.new PositionCalibrationPoint (""+id);
      }
      else if (type.equals("SliderCalibrationPoint"))
      {
        cp= hnd.new SliderCalibrationPoint (""+id);
      }
      else if (type.equals("RotationCalibrationPoint"))
      {
        cp= hnd.new RotationCalibrationPoint (""+id);
      }

      if (cp==null) throw new IOException(); 
      cp.setXY(x, y);
      calibrationPoints.add (cp);
    }
  }


  void saveWorkspace ()
  {
    XML xml= new XML("Workspace"); 
    xml.setString("position", trainPositionFile); // do not change this line
    xml.setString("slider", trainSliderFile);  // do not change this line
    xml.setString("rotation", trainRotationFile); // do not change this line

    XML child= xml.addChild("Tokens");

    for (Token token : tokens.values()) {
      XML descriptor= token.getXmlDescriptor();
      child.addChild (descriptor);
    }
    // save calibration file if available
    xml.addChild (getCalibrationPointsDescriptor());
    // save file
    hnd.saveXML(xml, currentWorkspace);
  }

  XML getCalibrationPointsDescriptor()
  {
    XML result= new XML("CalibrationPoints");
    for (CalibrationPoint cp : calibrationPoints)
      result.addChild (cp.getXmlDescriptor());

    return result;
  }


  void newWorkSpace (String name)
  {
    currentWorkspace= getWorkspaceFilePath(name+".mt");
    trainPositionFile= name+"_position.arff"; 
    trainSliderFile= name+"_slider.arff"; 
    trainRotationFile= name+"_rotation.csv";

    setStatusMessage ("Workspace:  "+ currentWorkspace); // set status bar

    // Go to calibration
    resetCalibration();
    startCalibration();
  }

  private String getWorkspaceFilePath (String filename)
  {
    return hnd.dataPath(WORKSPACE_DIR+filename);
  }

  private String getFiltersFilePath (String filter)
  {
    return hnd.dataPath(FILTERS_DIR+filter);
  }

  String getFilterByFreq (int freq)
  {
    return getFiltersFilePath(filters.get(""+freq));
  }


  // Token management

  Token getTokenById(String id)
  {
    if (tokens.isEmpty()) return null;
    return tokens.get(id);
  }

  Token getFirstToken ()
  {
    if (tokens.isEmpty()) return null;
    return getTokenById ((String)(getTokenIdSet().toArray()[0]));
  }

  Token getToken (int number)
  {
    if (tokens.isEmpty()) return null;
    return getTokenById ((String)(getTokenIdSet().toArray()[number]));
  }

  Token getCalibrationToken ()
  {
    return getToken(CALIBRATION_TOKEN);
  }

  Set<String> getTokenIdSet ()
  {
    return new TreeSet<String>(tokens.keySet());
  }

  int getNumberOfTokens() { 
    return totalTokens;
  }

  // Calibration points
  ArrayList<CalibrationPoint> getCalibrationPoints () { 
    return calibrationPoints;
  }

  boolean hasCalibrationPoints() {return !calibrationPoints.isEmpty();}; 

  void resetCalibration(){ calibrationPoints= new ArrayList<CalibrationPoint>();}


  String getCalibrationID ()
  {
    // get the next available ID if there is not toke 
    if (calibrationPoints.isEmpty()) return "1";
    //else
    String lastID= calibrationPoints.get(calibrationPoints.size()-1).getID();
    return ""+(Integer.parseInt(lastID)+1);
  }


  // use java reflective methods
  void changeToken (String id, Class<?> tokenType) 
  { 
    Token toChange= getTokenById(id);

    if (toChange.getClass() == tokenType) return; // do not to convert to same type

    int freq= toChange.getFrequency();
    boolean state= toChange.isActive();
    stopListenMagnet (toChange);
    Token t=null;

    String filter= getFiltersFilePath (filters.get(""+freq));

    if (tokenType == PositionToken.class)
    {
      t= hnd.new PositionToken (id, freq, filter);
    }
    else if (tokenType == IdentificationToken.class)
    {
      t= hnd.new IdentificationToken (id, freq, filter);
    }
    else if (tokenType == SliderToken.class)
    {
      t= hnd.new SliderToken (id, freq, filter);
    }
    else if (tokenType == RotationToken.class)
    {
      t= hnd.new RotationToken (id, freq, filter);
    }
    t.setActive (state);
    tokens.put (id, t);
    listenMagnet (t);
  }


  String getPositionTrainingFile() { 
    return getWorkspaceFilePath(trainPositionFile);
  }

  String getSliderTrainingFile() { 
    return getWorkspaceFilePath(trainSliderFile);
  }

  String getRotationTrainingFile() { 
    return getWorkspaceFilePath(trainRotationFile);
  }


  // Magnet
  void listenMagnet (Observer obs)
  {
    if (magnet==null) return; 
    magnet.addObserver(obs);
  }

  void stopListenMagnet (Observer obs)
  {
    if (magnet==null) return;
    magnet.deleteObserver (obs);
  }

  void setMagnet (float x, float y, float z)
  {
    if (magnet==null) return;
    magnet.setValues(x, y, z);
  }



  // PRIVATE INNER CLASSES

  private static class SingletonHolder { 
    public static final AppManager INSTANCE = new AppManager();
  }



  // Private
  private MagID3 hnd;
  private MagData magnet;

  private MagneticSignalWidget raw;
  private ConsoleWidget console;
  private FrequencyWidget fft;
  private CalibrationWidget calibrationWindow;


  OscP5 oscP5;


  private boolean networkActive;
  private String statusMessage;

  // Tokens
  private HashMap<String, Token> tokens; // token id, token
  private HashMap<String, String> filters; // token id, filter
  private int totalTokens;

  // Calibration points
  private ArrayList<CalibrationPoint> calibrationPoints; 

  // Workspace
  private String trainPositionFile, trainSliderFile, trainRotationFile;
  private String currentWorkspace;
}


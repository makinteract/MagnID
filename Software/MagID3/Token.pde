/***************************************************
Token superclass
****************************************************/

abstract class Token implements Observer
{
  Token (String ID, int frequency)
  {
    id= ID;
    targetFrequency= frequency;
    active=true;
    signalStrength=0;
  }

  String getID() { 
    return id;
  }

  int getFrequency() { 
    return targetFrequency;
  }

  float getSignalStrength()
  {
    return signalStrength;
  }

  XML getXmlDescriptor()
  {
    XML token= new XML ("Token");
    token.setString("type", getType());
    token.setString("id", id);
    token.setInt("frequency", targetFrequency);
    String status= isActive()? "on":"off";
    token.setString("status", status);
    return token;
  }

  String getType()
  {
    return this.getClass().getSimpleName();
  }

  public void update(Observable obs, Object arg)
  {
    rawData= (MagData) obs;
    if (rawData==null) return;
    onMagnetChange (rawData.x(), rawData.y(), rawData.z());
  }

  boolean isActive() {
    return active;
  }

  void toggle() {
    active^= true;
  }

  void setActive(boolean b) {
    active= b;
  }


  // the abstract method
  abstract void onMagnetChange (float x, float y, float z);
  abstract void doAction ();
  abstract void reload();

  protected String id;
  protected int targetFrequency;
  protected MagData rawData;
  protected boolean active;
  protected float signalStrength;
}



/***************************************************
Fixed frequency Token (CalibrationToken, PositionToken,
IdentificationToken, SliderToken)
****************************************************/


abstract class FixFrequencyToken extends Token
{
  FixFrequencyToken (String ID, int frequency, double [] filterCoefficinets)
  {
    super(ID, frequency);

    firFilterX= new FirFilter(filterCoefficinets);   
    firFilterY= new FirFilter(filterCoefficinets);   
    firFilterZ= new FirFilter(filterCoefficinets);  

    init();
  }

  FixFrequencyToken (String ID, int frequency, String filterCoefficinets)
  {
    super(ID, frequency);

    firFilterX= new FirFilter(filterCoefficinets);   
    firFilterY= new FirFilter(filterCoefficinets);   
    firFilterZ= new FirFilter(filterCoefficinets);  

    init();
  }

  private void init()
  {
    // The period (double of period will work but slow)
    int filterSize= 2000/targetFrequency; 
    init (filterSize);
  }

  protected void init(int n)
  {
    //Half of the period (double of period will work but slow)
    int filterSize= n; 
    
    windowX= new DspFilter (filterSize); 
    windowY= new DspFilter (filterSize);
    windowZ= new DspFilter (filterSize);
    filteredSignal= new MagData();
  }



  void onMagnetChange (float x, float y, float z)
  {
    if (!active)
    {
      signalStrength=0;
      return;
    }

    float filteredX= abs((float)firFilterX.filter(x));
    float filteredY= abs((float)firFilterY.filter(y));
    float filteredZ= abs((float)firFilterZ.filter(z));

    windowX.add (filteredX);
    windowY.add (filteredY);
    windowZ.add (filteredZ);

    mx=windowX.getMean();
    my=windowY.getMean();
    mz=windowZ.getMean();

    // update strength of signal
    signalStrength= mx+my+mz;

    filteredSignal.setValues(windowX.getMean(), windowY.getMean(), windowZ.getMean());  
    doAction();
  }

  void listenFilteredSignal (Observer obs)
  {
    filteredSignal.addObserver(obs);
  }


  protected FirFilter firFilterX, firFilterY, firFilterZ;
  protected MagData filteredSignal;
  protected DspFilter windowX, windowY, windowZ;  
  protected float mx, my, mz;
}



/***************************************************
CalibrationToken
****************************************************/

class CalibrationToken extends FixFrequencyToken
{
  CalibrationToken (String ID, int frequency, double [] filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets);
  }

  CalibrationToken (String ID, int frequency, String filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets);
  }

  void doAction() {
  }

  void reload(){}

  float getX() {
    return mx;
  }

  float getY() {
    return my;
  }

  float getZ() {
    return mz;
  }

  PVector getData() { 
    return new PVector (mx, my, mz);
  }
}


/***************************************************
PositionToken
****************************************************/


class PositionToken extends FixFrequencyToken
{
  PositionToken (String ID, int frequency, double [] filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets); 
    classifier= new SMOWeka(AppManager.Instance().getPositionTrainingFile());
  }

  PositionToken (String ID, int frequency, String filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets); 
    classifier= new SMOWeka(AppManager.Instance().getPositionTrainingFile());
  }

  void reload(){classifier.initialize ();}

  void doAction ()
  {    
    if (classifier==null) return;

    float result=0;
    if (mx+my+mz < LOW_STRENGHT_SIGNAL)
    {
      // keep result to 0
      result=0;
    }else{

      // postions start from 1, not 0
      result= 1+classifier.classify (mx, my, mz);
      if (result<=0) return;
    }

    if (millis()-prevTime > REFRESH_MS  )
    {
      prevTime= millis();
      AppManager.Instance().sendOscMessage (id, 'p', result, new float[]{mx,my,mz});
    }
  } 


  private Weka classifier;
  long prevTime;
}


/***************************************************
IdentificationToken
****************************************************/

class IdentificationToken extends FixFrequencyToken
{
  IdentificationToken (String ID, int frequency, double [] filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets);
  }


  IdentificationToken (String ID, int frequency, String filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets);
  }

  void reload(){}

  void doAction ()
  {    
    float result= mx+my+mz;
    if (result < LOW_STRENGHT_SIGNAL) result=0;

    if (millis()-prevTime > REFRESH_MS)
    {
      prevTime= millis();
      AppManager.Instance().sendOscMessage (id, 'i', result, new float[]{mx,my,mz});
    }
  }

  long prevTime=0;
}



/***************************************************
SliderToken
****************************************************/

class SliderToken extends FixFrequencyToken
{
  SliderToken (String ID, int frequency, double [] filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets); 
    classifier= new LinearRegressionWeka (AppManager.Instance().getSliderTrainingFile());
    fil= new DspFilter (10);
  }


  SliderToken (String ID, int frequency, String filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets); 
    classifier= new LinearRegressionWeka (AppManager.Instance().getSliderTrainingFile());
    fil= new DspFilter (10);
  }


  void reload(){classifier.initialize ();}



  void doAction ()
  {    
    if (classifier==null) return;
    if (mx+my+mz < LOW_STRENGHT_SIGNAL) return; // too weak, dont use

    float result= classifier.classify (mx, my, mz);
    
    if (result<0)return;
    fil.add(result);
    result= fil.getMean();

    if (millis()-prevTime > REFRESH_MS  )
    {
      prevTime= millis();
      AppManager.Instance().sendOscMessage (id, 's', result, new float[]{mx,my,mz});
    }
  }



  private Weka classifier;
  DspFilter fil;
  long prevTime;
}


/***************************************************
RotationToken
****************************************************/

class RotationToken extends FixFrequencyToken
{
  RotationToken (String ID, int frequency, double [] filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets); 
    loadTrainingFile();
    fil= new DspFilter(20);
    super.init(10);
  }

  RotationToken (String ID, int frequency, String filterCoefficinets)
  {
    super (ID, frequency, filterCoefficinets); 
    loadTrainingFile();
    fil= new DspFilter(20);
    super.init(10);
  }

 
  void reload(){loadTrainingFile();};
  

  void loadTrainingFile()
  {
    centerX=0;
    centerY=0;
    centerZ=0;

    String[] lines = loadStrings(AppManager.Instance().getRotationTrainingFile()); 
    for(int i = 0; i < lines.length; i++){ 
      String[] parts = splitTokens(lines[i], ","); 
      if (parts.length==4)
      {
        centerX+= Float.parseFloat(parts[1]);
        centerY+= Float.parseFloat(parts[2]);
        centerZ+= Float.parseFloat(parts[3]);
      }
    } 
    centerX/= lines.length;
    centerY/= lines.length;
    centerZ/= lines.length;
  }



  void doAction () 
  {

    float x= mx- centerX;
    float y= my- centerY;
    float z= mz- centerZ;

    // if (abs(x) < ROTATION_THRESHOLD) return;
    // if (abs(y) < ROTATION_THRESHOLD) return;
    // if (abs(z) < ROTATION_THRESHOLD) return;

    float angle= abs(degrees(atan2(x, y)));
    fil.add(angle);
    float curr= fil.getMean();  
    float delta= curr-prev;
    prev= curr; 
    cumulative+= delta;

    if (millis()-prevTime > REFRESH_MS/10)
    {
      prevTime= millis();
      /*if (abs(cumulative)<2) 
      {
        cumulative=0;
        return;
      }*/
      AppManager.Instance().sendOscMessage (id, 'r', cumulative, new float[]{mx,my,mz});
      cumulative=0;
    }
  }

  // PRIVATE
  private float centerX, centerY, centerZ;
  float prevTime, prev, cumulative;
  private DspFilter fil;

  private float angle, dx, prevx;
  public int ROTATION_THRESHOLD= 5;
}


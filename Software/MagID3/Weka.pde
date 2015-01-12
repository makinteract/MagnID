/***************************************************

Weka class for machine learning

****************************************************/

abstract class Weka
{

  Weka (String trainingFile)
  {
    this.trainingFile= trainingFile;
    testFileSize= 1; // defaul
    initialize ();
  }


  Weka (String trainingFile, int sizeOfTestFile)
  {
    this.trainingFile= trainingFile;
    testFileSize= sizeOfTestFile;
    initialize ();
  }


  synchronized void initialize ()
  {
    train=null; test=null;
    // load training file
    loadTrainingData (trainingFile);
    // call the abstract method
    initClassifier ();
  }


  protected void addForClassification (float x, float y, float z)
  {
    if (test==null) return;
    double[] vals = new double[test.numAttributes()];
    vals[0] = 0;
    vals[1] = x;
    vals[2] = y;
    vals[3] = z;

    test.add (new Instance(1.0, vals));
  }

  synchronized protected float classify (float x, float y, float z)
  {
    if (cls==null) return -1;
    if (test==null) createTestFile();
    
    if (test.numInstances() < testFileSize)
    {
      addForClassification(x,y,z);
      return -1;
    }

    // else we are ready
    try {
      // create a model using the training data
      eval = new Evaluation(train);
      // classify
      eval.evaluateModel(cls, test);
      //System.out.println(eval.toSummaryString("\nResults\n======\n", false));
    }
    catch(Exception ex) {
      ex.printStackTrace();
      println(ex.getMessage());
    }

    float res= getClassificationResult();
    test=null;
    return res;
  }


  private void createTestFile()
  {
    FastVector atts = new FastVector();
    FastVector attVals = new FastVector();

    for (int i=0; i< 3; i++)
    {
      attVals.addElement("v"+i);
    }

    atts.addElement(new Attribute("class", attVals));
    atts.addElement(new Attribute("X"));
    atts.addElement(new Attribute("Y"));
    atts.addElement(new Attribute("Z"));

    test = new Instances("amps", atts, 0);
    test.setClassIndex(0);
  }


  private void loadTrainingData (String trainingFile)
  {
    try
    {
      if (trainingFile.toLowerCase().endsWith(".csv"))
      {
        loadCSV (trainingFile);
      }
      else if (trainingFile.toLowerCase().endsWith(".arff"))
      {
        loadARFF (trainingFile);
      }
    }
    catch(Exception e) {
      println(e.getMessage());
    }
  }


  private void loadCSV (String trainingFile) throws IOException
  {
    CSVLoader loader = new CSVLoader();
    loader.setSource(new File(trainingFile));
    train = loader.getDataSet();
    train.setClassIndex(0);
  }

  private void loadARFF (String trainingFile)  throws IOException
  {
    FileReader reader = new FileReader(trainingFile); 
    train = new Instances(reader); 
    train.setClassIndex(0);      
  }


  // abstract methods
  abstract void initClassifier();
  abstract float getClassificationResult();

  int testFileSize;
  Instances train, test;
  Classifier cls=null;
  Evaluation eval=null;
  String trainingFile;
}





class SMOWeka extends Weka
 {
 
 SMOWeka(String trainingFile)
 {
  super(trainingFile);
 }
 
 void initClassifier()
 {
  try {
    cls= new SMO();
    cls.buildClassifier(train);
  }
    catch (Exception e)
  {
    println(e.getMessage());
  }
 }
 
 
  float getClassificationResult () 
  {
   if (cls==null || eval==null) return -1; // classifier not initialised
   
   FastVector predictions= eval.predictions();
   NominalPrediction np = (NominalPrediction) predictions.elementAt(0);
   int predicted= (int)np.predicted();
   int actual= (int)np.actual();
   return predicted;
  }

}
 




class LinearRegressionWeka extends Weka
{
  LinearRegressionWeka(String trainingFile)
  {
    super(trainingFile);
  }

  void initClassifier ()
  {
    try {
      cls= new LinearRegression();
      cls.buildClassifier(train);
    }
    catch (Exception e)
    {
      println(e.getMessage());
    }
  }

  float getClassificationResult () 
  {
   if (cls==null || eval==null) return -1; // classifier not initialised
   
   float result=-1;
    try {
      result= (float)cls.classifyInstance(test.firstInstance());
    }
    catch (Exception e) {
      println(e.getMessage());
    }

    return result;
  }
}

/***************************************************
FIR Filter class
****************************************************/


public class FirFilter {

  public FirFilter(double coefficients[]) 
  {
    this.h = coefficients;
    this.N = coefficients.length;            
    this.x = new double[N];
  }


  public FirFilter(String fileName) 
  {
    this.h = loadCoefficients(fileName);
    this.N = h.length;            
    this.x = new double[N];
  }



  public double filter(double newSample) {       
    y = 0;           
    x[iWrite] = newSample;      
    iRead = iWrite;
    for (n=0; n<N; n++) {
      y += h[n] * x[iRead];
      iRead++;
      if (iRead == x.length) {
        iRead = 0;
      }
    }
    iWrite--;
    if (iWrite < 0) {
      iWrite = x.length-1;
    }      
    return y;
  }


  private double[] loadCoefficients(String fileName)
  {
    String lines[] = loadStrings(fileName);
    ArrayList<Double> list= new ArrayList<Double>();

    for (int i = 0 ; i < lines.length; i++) {
      try {
        list.add (new Double (lines[i]));
      }
      catch (Exception e) {
      }
    }

    double[] result= new double[list.size()];
    for (int i=0; i<list.size(); i++)
    {
      result[i]= list.get(i).doubleValue();
    }
    return result;
  }


  private int N;
  private double h[];
  private double y;
  private double x[];
  private int n;
  private int iWrite = 0;
  private int iRead = 0;
}



/***************************************************
DSP Filter class repository
****************************************************/


public class DspFilter
{ 
  DspFilter(float[] data) 
  {
    this.data = data;
    size = data.length;
    index=0;
  }   

  DspFilter(int size) 
  {
    this.data = new float[size];
    this.size = size;
    index=0;
  }   

  boolean isFull()
  {
    return index==size-1;
  }

  void reset()
  {
    this.data = new float[size];
    index=0;
  }

  void add (float val)
  {
    data[index++]= val;
    if (index==data.length)
    {
      index=0;
    }

    // running mean
    ra= (val+index*ra)/(index+1);
  }

  float getRunningMean ()
  {
    return ra;
  }

  float getMean()
  {
    float sum = 0.0;
    for (float a : data)
      sum += a;
    return sum/size;
  }

  float getVariance()
  {
    float mean = getMean();
    float temp = 0;
    for (float a :data)
      temp += (mean-a)*(mean-a);
    return temp/(size-1);
  }

  float getMin()  
  {
    float res= (float)data[0];
    for (float a :data)
      res= min(res, (float)a);
    return res;
  }

  float getMax()  
  {
    float res= (float)data[0];
    for (float a :data)
      res= max(res, (float)a);
    return res;
  }


  float diff()
  {
    return getMax()-getMin();
  }

  float getStdDev()
  {
    return (float)Math.sqrt(getVariance());
  }

  public float getMedian() 
  {
    float[] b = new float[data.length];
    System.arraycopy(data, 0, b, 0, b.length);
    Arrays.sort(b);

    if (data.length % 2 == 0) 
    {
      return (b[(b.length / 2) - 1] + b[b.length / 2]) / 2.0;
    } 
    else 
    {
      return b[b.length / 2];
    }
  }

  private float[] data;
  private int size, index;
  private float ra;
} 


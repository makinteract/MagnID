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


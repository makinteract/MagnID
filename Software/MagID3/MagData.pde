/***************************************************
MagData: class to hold magnetic values
****************************************************/

class MagData extends Observable
{
  public MagData()
  {
    v=new float[3];
  }

  public void setValues (float[] vector)
  {
    if (vector.length!= 3) return;
    v= vector;
    setChanged();
    notifyObservers();
  }

  public void setValues (float x, float y, float z)
  {
    v[0]=x;
    v[1]=y;
    v[2]=z;
    setChanged();
    notifyObservers();
  }

  public float [] getValues() {
    return v;
  }

  public float x() { 
    return v[0];
  }
  public float y() { 
    return v[1];
  }
  public float z() { 
    return v[2];
  }

  private float [] v;
}


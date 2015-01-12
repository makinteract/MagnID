String MULTICAST_ADDRESS= "239.0.0.1";
int OSC_PORT= 5204;



void setup() {
  size(800,600);
  initNetwork();
  
}


void draw() {
  background(0);
}


void onTokenDetection (String tokenID, char tokenType, float value)
{
  println (tokenID +"  "+tokenType+"  "+value);
  
}


void onTokenDetection (String tokenID, char tokenType, float value, float x, float y, float z)
{
  // just ignore the x y z in this case
  onTokenDetection (tokenID, tokenType, value);
}





// NETWORK

import oscP5.*;
import netP5.*;

OscP5 oscP5;

void initNetwork()
{
  oscP5 = new OscP5(this,MULTICAST_ADDRESS, 5204);
}



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/MagID/token")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("scffff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      String id = theOscMessage.get(0).stringValue();  
      char type = theOscMessage.get(1).charValue();  
      float val = theOscMessage.get(2).floatValue();
      float x = theOscMessage.get(3).floatValue();
      float y = theOscMessage.get(4).floatValue();
      float z = theOscMessage.get(5).floatValue();
      
      onTokenDetection (id, type, val, x, y, z);
    }  
  } 
}

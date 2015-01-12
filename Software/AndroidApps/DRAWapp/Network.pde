import oscP5.*;
import netP5.*;

OscP5 oscP5;
String MULTICAST_ADDRESS= "239.0.0.1";
int OSC_PORT= 5204;


void connect()
{
  oscP5 = new OscP5(this, MULTICAST_ADDRESS, OSC_PORT);
}

void sendOscMessage (OscMessage message)
{
  if (oscP5==null) return;
  oscP5.send(message);
}

void sendOscMessage (String id, char type, float value, float [] xyz)
{
  if (oscP5==null) return ; 

  OscMessage message = new OscMessage("/MagID/token");
  message.add(id); 
  message.add(type); 
  message.add(value); 
  message.add(xyz); 
  sendOscMessage (message);
}


void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/MagID/token")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("scffff")) {
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


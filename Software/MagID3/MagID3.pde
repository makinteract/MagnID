// Processing 
import processing.serial.*;

// Java
import java.io.*;

// Jave GUI
import javax.swing.*; 
import java.util.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.*;
import java.awt.event.*;

// Observer
import java.util.Observer;
import java.util.Observable;
import java.util.*;

// Weka
import weka.core.converters.*;
import weka.core.*;
import weka.classifiers.*;
import weka.classifiers.bayes.NaiveBayes;
import weka.classifiers.evaluation.*;
import weka.classifiers.lazy.KStar;
import weka.classifiers.functions.LinearRegression;
import weka.classifiers.functions.SMO;
import weka.classifiers.functions.Logistic;

//OSC
import oscP5.*;
import netP5.*;


// GLOBALS
Serial serialPort;
MainGUI gui;


void setup()
{
  size(WIDTH, HEIGHT);

  // register for when the app is closed
  registerDispose(this);
  frame.addWindowListener(new WindowAdapter() {
    public void windowClosing(WindowEvent e) {
      dispose();
    }
  }
  );

  // Init interface
  AppManager.Instance().init (this);
  gui= new MainGUI(this);
  setupSerial();
}


void draw()
{
  gui.draw();
}


void stop()
{
  dispose();
}


public void dispose()
{
  if (serialPort!=null) stopSerial();
  AppManager.Instance().saveWorkspace();
}






// SERIAL

void setupSerial()
{
  serialPort = new Serial(this, Serial.list()[SERIAL_PORT], BAUD_RATE);
  serialPort.bufferUntil('\n');
}

void stopSerial()
{
  serialPort.stop();
  serialPort= null;
}

void serialEvent(Serial serialPort) {   
  if (serialPort==null) return;

  String s= "";
  while (serialPort.available ()>0)
  {
    s+= (char)(serialPort.read());
  } 
  s= s.trim();
  if (s.equals("")) return;

  String []xyz=splitTokens(s, ",");
  if (xyz.length!=3) return;

  float x= parseFloat (xyz[0]);
  float y= parseFloat (xyz[1]);
  float z= parseFloat (xyz[2]);

  AppManager.Instance().setMagnet(x, y, z);
}


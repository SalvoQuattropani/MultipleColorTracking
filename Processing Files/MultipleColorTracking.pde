import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import processing.serial.*;
Serial arduino;
Capture video;
OpenCV opencv;
PImage src;
ArrayList<Contour> contours;

// <1> Set the range of Hue values for our filter
//ArrayList<Integer> colors;
int maxColors = 4;
int[] hues;
int[] colors;
int rangeWidth = 10;
int midFaceY=0;
int midFaceX=0;
int stepSize=1;
PImage[] outputs;
int servoPanPosition = 90;
int colorToChange = -1;
color colore=color(255,128,0);
int servoTiltPosition = 90;
void setup() {
   

  
  
  video = new Capture(this, 640, 480,"USB2.0 PC CAMERA");
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();
  size(640,480);
  //size(opencv.width + opencv.width/4 + 30, opencv.height, P2D);
  
  // Array for detection colors
  colors = new int[maxColors];
  hues = new int[maxColors];
  
  outputs = new PImage[maxColors];
  
  video.start();
    
  String portName = Serial.list()[0];
 arduino = new Serial(this, portName, 57600 );
    arduino.write(servoTiltPosition); 
  
}

void draw() {
  
  background(150);
  
  if (video.available()) {
    video.read();
  }


  opencv.loadImage(video);
  

  opencv.useColor();
  src = opencv.getSnapshot();
  

  opencv.useColor(HSB);
  
  detectColors();
  

  
   // hues[0] = 15; //colore arancia
  image(src, 0, 0);
  for (int i=0; i<outputs.length; i++) {
    if (outputs[i] != null) {
      image(outputs[i], width-src.width/4, i*src.height/4, src.width/4, src.height/4);
      
      noStroke();
      fill(colors[i]);
      rect(src.width, i*src.height/4, 30, src.height/4);
    }
  }
  
  // Print text if new color expected
  textSize(20);
  stroke(255);
  fill(255);
  
  if (colorToChange > -1) {
    text("click to change color " + colorToChange, 10, 25);
  } else {
    text("press key [1-4] to select color", 10, 25);
  }
  
  displayContoursBoundingBoxes();
}

void detectColors() {

      int hue = int(map(hue(colore), 0, 255, 0, 180));
    
    //colors[colorToChange-1] = c;
    hues[0] = hue;
    
  
  for (int i=0; i<hues.length; i++) {
    
    if (hues[i] <= 0) continue;
    
    opencv.loadImage(src);
    opencv.useColor(HSB);
    
    
    opencv.setGray(opencv.getH().clone());
    
    int hueToDetect = hues[i];

    opencv.inRange(hueToDetect-rangeWidth/2, hueToDetect+rangeWidth/2);
    

    opencv.erode();
    

    outputs[i] = opencv.getSnapshot();
  }
  

  if (outputs[0] != null) {
    
    opencv.loadImage(outputs[0]);
    contours = opencv.findContours(true,true);
  }
}

void displayContoursBoundingBoxes() {
  
  for (int i=0; i<contours.size(); i++) {
    
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    
    
    
    
    if (r.width < 30 || r.height < 30)
      continue;
    
    stroke(255, 0, 0);
    fill(255, 0, 0, 150);
    strokeWeight(2);
   rect(r.x, r.y, r.width, r.height);
   println("posizione: " +r.x +" ,"+ r.y);
  
  
  
  
  if(contours.size() > 0){
   
    //midFaceY =r.y + (r.height/2);
  //  midFaceX =r.x + (r.width/2);
   midFaceX =r.x ;
   midFaceY =r.y;
      if(midFaceX < 100){
      if(servoTiltPosition >= 5)servoTiltPosition += stepSize;    }
    
    else if(midFaceX >100){
    println("pos"+midFaceX);
      if(servoTiltPosition <= 175)servoTiltPosition -=stepSize;    }
 
    if(midFaceY < 100){
      if(servoPanPosition >= 5)servoPanPosition += stepSize; 
    }
  
    else if(midFaceY > 100){
      if(servoPanPosition <= 175) servoPanPosition -=stepSize; 
    }
    
  }
 
 
 // port.write(tiltChannel);      //Send the tilt servo ID
  arduino.write(servoTiltPosition); //Send the updated tilt position.
   println("invio"+servoTiltPosition);
   // println( "INVIO: " + servoTiltPosition+ "e "+ tiltChannel);
 // port.write(panChannel);       
//  port.write(servoPanPosition); 
  delay(1);
    
}
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  }
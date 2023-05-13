import processing.serial.*;
import controlP5.*;

Serial myPort;
ControlP5 button;

int stime, sequence = 0, motionID = 0;

int torque = 1;
int speed  = 20; // 
char str;

KingSpider king_spider;

void setup() {
  king_spider = new KingSpider();
  
  size(825, 650); //window size
  frameRate(100); //frame rate 100Hz
  smooth(); //anti-aliasing
  /***
  //-------- List of Serial devices -----------
  println(Serial.list()); //
  String comPort = Serial.list()[0];
  //-------------------------------------------
  myPort=new Serial(this, comPort, 115200); 
  myPort.clear(); //clear buffer
  
  println("serial open");
  while (myPort.available()>0) {
    str=(char)myPort.read();
    println(str);
  }
  ***/

  //------------ Interface Design --------------  
  //Font setting
  PFont myFont = createFont("Arial", 16, true);
  ControlFont cf1 = new ControlFont(myFont, 14);
  button = new ControlP5(this);

  //Button Design
  button.addButton("initial")
    .setLabel("Initial Posture")
    .setFont(cf1)
    .setPosition(300, 50)
    .setSize(200, 100)
    .setColorActive(color(192, 192, 192))
    .setColorBackground(color(128, 128, 128))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
    
  button.addButton("ending")
    .setLabel("Ending Posture")
    .setFont(cf1)
    .setPosition(550, 50)
    .setSize(200, 100)
    .setColorActive(color(192, 192, 192))
    .setColorBackground(color(128, 128, 128))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
  
  button.addButton("posture1")
    .setLabel("Posture 1")
    .setFont(cf1)
    .setPosition(50, 200)
    .setSize(100, 50)
    .setColorActive(color(192, 64, 64))
    .setColorBackground(color(128, 64, 64))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
  
  button.addButton("posture2")
    .setLabel("Posture 2")
    .setFont(cf1)
    .setPosition(175, 200)
    .setSize(100, 50)
    .setColorActive(color(64, 192, 64))
    .setColorBackground(color(64, 128, 64))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
  
  button.addButton("posture3")
    .setLabel("Posture 3")
    .setFont(cf1)
    .setPosition(300, 200)
    .setSize(100, 50)
    .setColorActive(color(64, 64, 192))
    .setColorBackground(color(64, 64, 128))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
  
  button.addButton("posture4")
    .setLabel("Posture 4")
    .setFont(cf1)
    .setPosition(425, 200)
    .setSize(100, 50)
    .setColorActive(color(192, 192, 64))
    .setColorBackground(color(128, 128, 64))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
  
  button.addButton("posture5")
    .setLabel("Posture 5")
    .setFont(cf1)
    .setPosition(550, 200)
    .setSize(100, 50)
    .setColorActive(color(192, 64, 192))
    .setColorBackground(color(128, 64, 128))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
  
  button.addButton("posture6")
    .setLabel("Posture 6")
    .setFont(cf1)
    .setPosition(675, 200)
    .setSize(100, 50)
    .setColorActive(color(64, 192, 192))
    .setColorBackground(color(64, 128, 128))
    .setColorForeground(color(64, 64, 64))
    .setColorCaptionLabel(color(0, 0, 0));
    
  button.addButton("forward")
    .setLabel("Forward")
    .setFont(cf1)
    .setPosition(312, 300)
    .setSize(200, 75)
    .setColorActive(color(255, 220, 220))
    .setColorBackground(color(220))
    .setColorForeground(color(255, 220, 220))
    .setColorCaptionLabel(color(0, 0, 0));
    
  button.addButton("stop")
    .setLabel("Stop")
    .setFont(cf1)
    .setPosition(312, 400)
    .setSize(200, 75)
    .setColorActive(color(255, 220, 220))
    .setColorBackground(color(220))
    .setColorForeground(color(255, 220, 220))
    .setColorCaptionLabel(color(0, 0, 0));

  button.addButton("back")
    .setLabel("Back")
    .setFont(cf1)
    .setPosition(312, 500)
    .setSize(200, 75)
    .setColorActive(color(255, 220, 220))
    .setColorBackground(color(220))
    .setColorForeground(color(255, 220, 220))
    .setColorCaptionLabel(color(0, 0, 0));
    
  button.addButton("left")
    .setLabel("Left")
    .setFont(cf1)
    .setPosition(87, 400)
    .setSize(200, 75)
    .setColorActive(color(255, 220, 220))
    .setColorBackground(color(220))
    .setColorForeground(color(255, 220, 220))
    .setColorCaptionLabel(color(0, 0, 0));

  button.addButton("right")
    .setLabel("Right")
    .setFont(cf1)
    .setPosition(537, 400)
    .setSize(200, 75)
    .setColorActive(color(255, 220, 220))
    .setColorBackground(color(220))
    .setColorForeground(color(255, 220, 220))
    .setColorCaptionLabel(color(0, 0, 0));
    
  button.addButton("getdata")
    .setLabel("Get Pose Data")
    .setFont(cf1)
    .setPosition(50, 550)
    .setSize(200, 50)
    .setColorActive(color(100))
    .setColorBackground(color(50))
    .setColorForeground(color(100))
    .setColorCaptionLabel(color(255, 255, 255));
    
    speed_setting();
}

//-------------- mouse click events ----------------
void mousePressed() {
  if(mouseX > 50 && mouseX < 250 && mouseY > 40 && mouseY < 80){
    if(torque == 1) torque = 0;
    else torque = 1;
    torque_setting();
  }
  else if(mouseX > 50 && mouseX < 250 && mouseY > 100 && mouseY < 140){
    speed = speed + 20;
    if(speed > 200) speed = 20;
    speed_setting();
  }
}

//-------------- main Loop ----------------
void draw() {
  background(255);

  fill(0);
  textSize(32);
  textAlign(LEFT);
  text("Torque:", 50, 75);
  textAlign(LEFT);
  if (torque>0) {
    text("ON", 190, 75);
  } else {
    text("OFF", 190, 75);
  }

  textAlign(LEFT);
  text("Speed:", 50, 125);
  textAlign(RIGHT);
  text(speed, 250, 125);
  
  if(motionID == 1) forward_motion_control();
  else if(motionID == 2) back_motion_control();
  else if(motionID == 3) left_motion_control();
  else if(motionID == 4) right_motion_control();
  /***
  while (myPort.available()>0) {
    str=(char)myPort.read();
    print(str);
  }
  ***/
  delay(1);
}

//----------------  sending commands to servo -------------------
void torque_setting() {
  //myPort.clear(); //clear buffer
  if (torque == 1) {
    //myPort.write("[n]\n");
  } else {
    //myPort.write("[f]\n");
  }
  delay(100);
}

void speed_setting() {
  String msg = "[v," + speed + "]\n";
  //myPort.clear(); //clear buffer
  //myPort.write(msg);
  king_spider.writeCommand(msg);
  //delay(100);
}

void motor_control(int motorID[], int angle[]){
  if (torque == 1) {
    String msg = "[m";
    for(int i = 0; i < motorID.length; i++){
      msg += "," + motorID[i] + "," + angle[i];
    }
    msg += "]\n";
    //myPort.clear(); //clear buffer
    //myPort.write(msg);
    king_spider.writeCommand(msg);
    //delay(100);
  }
}

void motion_control(int motorID[], int intervalTime[], int angle[][]){
  int dtime = millis() - stime, t = 0, pid;
  float val, alfa = 1.4;
  for (int i = 0; i < sequence; i++) t += intervalTime[i];
  if(t < dtime) {
      if(sequence < intervalTime.length) {
        String msg = "[v";
        for(int i = 0; i < motorID.length; i++){
          if(sequence > 0) pid = sequence - 1;
          else pid = intervalTime.length - 1;
          val = alfa * (abs((float)(angle[sequence][i] - angle[pid][i])) * 5.0 * 60.0 * 1000.0) /  
          ((float)intervalTime[sequence] * 1024.0 * 3.0 * 0.111 * 2.0);
          msg += "," + motorID[i] + "," + (int)val;
        }
        msg += "]\n";
        //myPort.write(msg);
        king_spider.writeCommand(msg);
        motor_control(motorID, angle[sequence]);
      }
      sequence++;
  }
}

//----- the motorIDs, angular values, interval times are required to defined by the user ------ 
void forward_motion_control(){
  int[] motorID = {13, 15, 17};   
  int[] intervalTime = {500, 500, 500}; // Interval Time [ms] for each posture
  int[][] angle = {{600, 400, 600}, // posture1
                   {400, 600, 400}, // posture2
                   {512, 512, 512}}; // posture3
  
  motion_control(motorID, intervalTime, angle);
  if (sequence > intervalTime.length){
    sequence = 0;
    stime = millis();
  }
}

void back_motion_control(){
  int[] motorID = {13, 15, 17};   
  int[] intervalTime = {1000, 2000, 3000}; // Interval Time [ms] for each posture
  int[][] angle = {{400, 600, 400}, // posture1
                   {600, 400, 600}, // posture2
                   {512, 512, 512}}; // posture3
 
  motion_control(motorID, intervalTime, angle);
  if (sequence > intervalTime.length){
    sequence = 0;
    stime = millis();
  }
}

void left_motion_control(){
  int[] motorID = {13, 15, 17};   
  int[] intervalTime = {2000, 2000, 2000}; // Interval Time [ms] for each posture
  int[][] angle = {{600, 600, 600}, // posture1
                   {400, 400, 400}, // posture2
                   {512, 512, 512}}; // posture3
 
  motion_control(motorID, intervalTime, angle);
  if (sequence > intervalTime.length){
    sequence = 0;
    stime = millis();
  }
}

void right_motion_control(){
  int[] motorID = {13, 15, 17};   
  int[] intervalTime = {2000, 2000, 2000}; // Interval Time [ms] for each posture
  int[][] angle = {{400, 400, 400}, // posture1
                   {600, 600, 600}, // posture2
                   {512, 512, 512}}; // posture3
 
  motion_control(motorID, intervalTime, angle);
  if (sequence > intervalTime.length){
    sequence = 0;
    stime = millis();
  }
}

//---------------- Button Control ------------------
void initial() {
  motionID = 0;
  if (torque == 1){
    speed_setting();
    //myPort.write("[i]\n");
    king_spider.writeCommand("[i]\n");
  }
}

void ending() {
  motionID = 0;
  if (torque == 1)
    speed_setting();
    //myPort.write("[e]\n");
    king_spider.writeCommand("[e]\n");
}

//----------- Posture Buttons -----------
//the motorIDs and angular values are required to defined by the user according to robot's body structure.
void posture1() {
  int[] motorID = {13, 15, 17}; 
  int[] angle = {600, 400, 600};
  
  motionID = 0;
  speed_setting();
  motor_control(motorID, angle);
}

void posture2() {
  int[] motorID = {13, 15, 17};
  int[] angle = {400, 600, 400};
  
  motionID = 0;
  speed_setting();
  motor_control(motorID, angle);
}

void posture3() {
  int[] motorID = {13, 15, 17};
  int[] angle = {600, 600, 600};
  
  motionID = 0;
  speed_setting();
  motor_control(motorID, angle);
}

void posture4() {
  int[] motorID = {13, 15, 17};
  int[] angle = {400, 400, 400};
  
  motionID = 0;
  speed_setting();
  motor_control(motorID, angle);
}

void posture5() {
  int[] motorID = {13, 15, 17};
  int[] angle = {512, 600, 400};
  
  motionID = 0;
  speed_setting();
  motor_control(motorID, angle);
}

void posture6() {
  int[] motorID = {13, 15, 17};
  int[] angle = {512, 400, 600};
  
  motionID = 0;
  speed_setting();
  motor_control(motorID, angle);
}

//----------- Motion Buttons -----------
void forward() {
  motionID = 1;
  stime = millis();
}

void back() {
  motionID = 2;
  stime = millis();
}

void left() {
  motionID = 3;
  stime = millis();
}

void right() {
  motionID = 4;
  stime = millis();
}

void stop(){
  motionID = 0;
  stime = millis();
}

//----------- Get Data Buttons -----------
void getdata() {
  //myPort.write("[p]");
}
import processing.serial.*;
import controlP5.*;

Serial myPort;
ControlP5 button;

int torque = 1;
int speed  = 200;
char str;

KingSpider king_spider;

void setup()
{
    king_spider = new KingSpider();
    size(800, 600);
    frameRate(100);
    smooth();
    myPort=new Serial(this, "/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_AG0K5ARF-if00-port0", 57600);
    myPort.clear();
    println("serial open");
    //while (myPort.available()>0)
    //{
    //    str=(char)myPort.read();
    //    print(str);
    //}
    king_spider.writeCommand("[v,200]\n");
    myPort.write("[v,200]\n");

    PFont myFont = createFont("Arial", 16, true);
    ControlFont cf1 = new ControlFont(myFont, 14);
    button = new ControlP5(this);

    fill(0);
    textSize(16);
    textAlign(CENTER);
    if (torque>0)
    {
        text("ON", 150, 75);
    }
    else
    {
        text("OFF", 150, 75);
    }

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
        .setPosition(50, 250)
        .setSize(200, 100)
        .setColorActive(color(192, 64, 64))
        .setColorBackground(color(128, 64, 64))
        .setColorForeground(color(64, 64, 64))
        .setColorCaptionLabel(color(0, 0, 0));
    button.addButton("posture2")
        .setLabel("Posture 2")
        .setFont(cf1)
        .setPosition(300, 250)
        .setSize(200, 100)
        .setColorActive(color(64, 192, 64))
        .setColorBackground(color(64, 128, 64))
        .setColorForeground(color(64, 64, 64))
        .setColorCaptionLabel(color(0, 0, 0));
    button.addButton("posture3")
        .setLabel("Posture 3")
        .setFont(cf1)
        .setPosition(550, 250)
        .setSize(200, 100)
        .setColorActive(color(64, 64, 192))
        .setColorBackground(color(64, 64, 128))
        .setColorForeground(color(64, 64, 64))
        .setColorCaptionLabel(color(0, 0, 0));
    button.addButton("posture4")
        .setLabel("Posture 4")
        .setFont(cf1)
        .setPosition(50, 450)
        .setSize(200, 100)
        .setColorActive(color(192, 192, 64))
        .setColorBackground(color(128, 128, 64))
        .setColorForeground(color(64, 64, 64))
        .setColorCaptionLabel(color(0, 0, 0));
    button.addButton("posture5")
        .setLabel("Posture 5")
        .setFont(cf1)
        .setPosition(300, 450)
        .setSize(200, 100)
        .setColorActive(color(192, 64, 192))
        .setColorBackground(color(128, 64, 128))
        .setColorForeground(color(64, 64, 64))
        .setColorCaptionLabel(color(0, 0, 0));
    button.addButton("posture6")
        .setLabel("Posture 6")
        .setFont(cf1)
        .setPosition(550, 450)
        .setSize(200, 100)
        .setColorActive(color(64, 192, 192))
        .setColorBackground(color(64, 128, 128))
        .setColorForeground(color(64, 64, 64))
        .setColorCaptionLabel(color(0, 0, 0));

    setLegLengths();
}

void draw()
{
    background(55);

    planMotion();

    if (keyPressed) {
        if (key == 'm')
        {
            myPort.write("[m,1,512,2,512,3,512,4,512,5,512,6,512,7,512,8,512,9,512,10,512,11,512,12,512,13,512,14,512,15,512,16,512,17,512,18,512]\n");
        }
        else if (key == '1')
        {
            posture1();
        }
        else if (key == 'i')
        {
            myPort.write("[i]\n");
        }
        else if (key == 'e')
        {
            myPort.write("[e]\n");
        }
        else if (key == 'p')
        {
            myPort.write("[p]\n");
            delay(100);
            while (myPort.available()>0)
            {
                str=(char)myPort.read();
                print(str);
            }
        }
        else if (key == 'n')
        {
            myPort.write("[n]\n");
            torque = 1;
        }
        else if (key == 'f')
        {
            myPort.write("[f]\n");
            torque = 0;
        }
        else if (key == 'c')
        {
            myPort.write("[c]\n");
            king_spider.writeCommand("[v,30]\n");
            speed = 30;
        }
        else if (key == 'v')
        {
            myPort.write("[v]\n");
            king_spider.writeCommand("[v,60]\n");
            speed = 60;
        }
        else if (key == 'b')
        {
            myPort.write("[b]\n");
            king_spider.writeCommand("[v,100]\n");
            speed = 100;
        }
        else if (key == 'h')
        {
            myPort.write("[v,200]\n");
            king_spider.writeCommand("[v,200]\n");
            speed = 200;
            //thread("walk");
        }
    }

    fill(0);
    textSize(32);
    textAlign(LEFT);
    text("Torque:", 50, 75);
    textAlign(LEFT);
    if (torque>0)
    {
        text("ON", 190, 75);
    }
    else
    {
        text("OFF", 190, 75);
    }

    textAlign(LEFT);
    text("Speed:", 50, 125);
    textAlign(RIGHT);
    text(speed, 250, 125);
    delay(1);
}

void servo()
{
    if (torque == 0) {
        myPort.write("[n]\n");
    }
    else
    {
        myPort.write("[f]\n");
    }
}

void initial()
{
    myPort.write("[i]\n");
    king_spider.rotateRollPitchYaw(0.0, 0.0,0.0);
    king_spider.moveXY(0.0, 0.0);
    king_spider.writeCommand("[i]\n");
}

void ending()
{
    myPort.write("[e]\n");
    king_spider.rotateRollPitchYaw(0.0, 0.0,0.0);
    king_spider.moveXY(0.0, 0.0);
    king_spider.writeCommand("[e]\n");
}

void posture1()
{
    myPort.write("[m,1,412,2,612,3,512,4,512,5,512,6,512,7,512,8,512,9,512,10,512,11,512,12,512,13,612,14,412,15,512,16,512,17,512,18,512]\n");
    king_spider.writeCommand("[m,1,412,2,612,3,512,4,512,5,512,6,512,7,512,8,512,9,512,10,512,11,512,12,512,13,612,14,412,15,512,16,512,17,512,18,512]\n");
}

void posture2()
{
    myPort.write("[m,1,412,2,612,3,412,4,512,5,512,6,512,7,512,8,512,9,512,10,412,11,512,12,512,13,612,14,412,15,612,16,512,17,512,18,512]\n");
    king_spider.writeCommand("[m,1,412,2,612,3,412,4,512,5,512,6,512,7,512,8,512,9,512,10,412,11,512,12,512,13,612,14,412,15,612,16,512,17,512,18,512]\n");
}

void posture3()
{
    //myPort.write("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    //king_spider.writeCommand("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    //king_spider.setJointAngleValue(int(random(1,18)), int(random(0,1024)));
    //king_spider.rotateRollPitchYaw(random(-PI, PI), random(-PI, PI), random(-PI, PI));
    king_spider.rotateRollPitchYaw(PI, 0.0,0.0);
}

void posture4()
{
    //myPort.write("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    //king_spider.writeCommand("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    king_spider.setJointAngleValue(int(random(1,18)), int(random(0,1024)));
    king_spider.rotateRollPitchYaw(random(-PI, PI), random(-PI, PI), random(-PI, PI));
    king_spider.moveXY(random(-100, 100), random(-100, 100));
}

void posture5()
{
    //myPort.write("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    //king_spider.writeCommand("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    king_spider.writeCommand("[i]\n");
    //myPort.write("[i]\n");
    delay(500);
    king_spider.writeCommand("[m,1,212,2,812,3,312,4,712,5,312,6,712,7,512,8,512,9,712,10,312,11,712,12,312,13,812,14,212,15,712,16,312,17,712,18,312]\n");
    //myPort.write("[m,1,212,2,812,3,312,4,712,5,312,6,712,7,512,8,512,9,712,10,312,11,712,12,312,13,812,14,212,15,712,16,312,17,712,18,312]\n");
    delay(1000);
    king_spider.writeCommand("[m,1,212,2,812,3,112,4,712,5,312,6,712,7,512,8,512,9,712,10,112,11,712,12,312,13,812,14,212,15,912,16,312,17,712,18,312]\n");
    //myPort.write("[m,1,212,2,812,3,112,4,712,5,312,6,712,7,512,8,512,9,712,10,112,11,712,12,312,13,812,14,212,15,912,16,312,17,712,18,312]\n");
    delay(500);
    for (int i = 0; i < 2; i++)
    {
        king_spider.writeCommand("[m,1,412,2,812,3,112,4,712,5,312,6,712,7,512,8,312,9,712,10,112,11,712,12,312,13,1012,14,212,15,912,16,312,17,712,18,312]\n");
        //myPort.write("[m,1,412,2,812,3,112,4,712,5,312,6,712,7,512,8,312,9,712,10,112,11,712,12,312,13,1012,14,212,15,912,16,312,17,712,18,312]\n");
        delay(500);
        king_spider.writeCommand("[m,1,412,2,812,3,312,4,712,5,312,6,712,7,512,8,312,9,712,10,312,11,712,12,312,13,1012,14,212,15,712,16,312,17,712,18,312]\n");
        //myPort.write("[m,1,412,2,812,3,312,4,712,5,312,6,712,7,512,8,312,9,712,10,312,11,712,12,312,13,1012,14,212,15,712,16,312,17,712,18,312]\n");
        delay(500);
        king_spider.writeCommand("[m,1,412,2,812,3,312,4,912,5,312,6,712,7,512,8,312,9,912,10,312,11,712,12,312,13,1012,14,212,15,712,16,112,17,712,18,312]\n");
        //myPort.write("[m,1,412,2,812,3,312,4,912,5,312,6,712,7,512,8,312,9,912,10,312,11,712,12,312,13,1012,14,212,15,712,16,112,17,712,18,312]\n");
        delay(500);
        king_spider.writeCommand("[m,1,212,2,612,3,312,4,912,5,312,6,712,7,712,8,512,9,912,10,312,11,712,12,312,13,812,14,712,15,112,16,712,17,312]\n");
        //myPort.write("[m,1,212,2,612,3,312,4,912,5,312,6,712,7,712,8,512,9,912,10,312,11,712,12,312,13,812,14,712,15,112,16,712,17,312]\n");
        delay(500);
        king_spider.writeCommand("[m,1,212,2,612,3,312,4,712,5,312,6,712,7,712,8,512,9,712,10,312,11,712,12,312,13,812,14,712,15,312,16,712,17,312]\n");
        //myPort.write("[m,1,212,2,612,3,312,4,712,5,312,6,712,7,712,8,512,9,712,10,312,11,712,12,312,13,812,14,712,15,312,16,712,17,312]\n");
        delay(500);
        king_spider.writeCommand("[m,1,212,2,612,3,112,4,712,5,312,6,712,7,712,8,512,9,712,10,112,11,712,12,312,13,812,14,912,15,312,16,712,17,312]\n");
        //myPort.write("[m,1,212,2,612,3,112,4,712,5,312,6,712,7,712,8,512,9,712,10,112,11,712,12,312,13,812,14,912,15,312,16,712,17,312]\n");
        delay(500);
    }
    king_spider.writeCommand("[m,1,212,2,812,3,312,4,712,5,312,6,712,7,512,8,512,9,712,10,312,11,712,12,312,13,812,14,212,15,712,16,312,17,712,18,312]\n");
    //myPort.write("[m,1,212,2,812,3,312,4,712,5,312,6,712,7,512,8,512,9,712,10,312,11,712,12,312,13,812,14,212,15,712,16,312,17,712,18,312]\n");
    delay(1000);
    king_spider.writeCommand("[i]\n");
    //myPort.write("[i]\n");
}
void posture6()
{
    //myPort.write("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    //king_spider.writeCommand("[m,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512]\n");
    //king_spider.writeCommand("[v,200]\n");
    //speed = 200;
        //king_spider.writeCommand("[i]\n");
        //delay(500);
        //posture6_2();
        //delay(500);
    king_spider.writeCommand("[i]\n");
}

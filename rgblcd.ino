#include <Wire.h>
#include "rgb_lcd.h"

rgb_lcd lcd;
int jobSize = 500;
int algoType;
#define BUTTON_PIN 4
void setup()
{
  Serial.begin(9600);
  pinMode(BUTTON_PIN,INPUT_PULLUP);
  lcd.begin(16,2);
  delay(30);
  lcd.setRGB(255,255,255);
  delay(30);
  while(!(Serial.available() >0));
  algoType = Serial.read();
  Serial.println(jobSize);
  Serial.flush();
  lcd.clear(); 
  delay(30);
  while(!(Serial.available() > 0));
  
  
  lcd.setCursor(0,0);
  delay(30);
  lcd.write("RAINBOWS");
  delay(30);
  lcd.setCursor(0,1);
  delay(30);
  lcd.write("Job Size: ");
  delay(30);
  lcd.setCursor(10,1);
  delay(30);
  lcd.print(jobSize);  
  delay(30);
  
  if(Serial.read() == 'g')
  {
    Serial.flush();
  }
  else Serial.println("ERROR");
}

void waitForStart()
{
  //Serial.println("Waiting for Start");
  if(algoType=='1')
  {
  Serial.println(jobSize);
  }
  while(!(Serial.available() > 0));
  if(Serial.read() == 'g')
  return;
}

void signalPolling()
{
  if(Serial.available() > 0)
  {
    if(Serial.read() == 's')
    {
      //Serial.println("Stopped");
      waitForStart();
    }
  }
  else return;
  
}

void loop()
{
  int sensorVal = digitalRead(BUTTON_PIN);
  int i,j,k;
  for(i=0;i<255;i+=2)
  {
    signalPolling();
    sensorVal = digitalRead(BUTTON_PIN);
    if(sensorVal == 0)
    {
      endFunc();
    }
    signalPolling();
    lcd.setRGB(i,0,0);
    delay(30);
    signalPolling();    
    if(i%5==0) jobSize-= 1;
  }
  if(jobSize<=0)
  {
    completed();
  }
  lcd.setCursor(10,1);
  lcd.print("   ");
  lcd.setCursor(10,1);
  lcd.print(jobSize);
  for(j=0;j<255;j+=2)
  {
    signalPolling();
    sensorVal = digitalRead(BUTTON_PIN);
    if(sensorVal == 0)
    {
      endFunc();
    }
    signalPolling();
    lcd.setRGB(0,j,0);
    delay(30);
    signalPolling();
    if(j%5==0) jobSize-= 1;
  }
  if(jobSize<=0)
  {
    completed();
  }
  lcd.setCursor(10,1);
  lcd.print("   ");
  lcd.setCursor(10,1);
  lcd.print(jobSize);
  for(k=0;k<255;k+=2)
  {
    signalPolling();
    sensorVal = digitalRead(BUTTON_PIN); 
    if(sensorVal == 0)
    {
      endFunc();
    }
    signalPolling();
    lcd.setRGB(0,0,k);
    delay(30);
    signalPolling();
  if(k%5==0) jobSize-= 1;
  }
  lcd.setCursor(10,1);
  lcd.print("   ");
  lcd.setCursor(10,1);
  lcd.print(jobSize);
  if(jobSize<=0)
  {
    completed();
  }
}  
  
void endFunc()
{
  Serial.println("e");
  delay(20);
  lcd.clear();
  delay(30);
  lcd.setCursor(0,0);
  delay(30);
  lcd.write("Process Killed");
  delay(30);
  lcd.setCursor(0,1);
  delay(30);
  lcd.write("By User!");
  delay(30);
  lcd.setRGB(255,0,0);
  delay(30);
  delay(20);
  while(1);
}

void completed()
{
  Serial.println("e");
  delay(20);
  lcd.clear();
  delay(30);
  lcd.setCursor(0,0);
  delay(30);
  lcd.write("Process Finished");
  delay(30);
  lcd.setCursor(0,1);
  delay(30);
  lcd.write("Job Over!");
  delay(30);
  lcd.setRGB(0,255,0);
  delay(30);
  while(1);
}

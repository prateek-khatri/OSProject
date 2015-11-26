#include <LiquidCrystal_I2C.h>
#include <Wire.h>

LiquidCrystal_I2C lcd(0x3F, 16,2);
int i=0;
int j=16;
int jobSize = 434;
int algoType;
void setup()
{
  
  lcd.init();
  lcd.clear();
  lcd.noBacklight();
  lcd.setCursor(0,0);
  Serial.begin(9600);
  pinMode(13,OUTPUT);
  digitalWrite(13,LOW);
  //Serial.println("Waiting for Algo Type");
  while(!(Serial.available() >0));
  algoType = Serial.read();
  Serial.println(jobSize);
  Serial.flush();
  //Serial.println("Wating for Start Signal");
  while(!(Serial.available() >0));
    lcd.backlight();
    lcd.setCursor(0,0);
    lcd.print("COEN 283 - OS");
    lcd.setCursor(0,1);
    lcd.print("Scheduling = Fun");
    
  if(Serial.read() == 'g')
  {
    Serial.flush();
    int k;
    for(k=0;k<16;k++)
    {
      lcd.scrollDisplayLeft();
    }
    return;
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
  
    int k=0;
    for(k=0;k<32;k++)
    {
      signalPolling();
      jobSize -=2;
      signalPolling();
      delay(200);
      signalPolling();
      lcd.scrollDisplayRight();
      signalPolling();
    }
    for(k=0;k<32;k++)
    {
      signalPolling();
      jobSize -=2;
      signalPolling();
      delay(200);
      signalPolling();
      lcd.scrollDisplayLeft();
      signalPolling();
    }
    
    if(jobSize<=0)
    {
      Serial.println("e");
      while(1);
    }
}

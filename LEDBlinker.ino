int jobSize = 160;
int algoType;
void setup()
{
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
  if(Serial.read() == 'g')
  {
    Serial.flush();
    return;
  }
  else Serial.println("ERROR");

}
  
  
  


void waitForStart()
{
  //Serial.println("Waiting for Start");
  if(algoType == '1')
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
  
    digitalWrite(13,HIGH);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    digitalWrite(13,LOW);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    delay(100);
    signalPolling();
    jobSize-=8;
    if(jobSize<=0)
    {
      Serial.println("e");
      while(true);
      
    }
}

int jobSize = 160;
int algoType;
void setup()
{
  Serial.begin(9600);
  pinMode(13,OUTPUT);
  pinMode(8,OUTPUT);
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
  pinMode(11,OUTPUT);
  pinMode(12,OUTPUT);
  
  digitalWrite(8,LOW);
  digitalWrite(9,LOW);
  digitalWrite(10,LOW);
  digitalWrite(11,LOW);
  digitalWrite(12,LOW);
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
    digitalWrite(13,HIGH);
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
      digitalWrite(13,LOW);
      //Serial.println("Stopped");
      waitForStart();
    }
  }
  else return;
  
}

void loop()
{
    signalPolling();
    digitalWrite(8,HIGH);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    digitalWrite(12,LOW);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,HIGH);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    digitalWrite(12,LOW);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,HIGH);
    digitalWrite(11,LOW);
    digitalWrite(12,LOW);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,HIGH);
    digitalWrite(12,LOW);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    digitalWrite(12,HIGH);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    digitalWrite(12,HIGH);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,HIGH);
    digitalWrite(12,LOW);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,HIGH);
    digitalWrite(11,LOW);
    digitalWrite(12,LOW);
    signalPolling();
    delay(100);
    digitalWrite(8,LOW);
    digitalWrite(9,HIGH);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    digitalWrite(12,LOW);
    signalPolling();
    delay(100);
    digitalWrite(8,HIGH);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    digitalWrite(12,LOW);
    signalPolling();
    jobSize-=8;
    if(jobSize<=0)
    {
      Serial.println("e");
      while(true);
      
    }
}

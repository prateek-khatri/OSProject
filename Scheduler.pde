import processing.serial.*;

/*************************************
* Golabl Declarations
/*************************************/
Serial[] myPort = new Serial[4];     
int devices = 0;
String[] jobSize = new String[4];
boolean[] ready = new boolean[4];
boolean[] isStarted = new boolean[4];
String b = new String("e");
int[] count =new int[4];
/*************************************
* Setup Function
* Initialize Data Memebers
* Initialize Ports
* Intialize Handshake Procedures
/*************************************/
void setup()
{
  
int length = Serial.list().length;
println(Serial.list());

for(int i = 0 ;i<length;i++)
{
  myPort[i] = new Serial(this, Serial.list()[i], 9600);
  myPort[i].bufferUntil('\n');
}
devices = length;
if(devices == 0)
{
  println("No Devices Found, Please restart proram after attaching processes!");
  return;
}

//INSERT MODULAR FUNCTION FOR STARTING THE PORTS.

  init();
  roundRobin(2);
  //fifo();

  //println("Waiting for Start Signal");


}

/*************************************
* Init Function
* Initialize Ports
* Read Job Size from Each Process
* All processes can be set to Read State
/*************************************/
void init()
{
  for(int i = 0; i<devices;i++)
  {
    count[i] = 1;
    isStarted[i] = false;
    ready[i] = true;
    myPort[i].clear();
    delay(5000);
    myPort[i].write('0');
    delay(1000);
    println("Port "+ i +" Initialized");
    
    while(!(myPort[i].available()>0));
    
    while(myPort[i].available() > 0)
    {///////////////////////////////////////////////FIX THIS 
      jobSize[i] = myPort[i].readStringUntil('\n');
      if(jobSize[i] != null)
      {
        println("Job Size for Process "+(i+1)+" is "+jobSize[i]);
      }
    }
    myPort[i].clear();
  }
}
/*************************************
* Draw Function
* Draw Screens Here
* Draws User Interface
* Aggregates Information
/*************************************/

void draw()
{
  
}

/*************************************
* Fifo Function
* Implements First Come First Serve
* Outputs Time For execution of Processes
* Order depends on COM Ports.
/*************************************/

void fifo()
{
  println("Init FIFO Algorithm");
  int current = 0;
  int[] startTime = new int[devices];
  int[] endTime = new int[devices];
  int[] waitTime = new int[devices];
  for(int i=0;i<devices;i++)
  {
    
    myPort[i].write('g');
    startTime[i] = millis();
    delay(1000);
    println("Process "+(i+1)+" is running...");
    
    while(true)
    {
      delay(500);
      String a = myPort[i].readStringUntil('\n');
      if(a != null) break;
    }
    endTime[i] = millis();
  }
    
    
  
  
  for(int i = 0;i<devices;i++)
  {
    println("Process "+(i+1)+" finished in "+ ((endTime[i]-startTime[i])/1000)+" seconds.");
  }
}

void roundRobin(int timeSlice) //in seconds
{
  println("Init Round Robin Algorithm");
  int current = 0;
  int[] startTime = new int[devices];
  int[] endTime = new int[devices];
  int[] waitTime = new int[devices];
  int[] execTime = new int[devices];
  int start_exec = 0;
  
  
  int k=0;
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  {
    
    for(int i=0;i<devices;i++)
    {
      
      if(ready[i]==true)
      {
        if(!isStarted[i])
        {
          startTime[i] = millis();
          isStarted[i] = true;
        }
        myPort[i].write('g');
        println("Process "+(i+1)+" is running...");
        start_exec = millis();
        //delay(1000);
        
        while(true)
        {
          delay(1000);
          String a =myPort[i].readStringUntil('e');
          
          if(a!=null)
          {
            if(a.equals("e"))
            {
              ready[i] = false;
              println("Process "+(i+1)+" has ended.");
              endTime[i] = millis();
              println("Process "+(i+1)+" finished in "+ ((endTime[i]-startTime[i])/1000)+" seconds.");
              println("Process "+(i+1)+" executed for"+ execTime[i]);
              break;
            }
          }
          else if((millis() - start_exec)/1000 >= timeSlice)
          {
            myPort[i].write('s');
            println("Process "+(i+1)+" is Preempted...");
            execTime[i] = count[i]*timeSlice;
            count[i]++;
            break;
          }
        }
      }
    }
  }   
}
  

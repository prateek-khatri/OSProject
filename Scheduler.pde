import processing.serial.*;
import java.io.*;
import java.util.*;
class Node
{
  private int start_time;
  private int end_time;
  
  public Node(int a,int b)
  {
    start_time = a;
    end_time = b;
  }
}
LinkedList<Node> A= new LinkedList<Node>();
LinkedList<Node> B= new LinkedList<Node>();
LinkedList<Node> C= new LinkedList<Node>();
LinkedList<Node> D= new LinkedList<Node>();

/*************************************
* Golabl Declarations
/*************************************/
Serial[] myPort = new Serial[4];
Serial[] reOrder = new Serial[4];
int devices = 0;
int[] jobSize = new int[4];
int[] jobSizeReorder = new int[4];
boolean[] ready = {false,false,false,false}; // replace by true for debugging
boolean[] hasArrived = {false,false,false,false};
boolean[] isStarted ={false,false,false,false};
int[] arrival = {-1,-1,-1,-1};
int[] arrivalOrder = {500,500,500,500};
int[] count =new int[4];
int g_startTime;
int super_global;
/*************************************
* Setup Function
* Initialize Data Memebers
* Initialize Ports
* Intialize Handshake Procedures
/*************************************/
void reOrderPorts()
{
  
  fixArrival();
  int[] index = {-1,-1,-1,-1};
  int smallest=1000;
  int k=0;
  println("Arrival Array");
  println(arrival);
  while(true)
  {
    for(int i=0;i<devices;i++)
    {
      if(arrival[i] <= smallest)
      {
        smallest = arrival[i];
        index[k] = i;
      }
    }
    arrival[index[k]] = 1000;
    smallest=10001;
    k++;
    if(k == devices) break;
  }
  
  for(int i=0;i<devices;i++)
  {
    reOrder[i] = myPort[index[i]];
  }
  for(int i=0;i<devices;i++)
  {
    myPort[i] = reOrder[i];
  }
  
  println("Arrival Index");
  println(index);
}
/*************************************
* shortestReorder Function
* For Shortest Job First
* Orders Ports According to Job Sizes
* Only to be Invoked by SJF
/*************************************/
void shortestReorder()
{
  int[] index = {-1,-1,-1,-1};
  int smallest=1000;
  int k=0;
  println("Job Size Array");
  println(jobSize);
  while(true)
  {
    for(int i=0;i<devices;i++)
    {
      if(jobSize[i] <= smallest)
      {
        smallest = jobSize[i];
        index[k] = i;
      }
    }
    jobSize[index[k]] = 1000;
    smallest=10001;
    k++;
    if(k == devices) break;
  }
  
  for(int i=0;i<devices;i++)
  {
    reOrder[i] = myPort[index[i]];
  }
  for(int i=0;i<devices;i++)
  {
    myPort[i] = reOrder[i];
  }
  
  println("Arrival Index");
  println(index);
}
/*************************************
* fixArrival Function
* Takes Arrival Order Input 
* Helper for Re-ordering Processor Ports
* Sets Arrival Times
/*************************************/
void fixArrival()
{
  for(int i=0;i<devices;i++)
  {
    arrival[i] = (int)random(0,30);
    arrivalOrder[i] = arrival[i];
  }

  Arrays.sort(arrivalOrder);
  for(int i=0;i<devices;i++)
  {
    println("Process "+(i+1)+" arrives at "+arrivalOrder[i]+" seconds.");
  }
}
  
/*************************************
* Setup Function
* Initialize Data Memebers
* Initialize Ports
* Intialize Handshake Procedures
/*************************************/
void setup()
{




  //roundRobin(10);
  shortestJobFirst();
  //fifo();
  
  
  
  

  //println("Waiting for Start Signal");


}

/*************************************
* Init Function
* Initialize Ports
* Read Job Size from Each Process
* All processes can be set to Read State
/*************************************/
void init(int mode)
{
    super_global = millis();
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
  
  for(int i = 0; i<devices;i++)
  {
    ///////////INITIALIZE DATA STRUCTURES//////////////
    ready[i] = true;
    hasArrived[i] =false;
    isStarted[i] = false;
    count[i] = 1;
    myPort[i].clear();
    delay(5000);
    ///////////////////////////////////////////////////
    if(mode==0)
    {
    myPort[i].write('0');
    }
    else if(mode ==1)
    {
      myPort[i].write('1');
    }
    delay(1000);
    println("Port "+ i +" Initialized");
    
    while(!(myPort[i].available()>0));
    
    while(myPort[i].available() > 0)
    {///////////////////////////////////////////////FIX THIS 
      String a = myPort[i].readStringUntil(10);
      char[] b =a.toCharArray();
      int test = (b[0] - '0')*100;
      test += (b[1] - '0')*10;
      test+= (b[2] -'0');
      jobSize[i] = test;
      jobSizeReorder[i] = test;
      if(a != null)
      {
        println("Job Size for Process "+(i+1)+" is "+jobSize[i]);
      }
    }
    myPort[i].clear();
  }
  Arrays.sort(jobSizeReorder);
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
* shortestJobFirst Function
* Implements SJF(non-preempted)
* Outputs Time For execution of Processes
* Order depends on COM Ports.
/*************************************/
void shortestJobFirst()
{
  init(0);
  shortestReorder();
  println("Init SJF Algorithm");
  int[] startTime = new int[devices];
  int[] endTime = new int[devices];
  g_startTime = millis();
  
  
  
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  {
    for(int i=0;i<devices;i++)
    {
      if(ready[i] == true)
      {
        myPort[i].write('g');
        if(i!=0)
        {
          startTime[i] = currentTime();
        }
        else
        {
        startTime[i] = currentTime();
        }
        
        delay(1000);
        println("Process "+(i+1)+" is running...");
        
    
        while(true)
        {
          delay(500);
          String a = myPort[i].readStringUntil('\n');
          if(a != null)
          {
            ready[i] = false;
            println("Process "+(i+1)+" has ended.");
            println("Current Time: "+ currentTime());
            break;
          }
        }
        if(i!=0)
        {
          endTime[i] = currentTime();
        }
        else
        {
        endTime[i] = currentTime();
        }
      } 
    }
  }
    
  
  
  for(int i = 0;i<devices;i++)
  {
    println("Process "+(i+1)+" finished at "+ (endTime[i])+" seconds.");
  }
    
  stopAllConnections();    
  
}
/*************************************
* Fifo Function
* Implements First Come First Serve
* Outputs Time For execution of Processes
* Order depends on COM Ports.
/*************************************/
void fifo()
{
  init(0);
  reOrderPorts();
  println("Init FIFO Algorithm");
  int[] startTime = new int[devices];
  int[] endTime = new int[devices];
  g_startTime = millis();
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  {
    int k=0;
    for(int i=0;i<devices;i++)
    {
      if(k==devices) 
      {
        k=0;
      }
      checkReadyQueue(k);
      if(ready[i] == true && hasArrived[i] == true)
      {
        myPort[i].write('g');
        if(i!=0)
        {
          startTime[i] = millis();
        }
        else
        {
        startTime[i] = millis();
        }
        
        delay(1000);
        println("Process "+(i+1)+" is running...");
        
    
        while(true)
        {
          delay(500);
          String a = myPort[i].readStringUntil('\n');
          if(a != null)
          {
            ready[i] = false;
            println("Process "+(i+1)+" has ended.");
            println("Current Time: "+ currentTime());
            break;
          }
        }
        if(i!=0)
        {
          endTime[i] =  millis();
        }
        else
        {
        endTime[i] = millis();
        }
      } k++;
    }
  }
    
  
  
  for(int i = 0;i<devices;i++)
  {
    println("Process "+(i+1)+" finished at "+ (((endTime[i]-startTime[i])/1000)+((startTime[i]-g_startTime)/1000))+" seconds.");
  }
  stopAllConnections();
}
/*************************************
* Round Robin Function
* Implements RR Algorithm
* Stores Timeline in LinkedList
* Outputs the Timeline
/*************************************/

void roundRobin(int timeSlice) //in seconds
{
  init(0);
  reOrderPorts();
  println("Init Round Robin Algorithm");

  int start_exec = 0;
  int preempted = 0;
  g_startTime = millis();
  
  
  
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  {
    int k=0;
    
    for(int i=0;i<devices;i++)
    {
      if(k==devices) 
      {
        k=0;
      }
      checkReadyQueue(k);
      if(ready[i]==true && hasArrived[i]==true)
      {
        myPort[i].write('g');
        println("Process "+(i+1)+" is running...");
        start_exec = currentTime();
        
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
              println("Current Time: "+ currentTime());
              preempted = currentTime();
              break;
            }
          }
          else if((currentTime() - start_exec) >= timeSlice)
          {
           
            myPort[i].write('s');
            println("Process "+(i+1)+" is Preempted...");
            println("Current Time: "+ currentTime());
            preempted = currentTime();
            break;
          }
        }
        insertTime(i,start_exec,preempted);
      }
      k++;
    }
    
  }
   println("A Linked List");
   for(int i=0;i<A.size();i++)
   {
     print(A.get(i).start_time+ " ");
     println(A.get(i).end_time);
   }
   println("B Linked List");
   for(int i=0;i<B.size();i++)
   {
     print(B.get(i).start_time+ " ");
     println(B.get(i).end_time);
   }
   println("C Linked List");
   for(int i=0;i<C.size();i++)
   {
     print(C.get(i).start_time+ " ");
     println(C.get(i).end_time);
   }
   stopAllConnections();
}
/*************************************
* insertTime Function
* Inserts Time in Linked Lists for Preempted Processes
* Stores Timeline in LinkedList
/*************************************/
void insertTime(int process,int start_exec,int preempted)
{
  if(process == 0)
  {
    Node n = new Node(start_exec,preempted);
    A.add(n);
  }
  else if(process == 1)
  {
    Node n = new Node(start_exec,preempted);
    B.add(n);
  }
  else if(process == 2)
  {
    Node n = new Node(start_exec,preempted);
    C.add(n);
  }
  else if(process == 3)
  {
    Node n = new Node(start_exec,preempted);
    D.add(n);
  }
}
/*************************************
* currentTime

* Returns Current Time from Algo Start
/*************************************/
int currentTime()
{
  return ((millis()-g_startTime)/1000);
}
/*************************************
* checkReadyQueue Function
* Just checks if a Process has arrived
* sets hasArrived array value if process has arrived
/*************************************/
void checkReadyQueue(int k)
{
  //println("Time Check! With K= "+k);
  //println(arrivalOrder[k]+ " "+ currentTime());
  if(arrivalOrder[k]<= currentTime() && isStarted[k] == false )
  {
    hasArrived[k] = true;
    isStarted[k] = true;
    println("Process "+(k+1)+" has Arrived.");
  }
}
void stopAllConnections()
{
  for(int i=0;i<devices;i++)
  {
    myPort[i].stop();
  }
  super_global = millis();
}
  

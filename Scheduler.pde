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
String[] jobSize = new String[4];
boolean[] ready = {false,false,false,false}; // replace by true for debugging
boolean[] isServed = {false,false,false,false};
boolean[] hasEnded ={false,false,false,false};
int[] arrival = {-1,-1,-1,-1};
int[] arrivalOrder = {-1,-1,-1,-1};
String b = new String("e");
int[] count =new int[4];
int g_startTime;
/*************************************
* Setup Function
* Initialize Data Memebers
* Initialize Ports
* Intialize Handshake Procedures
/*************************************/
void reOrderPorts()
{
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

// GRAB ARRIVAL TIMES FROM USER - RIGHT NOW SET MANUALLY
for(int i=0;i<devices;i++)
{
  arrival[i] = (int)random(0,100);
  arrivalOrder[i] = arrival[i];
}



//INSERT MODULAR FUNCTION FOR STARTING THE PORTS.

  init();
  reOrderPorts();
  roundRobin(12);
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
    ///////////INITIALIZE DATA STRUCTURES//////////////
    ready[i] = true;
    count[i] = 1;
    myPort[i].clear();
    delay(5000);
    ///////////////////////////////////////////////////
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
  int[] startTime = new int[devices];
  int[] endTime = new int[devices];
  g_startTime = millis();
  for(int i=0;i<devices;i++)
  {
    
    myPort[i].write('g');
    if(i!=0)
    {
      startTime[i] = startTime[i-1] + millis();
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
      if(a != null) break;
    }
    if(i!=0)
    {
      endTime[i] = endTime[i-1] + millis();
    }
    else
    {
    endTime[i] = millis();
    }
  }
    
    
  
  
  for(int i = 0;i<devices;i++)
  {
    println("Process "+(i+1)+" finished in "+ ((endTime[i]-startTime[i])/1000)+" seconds.");
  }
}
/*************************************
* Round Robin Function
* Implements RR Algorithm
* Stores Timeline in LinkedList
* Outputs the Timeline
/*************************************/

void roundRobin(int timeSlice) //in seconds
{
  println("Init Round Robin Algorithm");

  int start_exec = 0;
  int preempted = 0;
  g_startTime = millis();
  
  
  int k=0;
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  {
    
    for(int i=0;i<devices;i++)
    {
      
      if(ready[i]==true)
      {
        myPort[i].write('g');
        println("Process "+(i+1)+" is running...");
        start_exec = millis()/1000;
        
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
              preempted = millis()/1000;
              break;
            }
          }
          else if((millis() - (start_exec*1000))/1000 >= timeSlice)
          {
            myPort[i].write('s');
            println("Process "+(i+1)+" is Preempted...");
            preempted = millis()/1000;
            break;
          }
        }
        insertTime(i,start_exec,preempted);
      }
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
}
/*************************************
* Helper Function
* Inserts Time in Linked Lists for Preempted Processes
* Stores Timeline in LinkedList
/*************************************/
void insertTime(int process,int start_exec,int preempted)
{
  if(process == 0)
  {
    Node n = new Node(start_exec-(6*devices),preempted-(6*devices));
    A.add(n);
  }
  else if(process == 1)
  {
    Node n = new Node(start_exec-(6*devices),preempted-(6*devices));
    B.add(n);
  }
  else if(process == 2)
  {
    Node n = new Node(start_exec-(6*devices),preempted-(6*devices));
    C.add(n);
  }
  else if(process == 3)
  {
    Node n = new Node(start_exec-(6*devices),preempted-(6*devices));
    D.add(n);
  }
}
  

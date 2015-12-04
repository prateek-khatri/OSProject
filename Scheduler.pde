import processing.serial.*;
import java.io.*;
import java.util.*;
class Node
{
  private int start_time;
  private int end_time;
  public int run_time;
  public int wait_time;
    
  public Node(int a,int b)
  {
    start_time = a;
    end_time = b;
    
  }
  public void setRunTime(int time) {
    run_time = time; 
  }
  public void setWaitTime(int time) {
    wait_time = time; 
  }
}
int[] wait_time = {0,0,0,0};
int[] response_time   = {0,0,0,0};
int[] turnaround_time = {0,0,0,0};
  
LinkedList<Node> A= new LinkedList<Node>();
LinkedList<Node> B= new LinkedList<Node>();
LinkedList<Node> C= new LinkedList<Node>();
LinkedList<Node> D= new LinkedList<Node>();

/*************************************
* Golabl Declarations
/*************************************/
int inf = Integer.MAX_VALUE;
Serial[] myPort = new Serial[4];
Serial[] reOrder = new Serial[4];
int devices = 0;
int[] jobSize = new int[4];
int[] jobSizeReorder = new int[4];
boolean[] ready = {false,false,false,false}; // replace by true for debugging
boolean[] hasArrived = {false,false,false,false};
boolean[] isStarted ={false,false,false,false};
boolean[] isAccepted = {true,false,false,false};
boolean somethingAccepted = false;
int holding_rate =3;
int accepted_rate = 2;
int[] accepted = {0,inf,inf,inf};
int[] holding = {0,0,0,0};
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
  //println("Arrival Array");
  //println(arrival);
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
    jobSizeReorder[i] = jobSize[index[i]];
    
    
  }
  for(int i=0;i<devices;i++)
  {
    myPort[i] = reOrder[i];
    jobSize[i] = jobSizeReorder[i];
    
  }
  //println("Job Size");
  //println(jobSize);
  //println("Arrival Index");
  //println(index);
}
/*************************************
* shortestReorder Function
* For Shortest Job First
* Orders Ports According to Job Sizes
* Only to be Invoked by SJF
/*************************************/
void shortestReorder()
{
  for(int i=0;i<devices;i++)
  {
    arrivalOrder[i] =0;
  }
  int[] index = {-1,-1,-1,-1};
  int smallest=1000;
  int k=0;
  //println("Job Size Array");
  //println(jobSize);
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
    jobSizeReorder[i] = jobSize[index[i]];
  }
  for(int i=0;i<devices;i++)
  {
    myPort[i] = reOrder[i];
    jobSize[i] = jobSizeReorder[i];
  }
  
  //println("The Job Size for Processes is As Follows:");
  //println(jobSize);
  //println("Arrival Index");
  //println(index);
}
void tabulize(int proc){
  LinkedList<Node> Proc;
  switch(proc) {
    case 0: Proc = A;
    break;
    case 1: Proc = B;
    break;
    case 2: Proc = C;
    break;
    case 3: Proc = D;
    break;
    default:
    Proc = A;
  }
  for(int i = 0; i < Proc.size(); i++) {
    int start = Proc.get(i).start_time;
    int end = Proc.get(i).end_time;
    Proc.get(i).setRunTime(end - start);
        
    //COMPUTE NODE WAIT TIME
    if (i == 0) {
      Proc.get(i).setWaitTime(Proc.get(i).start_time - arrivalOrder[proc]);
    } else {
      Proc.get(i).setWaitTime(Proc.get(i).start_time - Proc.get(i-1).start_time);
    }
    //println("Start | end: "+Proc.get(i).start_time+" "+Proc.get(i).end_time + " = "+Proc.get(i).wait_time);
    //COMPUTE TOTAL WAIT TIME
    wait_time[proc] += Proc.get(i).wait_time;
  }
  response_time[proc] = Proc.get(0).wait_time; //always the first node's wait time 
  turnaround_time[proc] = Proc.get(Proc.size()-1).end_time - arrivalOrder[proc]; 
}
void printTables() {
  for (int proc = 0; proc < devices; proc++) {
    tabulize(proc);
    println();
    println("FOR PROCESS "+(proc+1));
    println("============");
    println("WAIT TIME "+ wait_time[proc]);
    println("RESPONSE TIME "+ response_time[proc]);
    println("TURNAROUND TIME "+ turnaround_time[proc]);
    
    String tbl_wait = String.format("%7d", wait_time[proc]);
    String tbl_resp = String.format("%19d", response_time[proc]);
    String tbl_turn = String.format("%19d", turnaround_time[proc]);
    myTextarea.append("Process "+(proc+1));
    myTextarea.append(tbl_wait);
    myTextarea.append(tbl_resp);
    myTextarea.append(tbl_turn);
    myTextarea.append("\n");
    
  }
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
  size(1365, 768);
  setup_items();
  setup_squares();
  
  //roundRobin(9);
  //selfishRoundRobin(5);
  //shortestJobFirst();
  //fifo();
  //
  //shortestRemainingTimeFirst();
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
    wait_time[i] = 0;
    response_time[i] = 0;
    turnaround_time[i] = 0;
    isAccepted[i] = false;
    somethingAccepted = false;
    accepted[i] = inf;
    holding[i] = 0;
    
    //EMPTY LINKED LISTS HERE/////
    A.clear();
    B.clear();
    C.clear();
    D.clear();
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
        //println("Job Size for Process "+(i+1)+" is "+jobSize[i]);
      }
    }
    myPort[i].clear();
  }
  isAccepted[0] = true;
  accepted[0] = 0;
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
  //ellipse(mx, my, radius, radius);
  
  update(mouseX, mouseY); 
  for (int i=0; i<bNumber; i++) { 
    buttons[i].display();
  }
  for (int i=0; i<no_processes; i++) { 
    sqr[i].display();
  }
  
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
          for (int j=0; j<devices; j++){
            checkReadyQueue(j); //for any new processes that come in between
          }
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
    insertTime(i,startTime[i],endTime[i]);
  }
  printTables();
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
          for (int j=0; j<devices; j++){
            checkReadyQueue(j); //for any new processes that come in between
          }
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
    insertTime(i,(startTime[i]-g_startTime)/1000,(((endTime[i]-startTime[i])/1000)+((startTime[i]-g_startTime)/1000)));
  }
  printTables();
  stopAllConnections();
}
/*************************************
* converToJobSize Function
* Takes in Input String from Serial
* returns the relevant integer
/*************************************/
int convertToJobSize(String b)
{
  char[] abc = b.toCharArray();
  char[] job = new char[(b.length()-2)];
  for(int i=0;i<b.length()-2;i++)
  {
    job[i] = abc[i];
  }
  int test = Integer.parseInt(new String(job));
  return test;
 
}
/*************************************
* isShortestAvailable Function
* Takes in Input String from Serial
* returns the relevant integer
/*************************************/
boolean isShortestAvailable(int index)
{
  int smallest = 10000;
  int dex =devices-1;
  if(index == 0 && hasArrived[1] == false)
  {
    return true;
  }
  else
  {
    
    for(int i=0;i<devices;i++)
    {
      if(hasArrived[i] ==false)
      {
        dex =i-1;
        break;
      }
    }
        
    for(int i = dex ; i>=0; i--)
    {
      if(smallest > jobSize[i])
      {
        smallest = jobSize[i];
      }
    }
  }
  if(smallest == jobSize[index])
  {
    return true;
  }
  else
  {
    return false;
  }
}
/*************************************
* isShortestAvailable Function
* Takes in Input String from Serial
* returns the relevant integer
/*************************************/
boolean isShortestAccepted(int index)
{
  int smallest = 10000;
  int dex =devices-1;
  if(index == 0 && isAccepted[1] == false)
  {
    return true;
  }
  else
  {
    
    for(int i=0;i<devices;i++)
    {
      if(isAccepted[i] ==false)
      {
        dex =i-1;
        break;
      }
    }
        
    for(int i = dex ; i>=0; i--)
    {
      if(smallest > jobSize[i])
      {
        smallest = jobSize[i];
      }
    }
  }
  if(smallest == jobSize[index])
  {
    return true;
  }
  else
  {
    return false;
  }
}
/*************************************
* ShortestJob Function
* Implements RR Algorithm
* Stores Timeline in LinkedList
* Outputs the Timeline
/*************************************/
void shortestRemainingTimeFirst()
{
  init(1);
  reOrderPorts();
  println("Init SRTF Algorithm");
  int start_exec= 0;
  int preempted = 0;
  g_startTime = millis();
  
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  {
    int k=0;
    
    for(int i =0;i<devices;i++)
    {
      if(k==devices) k=0;
      checkReadyQueue(k);
      k++;
      if(ready[i] == true && hasArrived[i] == true && isShortestAvailable(i) == true)
      {
        myPort[i].write('g');
        start_exec = currentTime();
        println("Process "+(i+1)+" is running...");
        
        while(true)
        {
          delay(1000);
          String a =myPort[i].readStringUntil('e');
          for (int j=0; j<devices; j++){
            checkReadyQueue(j); //for any new processes that come in between
          }
          if(a!=null)
          {
            if(a.equals("e"))
            {
              ready[i] = false;
              jobSize[i] = 10000;
              println("Process "+(i+1)+" has ended.");
              println("Current Time: "+ currentTime());
              preempted = currentTime();
              break;
            }
          }
          else if(currentTime() == arrivalOrder[1] || currentTime() == arrivalOrder[2] || currentTime() == arrivalOrder[3])
          {
            
            myPort[i].write('s');
            println("Process Stopped");
            String b= null;
            delay(500);
            while(b == null)
            {
            b = myPort[i].readStringUntil('\n');
            }
            jobSize[i] = convertToJobSize(b);
            println("Job Size Array");
            println(jobSize);
            preempted = currentTime();
            println("Process "+(i+1)+" is Preempted...");
            println("Current Time: "+ currentTime());
            break;
          }
        }
        insertTime(i,start_exec,preempted);
      }
    }
  }
  /*
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
   println("D Linked List");
   for(int i=0;i<D.size();i++)
   {
     print(D.get(i).start_time+ " ");
     println(D.get(i).end_time);
   }*/
   printTables();
   stopAllConnections();
  
  
}

void selfishShortestRemainingTimeFirst()
{
  init(1);
  reOrderPorts();
  println("Init Selfish SRTF Algorithm");
  int start_exec= 0;
  int preempted = 0;
  g_startTime = millis();
  
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  {
    int k=0;
    
    for(int i =0;i<devices;i++)
    {
      if(k==devices) k=0;
      checkReadyQueue(k);
      k++;
      if(ready[i] == true && hasArrived[i] == true && isAccepted[i] == true && isShortestAccepted(i) == true)
      {
        myPort[i].write('g');
        start_exec = currentTime();
        println("Process "+(i+1)+" is running...");
        
        while(true)
        {
          delay(1000);
          
          checkHoldingQueue(); //if any procs need to be moved to accepted
          for (int j=0; j<devices; j++){
            checkReadyQueue(j); //for any new processes that come in between
          }
          //INCREMENT THE WAITING TIMES FOR ALL PROCS
          for (int j=0; j<devices; j++){            
            if (ready[j]==true && hasArrived[j]==true) {
              if (accepted[j] < inf) { accepted[j] += accepted_rate; }
              holding[j]  += holding_rate;
            }
          }

          String a =myPort[i].readStringUntil('e');
          
          if(a!=null)
          {
            if(a.equals("e"))
            {
              ready[i] = false;
              jobSize[i] = 10000;
              println("Process "+(i+1)+" has ended.");
              println("Current Time: "+ currentTime());
              preempted = currentTime();
              //if there is nothing else on the accepted queue then graduate whatever is next to it
              if (i < devices-1 && accepted[i+1] == inf) {
                accepted[i+1] = holding[i+1];
                holding[i+1] = -inf;
                isAccepted[i+1] = true;
                somethingAccepted = true;
                println("Process "+(i+2)+" has moved from holding to accepted queue.");
              }
              break;
            }
          }
          
          else if(somethingAccepted == true)
          {
            somethingAccepted = false;
            myPort[i].write('s');
            println("Process Stopped");
            String b= null;
            delay(500);
            while(b == null)
            {
            b = myPort[i].readStringUntil('\n');
            }
            jobSize[i] = convertToJobSize(b);
            println("Job Size Array");
            println(jobSize);
            preempted = currentTime();
            println("Process "+(i+1)+" is Preempted...");
            println("Current Time: "+ currentTime());
            break;
          }
        }
        insertTime(i,start_exec,preempted);
      } else if (ready[i]==true && hasArrived[i]==true) {
        //println("No processes in accepted queue, incrementing other proc "+(i+1));
          //INCREMENT THE WAITING TIMES FOR ALL PROCS
          for (int j=0; j<devices; j++){            
            if (ready[j]==true && hasArrived[j]==true) {
              if (accepted[j] < inf) { accepted[j] += accepted_rate; }
              holding[j]  += holding_rate; 
            }
          }
      }

    }
  }
  /*
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
   println("D Linked List");
   for(int i=0;i<D.size();i++)
   {
     print(D.get(i).start_time+ " ");
     println(D.get(i).end_time);
   }*/
   printTables();
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
          for (int j=0; j<devices; j++){
            checkReadyQueue(j); //for any new processes that come in between
          }
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
    
  }/*
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
   println("D Linked List");
   for(int i=0;i<D.size();i++)
   {
     print(D.get(i).start_time+ " ");
     println(D.get(i).end_time);
   }*/
   printTables();
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
/*************************************
* stopAllConnections Function
* Terminates Serial Connection
* CALL this after any algo ends
/*************************************/
void stopAllConnections()
{
  for(int i=0;i<devices;i++)
  {
    myPort[i].stop();
  }
  super_global = millis();
}
  


/* BENEFIT OF SRR IS THAT PROCESSES ALREADY RUNNING DO NOT TAKE TOO LONG TO COMPLETE */
void selfishRoundRobin(int timeSlice) //in seconds
{
  init(0);
  reOrderPorts();
  println("Init Selfish Round Robin Algorithm");

  int start_exec = 0;
  int preempted = 0;
  g_startTime = millis();
  
  
  
  while(ready[0] == true || ready[1] == true || ready[2] == true || ready[3] == true)
  { 
    for(int i=0;i<devices;i++)
    { 
      //checkAcceptedQueue(k); //this should be ready queue
      checkReadyQueue(i);
      if(ready[i]==true && hasArrived[i]==true && accepted[i] < inf)
      {
        myPort[i].write('g');
        println("Process "+(i+1)+" is running...");
        start_exec = currentTime();
        
        //delay(1000);
        //println("["+accepted[0]+" "+accepted[1]+" "+accepted[2]+" "+accepted[3] + "],[" + 
        //  holding[0]+" "+holding[1]+" "+holding[2]+" "+holding[3]+"],[" +
        //  ready[0]+" "+ready[1]+" "+ready[2]+" "+ready[3] + "],[" + 
        //  hasArrived[0]+" "+hasArrived[1]+" "+hasArrived[2]+" "+hasArrived[3]+"]");
        while(true)
        {
          delay(1000);
          
          checkHoldingQueue(); //if any procs need to be moved to accepted
          for (int j=0; j<devices; j++){
            checkReadyQueue(j); //for any new processes that come in between
          }
          //INCREMENT THE WAITING TIMES FOR ALL PROCS
          for (int j=0; j<devices; j++){            
            if (ready[j]==true && hasArrived[j]==true) {
              if (accepted[j] < inf) { accepted[j] += accepted_rate; }
              holding[j]  += holding_rate;
            }
          }
          
          String a = myPort[i].readStringUntil('e');
          
          if(a!=null)
          {
          //HANDLE PROCESS FINISHING
            if(a.equals("e"))
            {
              ready[i] = false;
              println("Process "+(i+1)+" has ended.");
              println("Current Time: "+ currentTime());
              preempted = currentTime();
              
              //if there is nothing else on the accepted queue then graduate whatever is next to it
              if (i < devices-1 && accepted[i+1] == inf) {
                accepted[i+1] = holding[i+1];
                holding[i+1] = -inf;
                println("Process "+(i+2)+" has moved from holding to accepted queue.");
              }
              break;
            }
          }
          else if((currentTime() - start_exec) >= timeSlice)
          {
           //HANDLE END OF PROCESS TIMESLICE
            myPort[i].write('s');
            println("Process "+(i+1)+" is Preempted...");
            println("Current Time: "+ currentTime());
            preempted = currentTime();
            break;
          }
        }
        insertTime(i,start_exec,preempted);
      }
      else if (ready[i]==true && hasArrived[i]==true) {
        //println("No processes in accepted queue, incrementing other proc "+(i+1));
          //INCREMENT THE WAITING TIMES FOR ALL PROCS
          for (int j=0; j<devices; j++){            
            if (ready[j]==true && hasArrived[j]==true) {
              if (accepted[j] < inf) { accepted[j] += accepted_rate; }
              holding[j]  += holding_rate;
            }
          }
      }
    } //END OF for(int i=0;i<devices;i++)
    
  }
  /*
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
   println("D Linked List");
   for(int i=0;i<D.size();i++)
   {
     print(D.get(i).start_time+ " ");
     println(D.get(i).end_time);
   }*/
   printTables();
   stopAllConnections();
}
/*************************************
* checkHoldingQueue Function
* checks the holding queue for any processes that should be graduated to accepted queue
* used for SRR method only
/*************************************/
void checkHoldingQueue() {
// Check for procs in holding that have matured to priority of the ones in accepted
// In essence we should only check the largest proc in holding queue, but since we're not sorting it...
  if (accepted[0] == 0) { //then this is the first iteration ever
    holding[0] = -inf;
    println("Process 1 has moved from holding to accepted queue.");
    somethingAccepted = true;
    isAccepted[0] = true;
    return;
  }
  else {
  for (int i = 0; i < devices; i ++){
     if (holding[i] == accepted[0] ||
        holding[i] == accepted[1] ||
        holding[i] == accepted[2] ||
        holding[i] == accepted[3]) { //if it's equal to any of them      
      accepted[i] = holding[i]; //put it in accepted queue
      holding[i] = -inf; //take it out of holding queue
      println("Process "+(i+1)+" has moved from holding to accepted queue.");
      somethingAccepted = true;
      isAccepted[i] = true;
    }
  }
  }
}
/*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*/
//KUHSBU's CODE BELOW
//===================================================================================================
/*************************************************
Global Declarations
*************************************************/
import controlP5.*;
int set = 0 ;
ControlP5 cp5;
int current_process_running = 0;
Textarea myTextarea;
String textValue = "";
int bNumber = 6; 
RectButton [] buttons = new RectButton[bNumber]; 
color[] colors = {#01DFD7, #00FF00}; 
color[] sqr_colors = {#FF0000, #00FF00};
boolean locked = false; 
color rect_color= color(209);
PImage bg;
int y;
float mx;
float my;
float easing = 0.05;
int radius = 24;
int edge = 100;
int inner = edge + radius;
color RR_color= #01DFD7;
color buttonColor= color(0);
int no_processes = 4;
color base = #01DFD7;
color running = 255;
square [] sqr = new square[no_processes]; 

/************************************************
CLASSES HERE
************************************************/
class Button 
{ 
  String Name; 
  int posX, posY; 
  int sizeX; 
  int sizeY; 
  color buttonColor, regColor, highlightColor; 
  boolean over = false; 
  boolean pressed = true; 
  boolean toggle = false; 
  void setName(String Name) {
    this.Name = Name;
  } 
  //void setbuttonColor(color change){this.buttonColor = change;locked=true;} 
  String getName()
  {
    return Name;
  }

  void update() 
  { 
    if (over()) { 
      buttonColor = highlightColor;
    } else { 
      buttonColor = regColor;
    }
  } 
  boolean pressed() 
  { 
    if (over) { 
      locked = true; 
      regColor = highlightColor; 
      return true;
    } else { 
      locked = false; 
      regColor = regColor; 
      return false;
    }
  } 

  boolean over() 
  { 
    return true;
  }
} 

class RectButton extends Button 
{ 
  RectButton(String Name, int posX, int posY, int sizeX, int sizeY, color regColor, color highlightColor) 
  { 
    this.Name = Name; 
    this.posX = posX; 
    this.posY = posY; 
    this.sizeX = sizeX; 
    this.sizeY = sizeY; 
    this.regColor = regColor; 
    this.highlightColor = highlightColor; 
    this.buttonColor = regColor;
  } 
  boolean overRect(int x, int y, int width, int height) 
  { 
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) { 
      return true;
    } else { 
      return false;
    }
  } 
  boolean over() 
  { 
    if ( overRect(posX, posY, sizeX, sizeY) ) { 
      over = true; 
      return true;
    } else { 
      over = false; 
      return false;
    }
  } 

  void display() 
  { 
    stroke(0); 
    fill(buttonColor); 
    rect(posX, posY, sizeX, sizeY, 7); 
    fill(0); 
    textAlign(CENTER); 
    text(Name, posX+sizeX/2, posY+sizeY/2+5);
  }
} 

class square_button 
{ 
  String Name; 
  int posX, posY; 
  int sizeX; 
  int sizeY; 
  color buttonColor, regColor, highlightColor; 
  boolean over = false; 
  boolean pressed = true; 
  boolean toggle = false; 

  void setName(String Name) {
    this.Name = Name;
  } 
  //void setbuttonColor(color change){this.buttonColor = change;locked=true;} 
  String getName()
  {
    return Name;
  }

  void update() 
  { 
    if (over()) { 
      buttonColor = highlightColor;
    } else { 
      buttonColor = regColor;
    }
  } 

  boolean pressed() 
  { 
    if (over) { 
      locked = true; 
      regColor = highlightColor; 
      return true;
    } else { 
      locked = false; 
      regColor = regColor; 
      return false;
    }
  } 

  boolean over() 
  { 
    return true;
  }
} 
class square extends square_button 
{ 
  square(String Name, int posX, int posY, int sizeX, int sizeY, color regColor, color highlightColor) 
  { 
    this.Name = Name; 
    this.posX = posX; 
    this.posY = posY; 
    this.sizeX = sizeX; 
    this.sizeY = sizeY; 
    this.regColor = regColor; 
    this.highlightColor = highlightColor; 
    this.buttonColor = regColor;
  } 
  boolean overRect(int x, int y, int width, int height) 
  { 
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) { 
      return true;
    } else { 
      return false;
    }
  } 
  boolean over() 
  { 
    if ( overRect(posX, posY, sizeX, sizeY) ) { 
      over = true; 
      return true;
    } else { 
      over = false; 
      return false;
    }
  } 

  void display() 
  { 
    stroke(0); 
    fill(buttonColor); 
    rect(posX, posY, sizeX, sizeY, 7); 
    fill(0); 
    textAlign(CENTER); 
    text(Name, posX+sizeX/2, posY+sizeY/2+5);
  }
} 

/********************************************************
setup_items function
********************************************************/
void setup_items()
{
  cp5 = new ControlP5(this);
  PFont font = createFont("arial", 20);
  bg = loadImage("circuit.jpg");
  text("Arrival Time", 120, 70, 0);
  for (int i=0; i<bNumber; i++) { 
    buttons[i] = new RectButton( "t", 150, 300+i*40, 250, 30, colors[0], colors[1]);
  } 
  myTextarea = cp5.addTextarea("txt")
    .setPosition(100, 50)
    .setSize(1150, 200)
    .setFont(createFont("Courier New", 20))
    .setLineHeight(20)
    .setColor(color(0))
    .setColorBackground(color(255, 100))
    .setText("Process   |  Wait Time  |   Response Time  |   Turnaround Time  \n")
    .setColorForeground(color(255, 100));
  ;
  buttons[0].setName("First In First Out"); 
  buttons[1].setName("Shortest Job First"); 
  buttons[2].setName("Shortest Remaining Time First");
  buttons[3].setName("Round Robin");
  buttons[4].setName("Selfish Round Robin");
  buttons[5].setName("Selfish Shortest Remaining Time First");
  buttons[0].regColor = colors[1]; 
  fill(0);
  text("Arrival Time", 150, 50, 0);
  cp5.addTextfield("Process 1")
    .setPosition(550, 300)
    .setSize(200, 40)
    .setFont(font)
    .setFocus(false)
   //.setFont(createFont("arial", 40))
    .setColor(color(255))
    ;
  cp5.addTextfield("Process 2")
    .setPosition(550, 360)
    .setSize(200, 40)
    .setFocus(false)
    .setFont(font)
    .setColor(color(255))
    ;
  cp5.addTextfield("Process 3")
    .setPosition(550, 420)
    .setSize(200, 40)
    .setFocus(false)
    .setFont(font)
    .setColor(color(255))
    ;  
  cp5.addTextfield("Process 4")
    .setPosition(550, 480)
    .setSize(200, 40)
    .setFont(font)
    .setFocus(false)
    .setColor(color(255))
    ;
  cp5.addTextfield("Time Slice")
    .setPosition(950, 300)
    .setSize(200, 40)
    .setFont(font)
    .setFocus(false)
    .setColor(color(255))
    ;
  background(bg);
  fill(76);
}
/********************************************************
setup_squares function
********************************************************/
void setup_squares()
{

  sqr[0] = new square( " ", 770, 300, 40, 40, sqr_colors[0], sqr_colors[1]);
  sqr[1] = new square( " ", 770, 360, 40, 40, sqr_colors[0], sqr_colors[1]);
  sqr[2] = new square( " ", 770, 420, 40, 40, sqr_colors[0], sqr_colors[1]);
  sqr[3] = new square( " ", 770, 480, 40, 40, sqr_colors[0], sqr_colors[1]);
}
/********************************************************
running function
********************************************************/
void running(int p_number)
{
      current_process_running = p_number;
      //sqr[p_number].regColor=sqr_colors[1];
      println("running called");
}

/********************************************************
Update function
********************************************************/

void update(int x, int y) 
{ 
  
  if(current_process_running == 0)
  {
     sqr[0].regColor = sqr_colors[0];   
     sqr[1].regColor = sqr_colors[0];   
     sqr[2].regColor = sqr_colors[0];   
     sqr[3].regColor = sqr_colors[0];   
  }
    
  else if(current_process_running == 1)
  {
     sqr[0].regColor = sqr_colors[1];   
     sqr[1].regColor = sqr_colors[0];   
     sqr[2].regColor = sqr_colors[0];   
     sqr[3].regColor = sqr_colors[0];  
   }
  else if(current_process_running == 2)
  {
     sqr[0].regColor = sqr_colors[0];   
     sqr[1].regColor = sqr_colors[1];   
     sqr[2].regColor = sqr_colors[0];   
     sqr[3].regColor = sqr_colors[0];   
  }
  else if(current_process_running == 3)
  {
    sqr[0].regColor = sqr_colors[0];   
     sqr[1].regColor = sqr_colors[0];   
     sqr[2].regColor = sqr_colors[1];   
     sqr[3].regColor = sqr_colors[0];   
  }
  else if(current_process_running == 4)
  {
    sqr[0].regColor = sqr_colors[0];   
     sqr[1].regColor = sqr_colors[0];   
     sqr[2].regColor = sqr_colors[0];   
     sqr[3].regColor = sqr_colors[1];   
  }
  
  if (locked == false) 
  { 
    for (int i=0; i<bNumber; i++)
    { 
      buttons[i].update();
    }
    for (int i=0; i<no_processes; i++) 
    { 
      sqr[i].update();
    }
    
  } 
  else
  { 
    locked = false;
  } 
  if (mousePressed)
  {   
    for(int j=0; j< no_processes ; j++)
    {
     if (sqr[j].pressed())
     { 
       sqr[j].regColor = sqr_colors[1];   
       //println("button pressed" + j);
     }
     else 
     { 
        sqr[j].regColor = sqr_colors[0];
        //println("square elase part");
     }
    }
    //Print Table Heading
    
    for (int i=0; i<bNumber; i++) 
    { 
      
      if (buttons[i].pressed()) 
      { 
       // buttons[i].regColor = colors[1]; 
        String myText=buttons[i].getName();
        
        //myTextarea.append("Algorithm                     Wait Time  |   Response Time  |   Turnaround Time  \n");
        myTextarea.append(myText);
        myTextarea.append("\n");
        String[] value = {"","","",""};
        value[0] = cp5.get(Textfield.class, "Process 1").getText();
        value[1] = cp5.get(Textfield.class, "Process 2").getText();
        value[2] = cp5.get(Textfield.class, "Process 3").getText();
        value[3] = cp5.get(Textfield.class, "Process 4").getText();
        String time_slice = cp5.get(Textfield.class, "Time Slice").getText();
        if(i==0 || i==1||i==2)
        {
          time_slice = "0";
        }
        else if(time_slice.equals(""))
        {
          time_slice = "2";
        }
        
        
        for(int m=0;m<4;m++)
        {
          if(value[m].equals("")) value[m] = "1000";
          arrival[m] = Integer.parseInt(value[m]);
          if(arrival[m] == -1) arrival[m] = 0;
        }
        
        button_caller(i,Integer.parseInt(time_slice));
        
      } 
      else 
      { 
        buttons[i].regColor = colors[0];
      }
    }
  }
} 

/*****************************************
Button Caller
*****************************************/
void button_caller(int k,int timeSlice)
{
  if(k==0)
  {
   
    fifo();
  }
  else if(k==1)
  {
   
    shortestJobFirst();
  }
  else if(k==2)
  {
    
    shortestRemainingTimeFirst();
  }
  else if(k==3)
  {
    
    roundRobin(timeSlice);
  }
  else if(k==4)
  {
    
    selfishRoundRobin(timeSlice);
  }
  else if(k==5)
  {
        selfishShortestRemainingTimeFirst();
  }

}

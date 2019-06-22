import processing.sound.*;

import themidibus.*; //Import the library
import java.util.Map;

SoundFile playerMovement;
SoundFile getKey;
SoundFile playerIsDead;

MidiBus myBus; // The MidiBus

int[][] labyrinth = {
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, 
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 1, 1, 1, 1, 0, 1, 1, 0, 1}, 
  {1, 0, 0, 0, 0, 0, 1, 0, 0, 1}, 
  {1, 0, 1, 0, 1, 1, 1, 0, 1, 1}, 
  {1, 0, 1, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 0, 1, 1, 0, 1, 1, 1, 0, 1}, 
  {1, 0, 1, 0, 0, 0, 1, 0, 0, 1}, 
  {1, 0, 1, 0, 1, 0, 0, 0, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
};


Graph graph = new Graph();

int[] keyPosition = {0, 0};
int[] exitPosition = {6, 7};
boolean hasKey = false;
boolean playerDeath = false;
int[] cursorPosition = {2, 7};
int[] monsterPosition = {0, 7};
long lastMove = 0;
ArrayList<Node> path = new ArrayList<Node>();
void setup() {
  
  size (400, 400);
  background (255);
  playerIsDead = new SoundFile(this,"Take_Damage.wav");
  
  size (400, 400);
  background (255);
  getKey = new SoundFile(this,"Key_Pick.wav");
  
  size (400, 400);
  background (255);
  playerMovement = new SoundFile(this,"Cursor_Move.wav");
  playerMovement.amp(0.4);
  
  size(400, 400);
  background(0);

  for (int i=0; i < 10; i++) {
    for (int j=0; j < 10; j++) {
      if (labyrinth[i][j] == 0) {
        Node n = graph.graph.get(10*i+j);
        if (n == null) {
          n = graph.addNode(j, i);
        }
      }
    }
  }
  
  //Get Neighbors
  for (Map.Entry me : graph.graph.entrySet()) {
    Node n = (Node)me.getValue();
    checkNeighbors(n);   
  }
  
  //for (Map.Entry me : graph.graph.entrySet()) {
  //  Node n = (Node)me.getValue();
  //  print(n.x);
  //  print(n.y);
  //  println(": ");
  //  print("\t");
  //  for (int i=0; i< n.edges.size(); i++) {
  //    print(n.edges.get(i).x);
  //    print(n.edges.get(i).y);
  //    print(", ");
  //  }
  //  println();
  //}

  final String OS = platformNames[platform];

  //MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  String[] inputs = MidiBus.availableInputs();
  String[] outputs = MidiBus.availableOutputs();

  String input = "Standalone Port";
  String output = "Standalone Port";
  String selInput = null;
  String selOutput = null;
  if (OS == "windows") {
    input = "MIDIIN2 (Launchpad Pro)";
    output = "MIDIOUT2 (Launchpad Pro)";
  } 
  for (int i = 0; i < inputs.length; i++) {
    if (inputs[i] == input) selInput = input;
  }
  for (int i = 0; i < outputs.length; i++) {
    if (outputs[i] == output) selOutput = output;
  }

  //if (selInput == null && selOutput == null) {
  //  myBus = new MidiBus(this, -1, -1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  //} else {
  myBus = new MidiBus(this, input, output); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  //}
  findPathToUser();
}

void draw() {
  int channel = 0;
  int pitch = 81;
  int velocity = 127;
  for (int i=0; i < 10; i++) {
    for (int j=0; j < 10; j++) {
      int position = 10*(9-i)+j;
      if ((position != xyToNote(cursorPosition[0], cursorPosition[1]) && 
          position != xyToNote(monsterPosition[0], monsterPosition[1]) &&
          position != xyToNote(keyPosition [0], keyPosition [1])) ||
          ((position == xyToNote(keyPosition[0], keyPosition[1])) && hasKey) ||
          ((position == xyToNote(exitPosition[0], exitPosition[1])) && !hasKey)||
          ((position != xyToNote(monsterPosition[0], monsterPosition[1]) && playerDeath)||
          (( position == xyToNote(monsterPosition [0], monsterPosition[1]) && !playerDeath)
          )))
         
          {
        if (labyrinth[i][j]==0) {
          myBus.sendNoteOn(0, position, 0); // Send a Midi noteOn
          fill(0, 0, 0);
        } else {
          fill(255, 255, 255);
          myBus.sendNoteOn(0, position, 3); // Send a Midi noteOn
        }
        rect(j*40, i*40, 40, 40);
      }
    }
  }

  showCursor();
  showMonster();
  
 if (!hasKey) showKey();
  if (!hasKey && cursorPosition[0] == keyPosition[0] && cursorPosition[1] == keyPosition[1]) {
    hasKey = true;
    getKey.amp(0.3);
    getKey.play();
  }
  if (hasKey) showExit();
   delay(50);
  if (millis() - lastMove > 350) {
    moveMonster();
    lastMove = millis();
    //println(dist(monsterPosition[0], monsterPosition[1], cursorPosition[0], cursorPosition[1]));
  }
  
    if (!playerDeath && monsterPosition [0] == cursorPosition[0] && monsterPosition[1] == cursorPosition[1]) {
   playerDeath = true;
   playerIsDead.play();
   playerIsDead.amp(0.3);
   Restart();
   //println("Death is Iminnent");
   
  }
  
   }

void Restart(){
  cursorPosition [0] = 2;
  cursorPosition [1] = 7;
  monsterPosition [0] = 0;
  monsterPosition [1] = 7;
  keyPosition [0] = 0;
  keyPosition [1] = 0;
  playerDeath = false;
  hasKey = false;
  
  println("Death is Iminnent");
 
}

void showExit() {
  myBus.sendNoteOn(0, xyToNote(exitPosition[0], exitPosition[1]), 17); // Send a Midi noteOn
  fill(10, 128, 40);
  circle(60+exitPosition[0]*40, 60+exitPosition[1]*40, 40);
}

void findPathToUser() {
  graph.clear();
  Node e = graph.graph.get(10*(monsterPosition[1]+1)+monsterPosition[0]+1);
  Node s = graph.graph.get(10*(cursorPosition[1]+1)+cursorPosition[0]+1);
  graph.setStart(s);
  graph.setEnd(e);
  bfs();
}

void bfs() {
  ArrayList<Node> queue = new ArrayList<Node>();
  path = new ArrayList<Node>();
  queue.add(graph.start);
  
  
  while (queue.size() > 0) {
    Node node = queue.get(0);
    if (node == graph.end) {
      path.add(node);
      Node next = node.parent;
      while (next != null) {
        path.add(next);
        next = next.parent;
      }
      break;
    } else {
      ArrayList<Node> next = node.edges;
      for (Node neighbor : next) {
        if (!neighbor.searched) {
          queue.add(neighbor);
          neighbor.parent = node;
        }
      }
      node.searched = true;
    }
  queue.remove(0);
  }
  
  for (Node segment : path) {
    if (segment != null) {
      print(segment.x);
      print(segment.y);
      if (segment.parent != null) print("-->");
    }
  }
  println("DONE");
  
}

void checkNeighbors(Node n) {
  int xPos = n.x+1;
  int yPos = n.y;
   if (xPos <=8 && labyrinth[yPos][xPos] == 0) {
     connectNeighbor(n, xPos, yPos);
   }
  xPos = n.x-1;
  yPos = n.y;
   if (xPos >=0 && labyrinth[yPos][xPos] == 0) {
     connectNeighbor(n, xPos, yPos);
   }
  xPos = n.x;
  yPos = n.y+1;
   if (yPos <=8 && labyrinth[yPos][xPos] == 0) {
     connectNeighbor(n, xPos, yPos);
   }
   
  xPos = n.x;
  yPos = n.y-1;
   if (yPos >= 0 && labyrinth[yPos][xPos] == 0) {
     connectNeighbor(n, xPos, yPos);
   }
}

void connectNeighbor(Node n, int xPos, int yPos) {
   Node neighbor = graph.graph.get(10*yPos+xPos);
   n.connect(neighbor);
}

void showCursor() {
  myBus.sendNoteOn(0, xyToNote(cursorPosition[0], cursorPosition[1]), 5); // Send a Midi noteOn
  fill(128, 0, 220);
  circle(60+cursorPosition[0]*40, 60+cursorPosition[1]*40, 40);
}

void showMonster() {
  myBus.sendNoteOn(0, xyToNote(monsterPosition[0], monsterPosition[1]), 50); // Send a Midi noteOn
  fill(125, 0, 0);
  circle(60+monsterPosition[0]*40, 60+monsterPosition[1]*40, 40);
}

void showKey(){
  myBus.sendNoteOn(0, xyToNote(keyPosition[0],keyPosition[1]), 15); // Send a Midi noteOn
  fill(130, 110, 0);
  circle(60+keyPosition[0]*40, 60+keyPosition[1]*40, 40);
}

void moveMonster() {
  if (path.size() > 1) {
    monsterPosition[0] = path.get(1).x-1;
    monsterPosition[1] = path.get(1).y-1;
    path.remove(0);
  }
}


int xyToNote(int x, int y) {
  return 10*(8-y)+x+1;
}


void keyPressed() {
  int keyIndex = -1;
  if (key == 'A' || key == 'a') {
    moveLeft();
  } else if (key == 'D' || key == 'd') {
    moveRight();
  } else if (key == 'W' || key == 'w') {
    moveUp();
  } else if (key == 'S' || key == 's') {
    moveDown();
  }
}

void moveLeft() {
  if (cursorPosition[0]>0 && !checkCollision(cursorPosition[0]-1, cursorPosition[1])) 
  {
    cursorPosition[0]--;
    findPathToUser();
    playerMovement.play();
    playerMovement.rate(random(0.8, 1.3));
  }
}

void moveRight() {
  if (cursorPosition[0]<7  && !checkCollision(cursorPosition[0]+1, cursorPosition[1])) {
    cursorPosition[0]++;
    findPathToUser();
    playerMovement.play();
    playerMovement.rate(random(0.8, 1.3));
  }
}

void moveUp() {
  if (cursorPosition[1]>0  && !checkCollision(cursorPosition[0], cursorPosition[1]-1)) {
    cursorPosition[1]--;
    findPathToUser();
    playerMovement.play();
    playerMovement.rate(random(0.8, 1.3));
  }
}

void moveDown() {
  if (cursorPosition[1]<7  && !checkCollision(cursorPosition[0], cursorPosition[1]+1)) {
    cursorPosition[1]++;
    findPathToUser();
    playerMovement.play();
    playerMovement.rate(random(0.8, 1.3));
  }
}

boolean checkCollision(int x, int y) {
  if (labyrinth[y+1][x+1] == 1) return true;
  return false;
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  int x = pitch%10;
  int y = 90-(pitch-x);
  Node n = graph.graph.get(y+x);
  if (n != null) {
    print(n.x);
    print(n.y);
    println();
    print("neighbors: ");
    for (int i=0; i< n.edges.size(); i++) {
      print(n.edges.get(i).x);
      print(n.edges.get(i).y);
      print(", ");
    }
    
  }

}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
  if (number == 91 && value == 127) moveUp();
  if (number == 92 && value == 127) moveDown();
  if (number == 93 && value == 127) moveLeft();
  if (number == 94 && value == 127) moveRight();
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

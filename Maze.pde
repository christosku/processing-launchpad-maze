import themidibus.*; //Import the library
import game2dai.entities.*;
import game2dai.entityshapes.ps.*;
import game2dai.maths.*;
import game2dai.*;
import game2dai.entityshapes.*;
import game2dai.fsm.*;
import game2dai.steering.*;
import game2dai.utils.*;
import game2dai.graph.*;

MidiBus myBus; // The MidiBus

int[][] labyrinth = {
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 1, 1, 1, 1, 0, 1, 1, 0, 1}, 
  {1, 0, 0, 0, 0, 0, 1, 0, 0, 1}, 
  {1, 0, 1, 0, 1, 1, 1, 0, 1, 1}, 
  {1, 0, 1, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 0, 1, 1, 1, 1, 1, 1, 0, 1}, 
  {1, 0, 1, 0, 0, 0, 1, 0, 0, 1}, 
  {1, 0, 1, 0, 1, 0, 0, 0, 1, 1}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 0}
};

int[] cursorPosition = {0, 0};
int[] monsterPosition = {0, 7};
long lastMove = 0;
void setup() {
  size(400, 400);
  background(0);
  
  final String OS = platformNames[platform];

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  // Either you can
  //                   Parent In Out
  //                     |    |  |
  //myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

  // or you can ...
  //                   Parent         In                   Out
  //                     |            |                     |
  //myBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.

  // or for testing you could ...
  //                 Parent  In        Out
  //      |     |          |
  if (OS == "windows") {
    myBus = new MidiBus(this, "MIDIIN2 (Launchpad Pro)", "MIDIOUT2 (Launchpad Pro)"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  } else {
    myBus = new MidiBus(this, "Standalone Port", "Standalone Port"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  }
}

void draw() {
  int channel = 0;
  int pitch = 81;
  int velocity = 127;
  for (int i=0; i < 10; i++) {
    for (int j=0; j < 10; j++) {
      int position = 10*(9-i)+j;
      if (position != xyToNote(cursorPosition[0], cursorPosition[1]) && position != xyToNote(monsterPosition[0], monsterPosition[1])) {
        if (labyrinth[i][j]==0) {
          myBus.sendNoteOn(0, position, 0); // Send a Midi noteOn
        } else {
          myBus.sendNoteOn(0, position, 3); // Send a Midi noteOn
        }
      }
    }
  }

  showCursor();
  showMonster();
  delay(50);
  if (millis() - lastMove > 500) {
    moveMonster();
    lastMove = millis();
    //println(dist(monsterPosition[0], monsterPosition[1], cursorPosition[0], cursorPosition[1]));
  }
}

void showCursor() {
  myBus.sendNoteOn(0, xyToNote(cursorPosition[0], cursorPosition[1]), 5); // Send a Midi noteOn
}

void showMonster() {
  myBus.sendNoteOn(0, xyToNote(monsterPosition[0], monsterPosition[1]), 50); // Send a Midi noteOn
}

void moveMonster() {
  if (monsterPosition[0] < cursorPosition[0] && !checkCollision(monsterPosition[0]+1, monsterPosition[1])) {
    monsterPosition[0]++;
  } else if (monsterPosition[0] > cursorPosition[0] && !checkCollision(monsterPosition[0]-1, monsterPosition[1])) {
    monsterPosition[0]--;
  } else if (monsterPosition[1] < cursorPosition[1] && !checkCollision(monsterPosition[0], monsterPosition[1]+1)) {
    monsterPosition[1]++;
  } else if (monsterPosition[1] > cursorPosition[1] && !checkCollision(monsterPosition[0], monsterPosition[1]-1)) {
    monsterPosition[1]--;
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
  if (cursorPosition[0]>0 && !checkCollision(cursorPosition[0]-1, cursorPosition[1])) cursorPosition[0]--;
}

void moveRight() {
  if (cursorPosition[0]<7  && !checkCollision(cursorPosition[0]+1, cursorPosition[1])) cursorPosition[0]++;
}

void moveUp() {
  if (cursorPosition[1]>0  && !checkCollision(cursorPosition[0], cursorPosition[1]-1)) cursorPosition[1]--;
}

void moveDown() {
  if (cursorPosition[1]<7  && !checkCollision(cursorPosition[0], cursorPosition[1]+1)) cursorPosition[1]++;
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

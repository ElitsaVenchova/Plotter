#include <Servo.h>

// defines pins numbers - Width
const int stepPinX = 12;
const int dirPinX = 11;
// defines pins numbers - Height
const int stepPinY = 9;
const int dirPinY = 8;
//pen pin
const int penPin = 3;

//Числови стойности, които ще се подават за задаване на действие
const int DIR_UP = 0;
const int DIR_UP_RIGHT = 1;
const int DIR_RIGHT = 2;
const int DIR_DOWN_RIGHT = 3;
const int DIR_DOWN = 4;
const int DIR_DOWN_LEFT = 5;
const int DIR_LEFT = 6;
const int DIR_UP_LEFT = 7;

const int PEN_UP = 8;
const int PEN_DOWN = 9;

const int END = 10; //Край. Тогава всичко трябва да се върне в начална позиция

//Размери на плотера
const int MAX_X = 200 * 11 + 50;
const int MAX_Y = 200 * 9;

//Горна и долна позиция на сервото
const int PEN_UP_POS = 160;
const int PEN_DOWN_POS = 135;

int currentX = 0, currentY = 0; //текуща позиция по X и Y
int posX = 0, posY = 0; //текуща позиция по X и Y
bool isPenUp = false; //Позицията на химикалката
bool isPrevPenUp = true;
Servo myservo;//Управлението на химикалката

void setup() {
  //Инициализиране на химикалката
  myservo.attach(penPin);
  //movePen(PEN_UP);

  // Sets the two pins as Outputs - Width
  pinMode(stepPinX, OUTPUT);
  pinMode(dirPinX, OUTPUT);
  // Sets the two pins as Outputs - Height
  pinMode(stepPinY, OUTPUT);
  pinMode(dirPinY, OUTPUT);

  digitalWrite(stepPinX, LOW);
  digitalWrite(stepPinY, LOW);
  digitalWrite(dirPinX, LOW);
  digitalWrite(dirPinY, LOW);

  Serial.begin(9600);//Отваряне серийна комуникация за получаване на пикселите на изображението
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  establishContact();  // send a byte to establish contact until receiver responds
}

void loop() {
  if ( Serial.available() )
  {
    int val = readData();//Прочитане на стойност
    if (val == PEN_UP) { //Вдигане на химикалката
      movePen(PEN_UP);
      Serial.println("ok");
      //Прочитане на новата позиция (x,y)
      int x = -1, y = -1;
      while (x != -1) { //Прочитане на X
        x =  readData();
      }
      Serial.println("ok");
      while (y != -1) {//Прочитане на Y
        y = readData();
      }
      move(x, y); //Преместване на позиция (x,y)
    } else if (val == PEN_DOWN) { //Сваляне на химикалката
      movePen(PEN_DOWN);
    } else if (val == END) { //Край на изображението
      movePen(PEN_UP);
      move(0, 0);
    } else { //Получаваме код на Фрийман
      move(val);
    }
  }
  Serial.println("ok");
  delay(10);
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}

int readData(){
  int res;
  int c;
  int v=0;
  
      Serial.println("before read");
  while (Serial.available()) {
    c = Serial.read();
    
    // handle digits
    if ((c >= '0') && (c <= '9')) {
      v = 10 * v + c - '0';
    }
    // handle delimiter
    else if (c == 'e') {
      res = v;
      v = 0;
    }
  }
  Serial.println(res);
  return res;
}

//Управление на химикалката
void movePen(int dir) {
  if (!isPenUp && dir == PEN_UP) {
    Serial.println("up");
    for (int pos = PEN_DOWN_POS; pos <= PEN_UP_POS; pos += 1) { // goes from 135 degrees to 180 degrees
      // in steps of 1 degree
      myservo.write(pos);
      delay(15);
    }
    isPenUp = true;
  } else if (isPenUp && dir == PEN_DOWN) {
    Serial.println("down");
    for (int pos = PEN_UP_POS; pos >= PEN_DOWN_POS; pos -= 1) { // goes from 180 degrees to 135 degrees
      // in steps of 1 degree
      myservo.write(pos);
      delay(70);
    }
    isPenUp = false;
  }
}

//Преместване на химикалката на определена позиция (x,y)
void move(int x, int y) {
  Serial.println(posX);
  Serial.println(posY);
  Serial.println(x);
  Serial.println(y);
  while (x != posX || y != posY) {
    if (x - currentX > 0) {
      moveStepX(LOW);
      posX--;
    } else if (x - posX < 0) {
      moveStepX(HIGH);
      posX++;
    }

    if (y - posY > 0) {
      moveStepY(LOW);
      posY--;
    } else if (y - posY < 0) {
      moveStepY(HIGH);
      posY++;
    }
  }
}

//Преместване на позията по зададения код на Фрийман
void move(int freemanCode) {
  if (freemanCode == DIR_UP) {
    moveStepX(HIGH);
  } else if (freemanCode == DIR_UP_RIGHT) {
    moveStepX(HIGH);
    moveStepY(HIGH);
  } else if (freemanCode == DIR_RIGHT) {
    moveStepY(HIGH);
  } else if (freemanCode == DIR_DOWN_RIGHT) {
    moveStepX(LOW);
    moveStepY(HIGH);
  } else if (freemanCode == DIR_DOWN) {
    moveStepX(LOW);
  } else if (freemanCode == DIR_DOWN_LEFT) {
    moveStepX(LOW);
    moveStepY(LOW);
  } else if (freemanCode == DIR_LEFT) {
    moveStepY(LOW);
  } else if (freemanCode == DIR_UP_LEFT) {
    moveStepX(HIGH);
    moveStepY(LOW);
  }
}

//Правене на стъпка по X и по Y.
//В отделни фуции са, защото може да се окаже, че една стъпка ще бъде повече от 1 оборот
void moveStepX(int dir) {
  int lenght = 0;
  if(currentX >= MAX_X){
    lenght = -1;
  } else if (!isPrevPenUp) {
    if (!isPenUp) { lenght = 40;
    } else { lenght = 60; }
  } else {
    if (!isPenUp) { lenght = -1;
    } else { lenght = 30; }
  }

  digitalWrite(dirPinX, dir);//задавае на посоката
  for (int x = 0; x < lenght; x++) {
    digitalWrite(stepPinX, HIGH);
    delayMicroseconds(500);
    digitalWrite(stepPinX, LOW);
    delay(20);                       // wait for a second
    currentX++;
  }
  isPrevPenUp = isPenUp;
  delay(20);
}
void moveStepY(int dir) {
  int lenght = 0;
  if(currentY >= MAX_Y){
    lenght = -1;
  } else if (!isPrevPenUp) {
    if (!isPenUp) { lenght = 40;
    } else { lenght = 60; }
  } else {
    if (!isPenUp) { lenght = -1;
    } else { lenght = 30; }
  }

  digitalWrite(dirPinY, dir);//задавае на посоката
  for (int x = 0; x < lenght; x++) {
    digitalWrite(stepPinY, HIGH);
    delayMicroseconds(500);
    digitalWrite(stepPinY, LOW);
    delay(20);                       // wait for a second
    currentY++;
  }
  isPrevPenUp = isPenUp;
  delay(20);
}

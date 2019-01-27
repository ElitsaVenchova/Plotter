#include <Servo.h>

// defines pins numbers - Width
const int stepPinX = 2;
const int dirPinX = 3;
// defines pins numbers - Height
const int stepPinY = 9;
const int dirPinY = 8;
//pen pin
const int penPin = 3;

//Числови стойности, които ще се подават за задаване на действие
const int PEN_UP = -1;
const int PEN_DOWN = -2;

const int DIR_UP = 0;
const int DIR_UP_RIGHT = 1;
const int DIR_RIGHT = 2;
const int DIR_DOWN_RIGHT = 3;
const int DIR_DOWN = 4;
const int DIR_DOWN_LEFT = 5;
const int DIR_LEFT = 6;
const int DIR_UP_LEFT = 7;

const int END = 8; //Край. Тогава всичко трябва да се върне в начална позиция

//Размери на плотера
const int MAX_X = 200 * 11 + 50;
const int MAX_Y = 200 * 9;

//Горна и долна позиция на сервото
const int PEN_UP_POS = 180;
const int PEN_DOWN_POS = 135;

int currentX = 0, currentY = 0; //текуща позиция по X и Y
bool isPenUp = true; //Позицията на химикалката
Servo myservo;//Управлението на химикалката

void setup() {
  //Инициализиране на химикалката
  myservo.attach(penPin);
  movePen(PEN_UP);

  Serial.begin(9600);//Отваряне серийна комуникация за получаване на пикселите на изображението

  // Sets the two pins as Outputs - Width
  pinMode(stepPinX, OUTPUT);
  pinMode(dirPinX, OUTPUT);
  // Sets the two pins as Outputs - Height
  pinMode(stepPinY, OUTPUT);
  pinMode(dirPinY, OUTPUT);
}

void loop() {
  if ( Serial.available() )
  {
    int val =  Serial.read();//Прочитане на стойност
    if (val == PEN_UP) { //Вдигане на химикалката
      movePen(PEN_UP);
      //Прочитане на новата позиция (x,y)
      int x = -1, y = -1;
      while (x != -1) { //Прочитане на X
        if ( Serial.available() ) {
          x =  Serial.read();
        }
      }
      while (y != -1) {//Прочитане на Y
        if ( Serial.available() ) {
          y =  Serial.read();
        }
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
  delay(10);
}

//Управление на химикалката
void movePen(int dir) {
  if (!isPenUp && dir == PEN_UP) {
    for (int pos = PEN_DOWN_POS; pos <= PEN_UP_POS; pos += 1) { // goes from 135 degrees to 180 degrees
      // in steps of 1 degree
      myservo.write(pos);
      delay(15);
    }
    isPenUp = true;
  } else if (isPenUp && dir == PEN_DOWN) {
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
  while (x != currentX && y != currentY) {
    if (x - currentX > 0) {
      moveStepX(LOW);
    } else if (x - currentX < 0) {
      moveStepX(HIGH);
    }

    if (y - currentY > 0) {
      moveStepY(LOW);
    } else if (y - currentY < 0) {
      moveStepY(HIGH);
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
    digitalWrite(dirPinX, dir);//задавае на посоката
  if (!isPenUp) {//
    digitalWrite(stepPinX, HIGH);
    delayMicroseconds(500);
    digitalWrite(stepPinX, LOW);
    delay(20);
    currentX ++;
  } else {
    for (int x = 0; x < 60; x++) {
      digitalWrite(stepPinX, HIGH);
      delayMicroseconds(500);
      digitalWrite(stepPinX, LOW);
      delay(20);      
    }
  }
}
void moveStepY(int dir) {
  digitalWrite(dirPinY, dir);
  digitalWrite(stepPinY, HIGH);
  delayMicroseconds(500);
  digitalWrite(stepPinY, LOW);
  delay(20);
  currentY++;
}

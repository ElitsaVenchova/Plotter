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

const int PEN_SHIFT = 8;

const int END = 9; //Край. Тогава всичко трябва да се върне в начална позиция

//Размери на плотера
const int MAX_X = 200 * 11 + 50;
const int MAX_Y = 200 * 9;

//Горна и долна позиция на сервото
const int PEN_UP_POS = 160;
const int PEN_DOWN_POS = 135;

int currentX = 0, currentY = 0; //текуща позиция по X и Y
bool isPenUp = false; //Позицията на химикалката
bool isPrevPenUp = true;
Servo penServo;//Управлението на химикалката

void setup() {
  //Инициализиране на химикалката
  penServo.attach(penPin);
  movePen();

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
    if (val == PEN_SHIFT) { //Вдигане на химикалката
      movePen();
    } else if (val == END) { //Край на изображението
      Serial.println("END");
    } else { //Получаваме код на Фрийман
      move(val);
    }
    Serial.println("ok");
  }
  delay(10);
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}

int readData() {
  int res;
  int c;
  int v = -1;
  int isDelimRead = false;

  while (!isDelimRead) {
    while (Serial.available()) {
      c = Serial.read();

      // handle digits
      if ((c >= '0') && (c <= '9')) {
        if (v == -1) {
          v = 0;
        }
        v = 10 * v + c - '0';
      }
      // handle delimiter
      else if (c == 'e' && v != -1) {
        res = v;
        v = -1;
        isDelimRead = true;
        break;
      }
    }
  }
  Serial.println(res);
  return res;
}

//Управление на химикалката
void movePen() {
  if (!isPenUp) {
    int currPos = penServo.read();
    Serial.print("up-");
    Serial.println(currPos);
    for (int pos = currPos; pos <= PEN_UP_POS; pos += 1) { // goes from 135 degrees to 180 degrees
      // in steps of 1 degree
      penServo.write(pos);
      delay(15);
    }
    isPenUp = true;
  } else if (isPenUp) {
    int currPos = penServo.read();
    Serial.print("down-");
    Serial.println(currPos);
    for (int pos = PEN_UP_POS; pos >= PEN_DOWN_POS; pos -= 1) { // goes from 180 degrees to 135 degrees
      // in steps of 1 degree
      penServo.write(pos);
      delay(70);
    }
    isPenUp = false;
  }
}

//Преместване на позията по зададения код на Фрийман
void move(int freemanCode) {
  if (freemanCode == DIR_UP) {
    moveStep(LOW, -1);
  } else if (freemanCode == DIR_UP_RIGHT) {
    moveStep(LOW, HIGH);
  } else if (freemanCode == DIR_RIGHT) {
    moveStep(-1, HIGH);
  } else if (freemanCode == DIR_DOWN_RIGHT) {
    moveStep(HIGH, HIGH);
  } else if (freemanCode == DIR_DOWN) {
    moveStep(HIGH, -1);
  } else if (freemanCode == DIR_DOWN_LEFT) {
    moveStep(HIGH, LOW);
  } else if (freemanCode == DIR_LEFT) {
    moveStep(-1, LOW);
  } else if (freemanCode == DIR_UP_LEFT) {
    moveStep(LOW, LOW);
  }
}

void moveStep(int dirX, int dirY) {
  int lenght = 0;
  if (!isPrevPenUp) {
    if (!isPenUp) {
      lenght = 40;
    } else {
      lenght = 40;
    }
  } else {
    if (!isPenUp) {
      lenght = -1;
    } else {
      lenght = 40;
    }
  }

  boolean isXOk = true, isYOk = true;

  digitalWrite(dirPinX, dirX);//задавае на посоката
  digitalWrite(dirPinY, dirY);//задавае на посоката
  for (int x = 0; x < lenght; x++) {
    if ((currentX > 0 && dirX == LOW) || (currentX < MAX_X && dirX == HIGH)) {
      digitalWrite(stepPinX, HIGH);
      delayMicroseconds(500);
      digitalWrite(stepPinX, LOW);
      delay(20);
      if (dirX == HIGH) {
        currentX++;
      } else {
        currentX--;
      }
    } else if (dirX != -1 && isXOk) {
      Serial.println("X --> -1");
      isXOk = false;
    }

    if ((currentY > 0 && dirY == LOW) || (currentY < MAX_Y && dirY == HIGH)) {
      digitalWrite(stepPinY, HIGH);
      delayMicroseconds(500);
      digitalWrite(stepPinY, LOW);
      delay(20);
      if (dirY == HIGH) {
        currentY++;
      } else {
        currentY--;
      }
    } else if (dirY != -1 && isYOk) {
      Serial.println("Y --> -1");
      isYOk = false;
    }
  }
  isPrevPenUp = isPenUp;
  delay(20);
}

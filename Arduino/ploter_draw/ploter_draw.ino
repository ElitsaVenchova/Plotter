#include <Servo.h> 

Servo myservo;

int led;

// defines pins numbers - Width
const int stepPinWidth = 2; 
const int dirPinWidth = 3; 

// defines pins numbers - Height
const int stepPinHeight = 4; 
const int dirPinHeight = 5; 

void setup(){
  // Връшане на сервото в начална позиция
  myservo.attach(9);
  int a = myservo.read(); //вземане на текущата позиция
  myservo.write(-a);  // set servo to init pos

 pinMode(13, OUTPUT);

 Serial.begin(9600);//Отваряне серийна комуникация за получаване на пикселите на изображението
 
  // Sets the two pins as Outputs - Width
  pinMode(stepPinWidth,OUTPUT); 
  pinMode(dirPinWidth,OUTPUT);

  // Sets the two pins as Outputs - Height
  pinMode(stepPinHeight,OUTPUT); 
  pinMode(dirPinHeight,OUTPUT);
}

void loop(){

  digitalWrite(dirPin,HIGH); // Enables the motor to move in a particular direction
  // Makes 200 pulses for making one full cycle rotation
  for(int x = 0; x < 200; x++) {
    digitalWrite(stepPin,HIGH); 
    delayMicroseconds(500); 
    digitalWrite(stepPin,LOW); 
    delayMicroseconds(500); 
  }
  delay(1000); // One second delay
  
  digitalWrite(dirPin,LOW); //Changes the rotations direction
  // Makes 400 pulses for making two full cycle rotation
  for(int x = 0; x < 400; x++) {
    digitalWrite(stepPin,HIGH);
    delayMicroseconds(500);
    digitalWrite(stepPin,LOW);
    delayMicroseconds(500);
  }
  delay(1000);
  

if( Serial.available() )
 { 
 led =  Serial.read(); 
 
  if(led == 13){
    Serial.print("YES");
    digitalWrite (13, HIGH);
  } else {
    digitalWrite (13, LOW);
  }
 }   
 delay(10);  
}

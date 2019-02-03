//серийна комуникация с Ардуиното
Serial port;
String portname = "COM3";  
int baudrate = 9600;
int plot_width=(200 * 11 + 50)/40, plot_height=(200 * 9)/40;//56/45

boolean hasArduino = true; //Флаг дали има свързано Ардуно

//################################################################Arduino

//Започване на серийна комуникация с Ардуиното
void connectToArdiono() {
  if (hasArduino) {//Започваме комуникацията само ако е зададено, че има свързано Ардуино
    port = new Serial(this, portname, baudrate);//Инициализиране на порта за серийнна комуникация
    println(port); //Отпечатване на порта
  }
}

//Изпращане на стойност на Arduino
void sendArdiuno(int val) {
  println(val);
  if (hasArduino) {
    port.write(Integer.toString(val));
    port.write('e');
    delay(2000);
    waitOK();
  }
}

void waitOK() {
  try {
    while (port.available() > 0) {
      String message = port.readStringUntil(13);
      if (message != null) {
        println("message received: "+trim(message));
      }
      if ("ok".equals(trim(message))) {
        break;
      }
    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

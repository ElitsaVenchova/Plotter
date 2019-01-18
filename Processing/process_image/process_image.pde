import gab.opencv.*;
import processing.serial.*;

//серийна комуникация с Ардуиното
Serial port;
String portname = "COM3";  
int baudrate = 9600;
int plot_width=1000, plot_height=2500;

//Изображението
OpenCV opencv;
PImage  img, adaptive;
String imgPath = "../data/test6.jpg";

boolean hasArduino = false; //Флаг дали има свързано Ардуно

void setup() {
  connectToArdiono();//свързване към ардуното
  processImage(); //обработка на изображението

  size(1080, 720);//задаване на размер на екрана с информация за изходното изображение
}

void draw() {
  pushMatrix();
  scale(0.5);
  image(img, 0, 0);
  image(adaptive, img.width, 0);
  popMatrix();

  // да не нагласят под картинките
  //fill(0);
  //text("adaptive threshold", img.width - 150, 0 +20 );

  adaptive.loadPixels();
  for (int i = 0; i < adaptive.pixels.length; i++) {
    //port.write(adaptive.pixels[i]);
    //print(adaptive.pixels[i] + ";");
  }
}

//Започване на серийна комуникация с Ардуиното
void connectToArdiono() {
  if (hasArduino) {//Започваме комуникацията само ако е зададено, че има свързано Ардуино
    port = new Serial(this, portname, baudrate);//Инициализиране на порта за серийнна комуникация
    println(port); //Отпечатване на порта
  }
}

//Обработка на изображението, което ще бъде нарисувано от плотера
void processImage() {

  //Зареждане на изображението
  img = loadImage(imgPath);

  //Инициализиране на OpenCV за обработка на изображението
  opencv = new OpenCV(this, img);  

  //Преобразуване на изображението в сивия спектър, защото тази имплементация работи само с gray scale изображения
  PImage gray = opencv.getSnapshot();
  opencv.loadImage(gray);

  //Бинаризиране на изображението с adaptive threshold
  opencv.adaptiveThreshold(591, 1);
  adaptive = opencv.getSnapshot();

  //Завъртане на изображението, ако ширината не е по-малка от височината
  rotate();
  //Скалиране на изображението, за да може да се изчертае от плотера
  img_resize();
}

//Обръщаме изображението, ако е необходимо, за да не се намаля трърде много
//Ако е извиква, то е по-добре да е преди img_resize, защото инаме няма да има ефекта на разването на по-голямо изображение.
void rotate() {
  
  //Проверка дали изображението е обърнато
  if(plot_width < plot_height && adaptive.width > adaptive.height){
  //Създаваме ново изображение
  PImage rotated = createImage(adaptive.height, adaptive.width, ALPHA);
  
  //Зареждане на пикселите на двете изображение
  rotated.loadPixels();
  adaptive.loadPixels();
  
  //Номера на итерацията по старата ширина и номера на стария индекс по ширина
  //@TODO: Да се види дали има някакъв готов начин за направата на това
  int iter = 0;
  int ind = 0;
  for (int i = 0; i < adaptive.pixels.length; i++) {
    if(ind > adaptive.height - 1){
      ind = 0;
      iter++;
    }
    rotated.pixels[i] = adaptive.pixels[iter + ind*adaptive.width];
    ind++;
  }
  rotated.updatePixels();//Обновяване на пикселите на новото изображение
  
  //Променяме оригиналното изображение
  adaptive = rotated;
  }
}

//Промяна на размера на изображението с цел да може да се изчертае от плотера
void img_resize() {
  //В началото новите размери са равни на старите
  int new_height = adaptive.height, new_width = adaptive.width;

  //Ако височина на изображението е по-голяма от тази на плотера
  if (plot_height < new_height) {
    int old_height = new_height; //запазваме старата височина
    new_height = new_height - (new_height - plot_height); //премахваме излишната височина
    new_width = new_width*(new_height/old_height); // ширината я умножаваме по коефициента, с който е намалена височината(?*old_height=new_height => ? = new_height/old_height)
  }
  //Ако ширината на изображението е по-голяма от тази на плотера
  if (plot_width < new_width) {
    int old_width = new_width;//запазваме старата ширина
    new_width = new_width - (new_width - plot_width);//премахваме излишната ширина
    new_height = new_height*(new_width/old_width);// височината я умножаваме по коефициента, с който е намалена ширината(?*old_width=new_width => ? = new_width/old_width)
  }

  //Задаване на новите размери на изображението
  adaptive.resize(new_width, new_height);
}

import gab.opencv.*;
import processing.serial.*;

//серийна комуникация с Ардуиното
Serial port;
String portname = "COM3";  
int baudrate = 9600;
int plot_width=1000, plot_height=2500;

//Изображението
OpenCV opencv;
PImage  img, canny,ad,rotate;
String imgPath = "../data/test6.jpg";

boolean hasArduino = false; //Флаг дали има свързано Ардуно
boolean rotateIfNecessary = true; //да се ротира ли изображение, ако не е ориентирано както плотера

void setup() {
  connectToArdiono();//свързване към ардуното
  processImage(); //обработка на изображението

  size(1080, 720);//задаване на размер на екрана с информация за изходното изображение

  noLoop(); // draw() се извиква само веднъж
}

void draw() {
  pushMatrix();
  scale(0.5);
  image(img, 0, 0);
  image(canny, img.width, 0);
  image(ad, 0, img.height);
  //image(rotate, img.width, img.height);
  popMatrix();

  canny.loadPixels();
  //@TODO: Да се добави компресиране на данните преди изпращане(като последователност(Бели*брой черни*брой бели*брой и т.н)
  //Също предварително изпращане на размерите на картината и ардуиното ще си слага мястото за нов ред само
  for (int i = 0; i < canny.pixels.length; i++) {
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
  //Завъртане на изображението
  img_rotate();
  //Скалиране на изображението, за да може да се изчертае от плотера
  img_resize();

  //Инициализиране на OpenCV за обработка на изображението
  opencv = new OpenCV(this, img);
  opencv.findCannyEdges(50,200);
  canny = opencv.getSnapshot();
  canny.filter(INVERT);
  
  opencv = new OpenCV(this, img);
  opencv.findCannyEdges(50,150);
  ad = opencv.getSnapshot();
  ad.filter(INVERT);

}

//@TODO: Ако има готова решение, да се замести с него
void img_rotate() {
  img.loadPixels();
  if (rotateIfNecessary && (img.height > plot_height || img.width > plot_width) &&
    ((img.height < img.width && plot_height > plot_width) 
          || (img.height > img.width && plot_height < plot_width))) {
     rotate = createImage(img.height, img.width, RGB);
    rotate.loadPixels();
    int iter=0, ind =0;
    for (int i = 0; i < img.pixels.length; i++) {
      if(ind > img.width - 1){
        iter++;
        ind= 0;
      }
      rotate.pixels[ind*img.height + iter] = img.pixels[i];
      ind++;
    }
    rotate.updatePixels();
    img = rotate;
  }
}

//Промяна на размера на изображението с цел да може да се изчертае от плотера
void img_resize() {
  //В началото новите размери са равни на старите
  int new_height = img.height, new_width = img.width;

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
  img.resize(new_width, new_height);
}

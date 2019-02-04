import gab.opencv.*;
import processing.serial.*;

//Изображението
OpenCV opencv;
PImage  img, gray, grayEqualized, adaptive, adaptiveEqualized, threshold, thresholdEqualized, res;
String imgPath = "../data/test19.jpg";//Изображението, което ще се обработва
color[][] mat2d;//Пикселите на изображението, което ще се изчертава в двумерен масив

boolean rotateIfNecessary = true; //да се ротира ли изображение, ако не е ориентирано както плотера

void setup() {
  connectToArdiono();//свързване към ардуното
  processImage(); //обработка на изображението

  size(800, 800);//задаване на размер на екрана с информация за изходното изображение
  
  PImage buffer = threshold;

  res = buffer;
  //OpenCV.HORIZONTAL, OpenCV.VERTICAL, or OpenCV.BOTH
  //flip
  opencv = new OpenCV(this, res);
  opencv.flip(OpenCV.HORIZONTAL);
  res = opencv.getSnapshot();
  thread("sendFreemanCode");
}

void sendFreemanCode() {
  sendFreemanCode(buffer);
  closeCommunication();
}

void draw() {
  background (192);
  //res
  //, , , ;
  //Изчертаване на някои от обработените изображения и хистограмите. Използва се единствено за моментен преглед на резултатие
  pushMatrix();
  scale(0.5);

  if (isEnd) {
    image(img, 0, 0);
    image(res, img.width, 0);
    image(gray, 0, img.height);
    image(grayEqualized, img.width, img.height);
    image(adaptive, 0, 2*img.height);
    image(adaptiveEqualized, img.width, 2*img.height);
    image(threshold, 0, 3*img.height);
    image(thresholdEqualized, img.width, 3*img.height);
    image(cannyMean, 0, 4*img.height);
    image(cannyMeanEqualized, img.width, 4*img.height);
    image(cannyMedian, 0, 5*img.height);
    image(cannyMedianEqualized, img.width, 5*img.height);
    grayHist.draw(2*img.width, 0, 700, 300);
    grayHistEqualized.draw(2*img.width, 300, 700, 300);
  } else {
    image(res, 0, 0, 500, 200);
    delay(2000);
  }
  popMatrix();
}

void updateResImage(int x, int y) {
  res.loadPixels();
  res.pixels[res.width*x + y] = RED;
  res.updatePixels();
}

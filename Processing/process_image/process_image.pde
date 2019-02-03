import gab.opencv.*;
import processing.serial.*;

//Изображението
OpenCV opencv;
PImage  img, gray, grayEqualized, adaptive, adaptiveEqualized,threshold, thresholdEqualized, res;
String imgPath = "../data/test21.jpg";//Изображението, което ще се обработва
float lowerInd = 0.66, upperInd = /*1.98,1.33*/1.33;//Индектси за определяне на горна и долна граница на threshold
color[][] mat2d;//Пикселите на изображението, което ще се изчертава в двумерен масив

boolean rotateIfNecessary = true; //да се ротира ли изображение, ако не е ориентирано както плотера

void setup() {
  connectToArdiono();//свързване към ардуното
  processImage(); //обработка на изображението

  size(500, 500);//задаване на размер на екрана с информация за изходното изображение
  noLoop(); // draw() се извиква само веднъж
}

void draw() {
  sendFreemanCode(/*cannyMeanEqualized*/adaptive);//Изпращане на информацията за контурите на изображението към Arduino
//res
//, , , ;
  //Изчертаване на някои от обработените изображения и хистограмите. Използва се единствено за моментен преглед на резултатие
  pushMatrix();
  scale(0.5);
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
  image(cannyMedian, 0, 4*img.height);
  image(cannyMedianEqualized, img.width, 4*img.height);
  grayHist.draw(2*img.width, 0, 700, 300);
  grayHistEqualized.draw(2*img.width, 300, 700, 300);
  image(adaptive/*Equalized*/, 0, img.height);
  image(cannyMedian/*Equalized*/, img.width, img.height);
  popMatrix();
}

//Обработка на изображението, което ще бъде нарисувано от плотера
void processImage() {
  //Зареждане на изображението
  img = loadImage(imgPath);
  img.save("../output/1img.jpg");
  //Завъртане на изображението
  img_rotate();
  //Скалиране на изображението, за да може да се изчертае от плотера
  img_resize();

  //Взимане на изображението в сивата скала и неговата хистограма
  opencv = new OpenCV(this, img);
  gray = opencv.getSnapshot();
  gray.save("../output/2gray.jpg");

  grayHist = opencv.findHistogram(opencv.getGray(), 256);

  //Взимане на изображението с изравнена хистограма
  opencv.equalizeHistogram();
  grayEqualized = opencv.getSnapshot();
  grayEqualized.save("../output/3grayEqualized.jpg");
  
  grayHistEqualized = opencv.findHistogram(opencv.getGray(), 256);

  opencv.loadImage(gray);
  opencv.threshold(80);
  threshold = opencv.getSnapshot();
  threshold.save("../output/4threshold.jpg");
  
  opencv.loadImage(gray);
  opencv.adaptiveThreshold(10, 1);
  adaptive = opencv.getSnapshot();
  adaptive.save("../output/5adaptive.jpg");
  
  //Canny на изображението с treshold на база средната стойност на пикселите
  cannyMean = canny(img, CannyThreshold.MEAN);
  cannyMean.save("../output/6cannyMean.jpg");

  //Canny на изображението с treshold на база медианата на пикселите
  cannyMedian = canny(img, CannyThreshold.MEDIAN);
  cannyMedian.save("../output/7cannyMedian.jpg");

  opencv.loadImage(grayEqualized);
  opencv.threshold(80);
  thresholdEqualized = opencv.getSnapshot();
  thresholdEqualized.save("../output/8thresholdEqualized.jpg");
  
  opencv.loadImage(grayEqualized);
  opencv.adaptiveThreshold(10, 1);
  adaptiveEqualized = opencv.getSnapshot();
  adaptiveEqualized.save("../output/9adaptiveEqualized.jpg");

  //Canny на изображението с изравнена хистограма с treshold на база средната стойност на пикселите
  cannyMeanEqualized = canny(grayEqualized, CannyThreshold.MEAN);
  cannyMeanEqualized.save("../output/10cannyMeanEqualized.jpg");

  //Canny на изображението с изравнена хистограма с treshold на база медианата на пикселите
  cannyMedianEqualized = canny(grayEqualized, CannyThreshold.MEDIAN);
  cannyMedianEqualized.save("../output/11cannyMedianEqualized.jpg");
}

void updateResImage(int x, int y) {
  res.loadPixels();
  res.pixels[res.width*x + y] = RED;
  res.updatePixels();
  image(res, res.width, 0, 500, 200);
}

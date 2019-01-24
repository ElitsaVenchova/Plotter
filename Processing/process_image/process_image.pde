import gab.opencv.*;
import processing.serial.*;

enum CannyThreshold {
  MEAN, MEDIAN
};

//серийна комуникация с Ардуиното
Serial port;
String portname = "COM3";  
int baudrate = 9600;
int plot_width=1000, plot_height=2500;

//Изображението
OpenCV opencv;
Histogram grayHist, grayHistEqualized;
PImage  img, cannyMean, cannyMedian, cannyMeanEqualized, cannyMedianEqualized, gray, grayEqualized;
String imgPath = "../data/test8.jpg";
float lowerInd = 0.66,upperInd = /*1.98,1.33*/1.98;

boolean hasArduino = false; //Флаг дали има свързано Ардуно
boolean rotateIfNecessary = false; //да се ротира ли изображение, ако не е ориентирано както плотера

void setup() {
  connectToArdiono();//свързване към ардуното
  processImage(); //обработка на изображението

  size(2080, 900);//задаване на размер на екрана с информация за изходното изображение
  noLoop(); // draw() се извиква само веднъж
}

void draw() {
  pushMatrix();
  scale(0.5);
  image(gray, 0, 0);
  image(grayEqualized, img.width, 0);
  grayHist.draw( 2*img.width, 0, 700, 300);
  grayHistEqualized.draw( 2*img.width, 300, 700, 300);
  image(cannyMean/*Equalized*/, 0, img.height);
  image(cannyMedian/*Equalized*/, img.width, img.height);
  popMatrix();

  //cannyMean.loadPixels();
  //@TODO: Да се добави компресиране на данните преди изпращане(като последователност(Бели*брой черни*брой бели*брой и т.н)
  //Също предварително изпращане на размерите на картината и ардуиното ще си слага мястото за нов ред само
  for (int i = 0; i < cannyMean.pixels.length; i++) {
    //port.write(gray(cannyMean.pixels[i]));
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
  img.save("../output/1img.jpg");
  //Завъртане на изображението
  img_rotate();
  //Скалиране на изображението, за да може да се изчертае от плотера
  img_resize();

  opencv = new OpenCV(this, img);
  gray = opencv.getSnapshot();
  gray.save("../output/2gray.jpg");

  grayHist = opencv.findHistogram(opencv.getGray(), 256);

  opencv.equalizeHistogram();
  grayEqualized = opencv.getSnapshot();
  grayEqualized.save("../output/3grayEqualized.jpg");

  grayHistEqualized = opencv.findHistogram(opencv.getGray(), 256);

  //Инициализиране на OpenCV за обработка на изображението
  cannyMean = canny(img, CannyThreshold.MEAN);
  cannyMean.save("../output/4cannyMean.jpg");

  cannyMedian = canny(img, CannyThreshold.MEDIAN);
  cannyMedian.save("../output/5cannyMedian.jpg");

  cannyMeanEqualized = canny(grayEqualized, CannyThreshold.MEAN);
  cannyMeanEqualized.save("../output/6cannyMeanEqualized.jpg");

  cannyMedianEqualized = canny(grayEqualized, CannyThreshold.MEDIAN);
  cannyMedianEqualized.save("../output/7cannyMedianEqualized.jpg");
}

//@TODO: Ако има готова решение, да се замести с него
void img_rotate() {
  if (rotateIfNecessary && (img.height > plot_height || img.width > plot_width) &&
    ((img.height < img.width && plot_height > plot_width) 
    || (img.height > img.width && plot_height < plot_width))) {

    img.loadPixels();
    PImage rotate = createImage(img.height, img.width, RGB);
    rotate.loadPixels();
    int iter=0, ind =0;
    for (int i = 0; i < img.pixels.length; i++) {
      if (ind > img.width - 1) {
        iter++;
        ind= 0;
      }
      rotate.pixels[ind*img.height + iter] = img.pixels[i];
      ind++;
    }
    cannyMedian.updatePixels();
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

PImage canny(PImage src, CannyThreshold metod) {
  opencv = new OpenCV(this, src);
  PImage srcGrey = opencv.getSnapshot();
  
  int[] vals = new int[256];
   
   srcGrey.loadPixels();
   srcGrey.getNative();
   for(int i=0;i<srcGrey.pixels.length;i++){
    vals[gray(srcGrey.pixels[i])]++;
   }
   
  int val = 0;
  
  if(CannyThreshold.MEAN.equals(metod)){
    val = findMean(src.pixels.length,vals);
  } else {
    val = findMedian(src.pixels.length/2, vals);
  }
  println(metod + " -> " + val + ";");
  PImage dest;
  //Инициализиране на OpenCV за обработка на изображението
  opencv = new OpenCV(this, src);
  opencv.findCannyEdges((int)lowerInd*val, (int)upperInd*val);
  dest = opencv.getSnapshot();
  dest.filter(INVERT);
  return dest;
}

int findMedian(int mid,int[] vals){
  int res=0;
  
   for(int i=0;i<vals.length;i++){
     if(vals[i] >= mid){
       res = i;
       break;
     } else {
       mid -= vals[i];
     }
   }
   
   return res;
}

int findMean(int srcSize,int[] vals){
   int sum = 0;
   for(int i=0;i<vals.length;i++){
     sum += i*vals[i];
   }
   return sum/srcSize;
}

static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);  
}

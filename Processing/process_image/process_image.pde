import gab.opencv.*;
import processing.serial.*;

//Метод за определяне на threshold за Canny алгоритъма
enum CannyThreshold { MEAN, MEDIAN}; 

final color WHITE = color(255, 255, 255);
final color BLACK = color(0, 0, 0);

//Числови стойности, които ще се подават на Arduino за задаване на действие
static final int DIR_UP = 0;
static final int DIR_UP_RIGHT = 1;
static final int DIR_RIGHT = 2;
static final int DIR_DOWN_RIGHT = 3;
static final int DIR_DOWN = 4;
static final int DIR_DOWN_LEFT = 5;
static final int DIR_LEFT = 6;
static final int DIR_UP_LEFT = 7;

static final int PEN_SHIFT = 8;

static final int END = 9;

//серийна комуникация с Ардуиното
Serial port;
String portname = "COM3";  
int baudrate = 9600;
int plot_width=(200 * 11 + 50)/40, plot_height=(200 * 9)/40;//56/45
int x=0, y=0;

//Изображението
OpenCV opencv;
Histogram grayHist, grayHistEqualized;//Хистограмата на сивото изображение, Хистограмата след изравняване
PImage  img, cannyMean, cannyMedian, cannyMeanEqualized, cannyMedianEqualized, gray, grayEqualized;
String imgPath = "../data/test20.png";//Изображението, което ще се обработва
float lowerInd = 0.66, upperInd = /*1.98,1.33*/1.33;//Индектси за определяне на горна и долна граница на threshold
color[][] mat2d;//Пикселите на изображението, което ще се изчертава в двумерен масив

boolean hasArduino = true; //Флаг дали има свързано Ардуно
boolean rotateIfNecessary = true; //да се ротира ли изображение, ако не е ориентирано както плотера

void setup() {
  connectToArdiono();//свързване към ардуното
  processImage(); //обработка на изображението

  sendFreemanCode(cannyMeanEqualized);//Изпращане на информацията за контурите на изображението към Arduino

  size(2080, 900);//задаване на размер на екрана с информация за изходното изображение
  noLoop(); // draw() се извиква само веднъж
}

void draw() {
  //Изчертаване на някои от обработените изображения и хистограмите. Използва се единствено за моментен преглед на резултатие
  pushMatrix();
  scale(0.5);
  image(gray, 0, 0);
  image(grayEqualized, img.width, 0);
  grayHist.draw( 2*img.width, 0, 700, 300);
  grayHistEqualized.draw( 2*img.width, 300, 700, 300);
  image(cannyMean/*Equalized*/, 0, img.height);
  image(cannyMedian/*Equalized*/, img.width, img.height);
  popMatrix();
}



//################################################################Обработка на изображението




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

  //Canny на изображението с treshold на база средната стойност на пикселите
  cannyMean = canny(img, CannyThreshold.MEAN);
  cannyMean.save("../output/4cannyMean.jpg");

  //Canny на изображението с treshold на база медианата на пикселите
  cannyMedian = canny(img, CannyThreshold.MEDIAN);
  cannyMedian.save("../output/5cannyMedian.jpg");

  //Canny на изображението с изравнена хистограма с treshold на база средната стойност на пикселите
  cannyMeanEqualized = canny(grayEqualized, CannyThreshold.MEAN);
  cannyMeanEqualized.save("../output/6cannyMeanEqualized.jpg");

  //Canny на изображението с изравнена хистограма с treshold на база медианата на пикселите
  cannyMedianEqualized = canny(grayEqualized, CannyThreshold.MEDIAN);
  cannyMedianEqualized.save("../output/7cannyMedianEqualized.jpg");
}


//####################################Основни обработки
//Завъртане на изображението
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


//####################################Canny


//Прилагане на алгоритъма Canny
//src - входно изображение
//method - метода, който да се използва за определяне на treshold
//output: новото изображение, което е изход от прилагането на Canny върху src
PImage canny(PImage src, CannyThreshold metod) {
	
	//Вземаме входното изображение в сивия спектър
  opencv = new OpenCV(this, src);
  PImage srcGrey = opencv.getSnapshot();

  //Ръчно пресмятане на хистограмата
  int[] hist = new int[256];

  srcGrey.loadPixels();
  srcGrey.getNative();
  for (int i=0; i<srcGrey.pixels.length; i++) {
    hist[gray(srcGrey.pixels[i])]++;
  }

  //Определяне на стойността за treshold в зависимост от подадения метод
  int val;
  if (CannyThreshold.MEAN.equals(metod)) {
    val = findMean(src.pixels.length, hist);
  } else {
    val = findMedian(src.pixels.length/2, hist);
  }
  
  PImage dest;
  //Прилагане на Canny върху входното изображение
  opencv = new OpenCV(this, src);
  opencv.findCannyEdges((int)lowerInd*val, (int)upperInd*val);
  dest = opencv.getSnapshot();//резултата е бинаризирано изображение, на което контурите са бели, а всичко останало е черно
  dest.filter(INVERT); //обръщаме резултата(бяло->черно и черно->бяло)
  return dest;
}

//Намиране на медиана на база хистограмата
int findMedian(int mid, int[] hist) {
  int res=0;

  for (int i=0; i<hist.length; i++) {
    if (hist[i] >= mid) {
      res = i;
      break;
    } else {
      mid -= hist[i];
    }
  }

  return res;
}

//Намиране на средната стойност на база хистограмата
int findMean(int srcSize, int[] vals) {
  int sum = 0;
  for (int i=0; i<vals.length; i++) {
    sum += i*vals[i];
  }
  return sum/srcSize;
}

//PImage.pixels връща масив от color, което е число(в RGB). 
//Тук го обработваме да връща стойностите на цвета от 0 до 255 за изображенията в сивия спектър 
static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);
}

//################################################################Freeman Chain Code

void sendFreemanCode(PImage src) {
  mat2d = get2DMatrics(src);
  for (int i=0; i<mat2d.length; i++) {
    for (int j=0; j<mat2d[0].length; j++) {
      if (BLACK == mat2d[i][j]) {
        sendFreemanCode(i,j);
        sendArdiuno(PEN_SHIFT);
        getFreemanCode(mat2d.length, mat2d[0].length);
        sendArdiuno(PEN_SHIFT);
      }
    }
  }
  sendFreemanCode(0,0);
  sendArdiuno(END); //Край на изображението
}

void sendFreemanCode(int destX, int destY){
  while(x != destX || y != destY){
    if(x > destX && y == destY){
      sendArdiuno(DIR_UP);
      x--;
    } else if(x > destX && y < destY){
      sendArdiuno(DIR_UP_RIGHT);
      x--;
      y++;
    } else if(x == destX && y < destY){
      sendArdiuno(DIR_RIGHT);
      y++;
    } else if(x < destX && y < destY){
      sendArdiuno(DIR_DOWN_RIGHT);
      x++;
      y++;
    } else if(x < destX && y == destY){
      sendArdiuno(DIR_DOWN);
      x++;
    } else if(x < destX && y > destY){
      sendArdiuno(DIR_DOWN_LEFT);
      x++;
      y--;
    } else if(x == destX && y > destY){
      sendArdiuno(DIR_LEFT);
      y--;
    }else if(x > destX && y > destY){
      sendArdiuno(DIR_UP_LEFT);
      x--;
      y--;
    }
  }
}

//Изпращене на следващия от (x,y) пиксел от контура.
void getFreemanCode(int width, int height) {
  mat2d[x][y] = WHITE;
  if (x - 1 >= 0 && mat2d[x-1][y] == BLACK) {
    sendArdiuno(DIR_UP);
    x--;
    getFreemanCode(width, height);
  } else if (x - 1 >= 0 && y + 1 < height && mat2d[x-1][y + 1] == BLACK) {
    sendArdiuno(DIR_UP_RIGHT);
    x--;
    y++;
    getFreemanCode(width, height);
  } else if (y + 1 < height && mat2d[x][y+1] == BLACK) {
    sendArdiuno(DIR_RIGHT);
    y++;
    getFreemanCode(width, height);
  } else if (x + 1 < width && y + 1 < height && mat2d[x+1][y + 1] == BLACK) {
    sendArdiuno(DIR_DOWN_RIGHT);
    x++;
    y++;
    getFreemanCode(width, height);
  } else if (x + 1 < width && mat2d[x + 1][y] == BLACK) {
    sendArdiuno(DIR_DOWN);
    x++;
    getFreemanCode(width, height);
  } else if (x + 1 >= 0 && y - 1 < height && mat2d[x+1][y - 1] == BLACK) {
    sendArdiuno(DIR_DOWN_LEFT);
    x++;
    y--;
    getFreemanCode(width, height);
  } else if (y - 1 >= 0 && mat2d[x][y-1] == BLACK) {
    sendArdiuno(DIR_LEFT);
    y--;
    getFreemanCode(width, height);
  } else if (y -1 >= 0 && x - 1 >= 0 && mat2d[x-1][y-1] == BLACK) {
    sendArdiuno(DIR_UP_LEFT);
    x--;
    y--;
    getFreemanCode(width, height);
  }
}

//Преобразуване на масива с пикселите в двумерен за по-лесно обработване
color[][] get2DMatrics(PImage src) {
  color[][] res = new color[src.width][src.height];
  src.loadPixels();

  int y = -1;
  for (int i=0; i<src.pixels.length; i++) {
    if (i%src.width == 0) {
      y++;
    }
    res[i - src.width*y][y] = src.pixels[i];
  }

  return res;
}
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

void waitOK(){
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

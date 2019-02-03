//####################################Canny
//Метод за определяне на threshold за Canny алгоритъма
enum CannyThreshold { 
  MEAN, MEDIAN
}; 

Histogram grayHist, grayHistEqualized;//Хистограмата на сивото изображение, Хистограмата след изравняване
PImage  cannyMean, cannyMedian, cannyMeanEqualized, cannyMedianEqualized;
float lowerInd = 0.66, upperInd = /*1.98,1.33*/1.33;//Индектси за определяне на горна и долна граница на threshold

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

final color WHITE = color(255, 255, 255);
final color BLACK = color(0, 0, 0);
final color RED = color(255, 0, 0);

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

  print("threshold");
  opencv = new OpenCV(this, img);
  opencv.threshold(170);
  threshold = opencv.getSnapshot();
  threshold.save("../output/4threshold.jpg");

  print("adaptive");
  opencv = new OpenCV(this, img);
  opencv.adaptiveThreshold(5, 1);
  adaptive = opencv.getSnapshot();
  adaptive.save("../output/5adaptive.jpg");

  //Canny на изображението с treshold на база средната стойност на пикселите
  cannyMean = canny(img, CannyThreshold.MEAN);
  cannyMean.save("../output/6cannyMean.jpg");

  //Canny на изображението с treshold на база медианата на пикселите
  cannyMedian = canny(img, CannyThreshold.MEDIAN);
  cannyMedian.save("../output/7cannyMedian.jpg");

  print("thresholdEqualized");
  opencv = new OpenCV(this, grayEqualized);
  opencv.threshold(170);
  thresholdEqualized = opencv.getSnapshot();
  thresholdEqualized.save("../output/8thresholdEqualized.jpg");

  print("adaptiveEqualized");
  opencv = new OpenCV(this, grayEqualized);
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

//Преобразуване на масива с пикселите в двумерен за по-лесно обработване
color[][] get2DMatrics(PImage src) {
  color[][] res = new color[src.height][src.width];
  src.loadPixels();

  int y = -1;
  for (int i=0; i<src.pixels.length; i++) {
    if (i%src.width == 0) {
      y++;
    }
    res[y][i - src.width*y] = src.pixels[i];
  }

  return swap(res);
}

color[][] swap(color[][] imgMatr) {
  color[][] res = new color[imgMatr.length][imgMatr[0].length];

  for (int i=0; i<imgMatr.length; i++) {
    int y = imgMatr[0].length - 1;
    for (int j=0; j<imgMatr[0].length; j++) {
      res[i][y] = imgMatr[i][j];
      y--;
    }
  }

  return res;
}

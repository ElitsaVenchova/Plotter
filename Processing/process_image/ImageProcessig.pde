final color WHITE = color(255, 255, 255);
final color BLACK = color(0, 0, 0);
final color RED = color(255, 0, 0);

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

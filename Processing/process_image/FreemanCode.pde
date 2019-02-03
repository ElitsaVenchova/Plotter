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

boolean isEnd = false ;

int x=0, y=0;

//################################################################Freeman Chain Code

void sendFreemanCode(PImage src) {
  mat2d = get2DMatrics(src);
  for (int i=0; i<mat2d.length; i++) {
    for (int j=0; j<mat2d[0].length; j++) {
      if (BLACK == mat2d[i][j]) {
        moveAsFreemanCode(i, j);
        sendArdiuno(PEN_SHIFT);
        getFreemanCode(mat2d.length, mat2d[0].length);
        sendArdiuno(PEN_SHIFT);
      }
    }
  }
  moveAsFreemanCode(0, 0);
  sendArdiuno(END); //Край на изображението
  isEnd = true;
}

void moveAsFreemanCode(int destX, int destY) {
  while (x != destX || y != destY) {
    if (x > destX && y == destY) {
      sendArdiuno(DIR_UP);
      x--;
    } else if (x > destX && y < destY) {
      sendArdiuno(DIR_UP_RIGHT);
      x--;
      y++;
    } else if (x == destX && y < destY) {
      sendArdiuno(DIR_RIGHT);
      y++;
    } else if (x < destX && y < destY) {
      sendArdiuno(DIR_DOWN_RIGHT);
      x++;
      y++;
    } else if (x < destX && y == destY) {
      sendArdiuno(DIR_DOWN);
      x++;
    } else if (x < destX && y > destY) {
      sendArdiuno(DIR_DOWN_LEFT);
      x++;
      y--;
    } else if (x == destX && y > destY) {
      sendArdiuno(DIR_LEFT);
      y--;
    } else if (x > destX && y > destY) {
      sendArdiuno(DIR_UP_LEFT);
      x--;
      y--;
    }
  }
}

//Изпращене на следващия от (x,y) пиксел от контура.
void getFreemanCode(int width, int height) {
  mat2d[x][y] = WHITE;
  updateResImage(x, y);
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
  } else if (x + 1 < width && y - 1 >= 0 && mat2d[x+1][y - 1] == BLACK) {
    sendArdiuno(DIR_DOWN_LEFT);
    x++;
    y--;
    getFreemanCode(width, height);
  } else if (y - 1 >= 0 && mat2d[x][y-1] == BLACK) {
    sendArdiuno(DIR_LEFT);
    y--;
    getFreemanCode(width, height);
  } else if (x - 1 >= 0 && y -1 >= 0 && mat2d[x-1][y-1] == BLACK) {
    sendArdiuno(DIR_UP_LEFT);
    x--;
    y--;
    getFreemanCode(width, height);
  }
}

/*********************************  MY CURSOR ********************/

void set_cursor(int cursor_on) {
  int size;

  setactivepage(0);
  if (!cursor_on) {
    putimage(col+7,row,text_cursor.oldscreen,COPY_PUT);
    free(text_cursor.oldscreen);
    text_cursor.on=0;
  }
  else {
    size=imagesize(col+7,row,col+14,row+16);
    text_cursor.oldscreen=malloc(size);
    getimage(col+7,row,col+14,row+16,text_cursor.oldscreen);
    setfillstyle(SOLID_FILL, WHITE);
    bar(col+7, row, col+14, row+16);
    text_cursor.on=1;
  }
}

/*********************** MY CURSOR **********************************/
typedef struct {
  int x, y, on;
  void *oldscreen;
} CURSOR;

CURSOR text_cursor;

#define K_ESC    0x1b
#define K_ENTER  0x0a
#define K_CTRL_W 0x17
#define K_CTRL_E 0x05
#define K_BS     0x7f

/* data structure for the menu */
typedef struct menunode {
  char *title;
  struct menunode *nextmenu, *prevmenu;    /* pointer to other menu nodes */
  char *entry[10];      /* description of options */
  int menux,menuy;      /* location of menuface */
  int noofentry;        /* number of options available */
  void (*func)();       /* functions used to process the choice made */
  int option;           /* the option selected by user */
  WINDOW *frame, *win_handle;   /* handle of opened window */
} MENU;

extern int bailout;

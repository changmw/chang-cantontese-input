/* header file for Videotex.c */

/* printer status */
#define PTR_SELECTED   0x10
#define PTR_IOERROR    0x08
#define PTR_OUTOFPAPER 0x20

/* functions */
void modemf();
void dialf();
void termf();
void localf();
void baudf();
void stopbitf();
void wordlenf();
void parityf();
void serialpf();
void miscf();
void fsavef();
void init_menu();
void horiz_menu();
void print_screen();
void draw_logo();
void save_config();
void load_config();
void init_config();
void change_dialdir();
void show_dialdir();
void change_macros();
void show_macros();
void testing();
void menu_statusline();

/* macro data structure */
typedef struct {
  char name[10][11];     /* macro's functional description */
  char content[10][11];  /* content */
} MACRO;

/* dialing directory data structure */
typedef struct {
  int  cur_entry;          /* pointer to current phone number */
  char description[10][21];   /* description of options */
  char phonenumber[10][11];   /* phone number */
  int  baudrate[10];       /* baud rate */
  char wordlength[10];     /* word length */
  char stopbit[10];        /* no of stop bits */
  char parity[10];         /* parity */
} DIALDIR;

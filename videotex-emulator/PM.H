#define OFF       0         /* Define for all OFF flags */
#define ON        1         /* Define for all ON  flags */
#define CHAR_BASE 0x0000    /* Segment address of Character base */

/* Defines of all screen modes */

#define NORMAL    0         /* Normal height (default) */
#define DOUBLE    1         /* Double height */

#define ALPHA     0         /* Alpha mode (default) */
#define CHINESE   1         /* Chinese mode */
#define MOSAIC    2         /* Mosaic mode */


#define CONTIGUOUS 0        /* Contiguous mosaic mode */
#define SEPARATED 1         /* Separated mosaic mode */

#define STANDARD  0         /* Standard character mode (default) */

/* Defines of all control codes */

#define ESC       27        /* Escape */
#define DC_ON     17        /* Device control ON */
#define DC_OFF    20        /* Device control OFF */
#define APB       8         /* Active position backwards */
#define APF       9         /* Active position forward */
#define APD       10        /* Active position down */
#define APU       11        /* Active position up */
#define CS        12        /* Clear screen */
#define APR       13        /* Active position return */
#define APH       30        /* Active position home */
#define NUL       0         /* Null */
#define ENQ       5         /* Enquiry */
#define ALPHA_RED      65   /* Alpha color red */
#define ALPHA_GREEN    66   /* Alpha color green */
#define ALPHA_YELLOW   67   /* Alpha color yellow */
#define ALPHA_BLUE     68   /* Alpha color blue */
#define ALPHA_MAGENTA  69   /* Alpha color magenta */
#define ALPHA_CYAN     70   /* Alpha color cyan */
#define ALPHA_WHITE    71   /* Alpha color white */
#define MOSAIC_RED     81   /* Mosaic color red */
#define MOSAIC_GREEN   82   /* Mosaic color green */
#define MOSAIC_YELLOW  83   /* Mosaic color yellow */
#define MOSAIC_BLUE    84   /* Mosaic color blue */
#define MOSAIC_MAGENTA 85   /* Mosaic color magenta */
#define MOSAIC_CYAN    86   /* Mosaic color cyan */
#define MOSAIC_WHITE   87   /* Mosaic color white */
#define CHINESE_RED     97  /* Chinese color red */
#define CHINESE_GREEN   98  /* Chinese color green */
#define CHINESE_YELLOW  99  /* Chinese color yellow */
#define CHINESE_BLUE    100 /* Chinese color blue */
#define CHINESE_MAGENTA 101 /* Chinese color magenta */
#define CHINESE_CYAN    102 /* Chinese color cyan */
#define CHINESE_WHITE   103 /* Chinse color white */

#define FLASH           72  /* Flashing */
#define STEADY          73  /* Steady */
#define NORMAL_HEIGHT   76  /* Normal character height */
#define DOUBLE_HEIGHT   77  /* Double character height */
#define CHINESE_MODE    78  /* Chinse mode */
#define CHINESE_SPECIAL 79  /* Chinese special character set */
#define CONCEAL         88  /* Conceal mode */
#define CONT_MOSAIC     89  /* Contiguous mosaic mode */
#define SEPA_MOSAIC     90  /* Separated mosaic mode */
#define BLACK_BKG       92  /* Black background */
#define NEW_BKG         93  /* New background */
#define HOLD_MOSAIC     94  /* Hold mosaic mode */
#define RELEASE_MOSAIC  95  /* Release mosaic mode */

extern int activepage;

/* Function prototypes */

void flashing();
void clear_attributes();
void charin(char c);
void do_escape_seq(char c);
void outchar(int xpos,int ypos,int size,char charsend);
void putcharline(int xcord,int ycord,int bitpattern,int out_color);
void reveal();
int save_text_screen(char *savefile, int mode);
int save_screen(char *savefile, int mode);
int view_screen(char *viewfile);

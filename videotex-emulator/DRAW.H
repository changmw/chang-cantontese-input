/*
   header file for using services of DRAW.C
*/
#define PI          3.1416      /* value of pi */

/* total length of arguments in number of bytes for various
   primtives */
#define N_CIRCLE    7
#define N_POINT     5
#define N_RECTANGLE 9
#define N_FILL      6
#define N_LINE      9
#define N_ARC       13
#define N_INC_SET   4
#define N_INC_LINE  5
#define N_INC_POINT 5
#define N_INC_ARC   9

/* ESC sequence for graphics primitives */
#define DRAW_LINE         0x70   /* ESC p */
#define DRAW_RECTANGLE    0x71   /* ESC q */
#define DRAW_POINT        0x72   /* ESC r */
#define DRAW_CIRCLE       0x73   /* ESC s */
#define DRAW_FILL         0x74   /* ESC t */
#define DRAW_ARC          0x75   /* ESC u */
#define INCREMENTAL_SET   0x76   /* ESC v */
#define INCREMENTAL_LINE  0x77   /* ESC w */
#define INCREMENTAL_POINT 0x78   /* ESC x */
#define INCREMENTAL_ARC   0x79   /* ESC y */

extern int maxx, maxy;
extern int line_on, circle_on, rectangle_on, point_on, fill_on, arc_on,
       inc_set_on, inc_line_on, inc_point_on, inc_arc_on;
extern int draw_para_rxd;
extern char draw_para[20];

void my_line();
void my_circle();
void my_rectangle();
void my_fill();
void my_point();
void my_arc();
void init_draw();
void set_draw_cursor();
void my_inc_line();
void my_inc_arc();
void my_inc_point();
void draw_arc(float x1, float y1,
              float x2, float y2,
              float x3, float y3,
              int color);
float findx(float x1, float y1,
            float x2, float y2,
            float x3, float y3);
float findy(float x1, float y1,
            float x2, float y2,
            float x3, float y3);
float quarter(float x, float y, float x1, float y1);
float rad_to_deg(float rad);

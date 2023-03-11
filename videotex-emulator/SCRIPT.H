/*
   header file for UTIL.H
*/
#define fbufsize 200     /* buffer size for each statement of the script */

#define LOOP        0    /* command flag */
#define ALARM       1
#define IF          3
#define DIAL        4
#define SEND        5
#define WAIT        6
#define CAPTURE     7
#define ELSE        8
#define SHOW        9
#define SLEEP      10
#define ENDIF      11
#define ENDLOOP    12
#define EXITLOOP   13
#define BADCOMMAND 14

#define NAME_X     320

extern int script_CONNECT;   /* use to communicate the result of dialing */
                             /* with communication manager */
extern int script_running;

void execute_script(char *fname);
void substr(char *source, int s, int n, char *target);
void parse_command_line();
void addnull();
int nextword(char *s, int i);

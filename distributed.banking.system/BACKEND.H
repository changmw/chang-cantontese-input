#define OK      "00\0"
#define SYSERR  "02\0"
#define DUP     "03\0"
#define REC1ERR "04\0"
#define BALERR  "05\0"
#define REC2ERR "07\0"
#define PWERR   "09\0"

struct qtype {
     long mtype;
     char mtext[60];
     } ;

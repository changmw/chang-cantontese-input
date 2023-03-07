/*
 * header for an entry form
 */
#define MAX_ENTRY_LEN 50  /* maximum entry length */
#define MAX_ENTRY_NUM 10  /* maximum number of entry in a form */

#define ECHO_ON       1
#define ECHO_OFF      0

#define ACCEPT        1
#define REJECT        2

#define NONE          0
#define NUMERIC       1
#define STRING        2
#define DATE          3

/* Transaction Codes */
#define OPER 1
#define OPEN 2
#define AINQ 3
#define ADEP 4
#define ACWD 5
#define ATFR 6
#define CLOS 7

/* field lengths */
#define L_TRANCODE 4
#define L_OPERID   3
#define L_PASSWORD 8
#define L_ACCNUM   6
#define L_AMOUNT   9
#define L_CUSTNAME 50
#define L_RESPONSE 2

#define REQUEST_QNAME 1234

typedef struct item_entry {
    char * e_name;                                        /* name description */
    int  e_type;                 /* 0 - no value, 1 - int, 2 - char, 3 - date */
    int  e_length;                                    /* length for the entry */
    int  e_echo;                                    /* 0 - echo, 1 - not echo */
    int  namex, namey;                            /* pos for name description */
    int  valuex, valuey;                               /* pos for value entry */
    char e_value[MAX_ENTRY_LEN];                  /* to store the entry value */
} BASE_ENTRY;

typedef struct form_type {
    char * title;                                               /* form title */
    int no_of_entry;
    int formx, formy;
    BASE_ENTRY  entry[MAX_ENTRY_NUM];                  /* entries of the form */
} BASE_FORM;

typedef struct tran_type {
    char tran_code;
    char tran_state;
    char operator_id[L_OPERID];
    char tran_account1[L_ACCNUM];
    char tran_account2[L_ACCNUM];
    char tran_amount[L_AMOUNT];
    char tran_result;
} TRANSACTION;

typedef struct reply {
    char code[L_RESPONSE];
    char operator[L_OPERID];
    char account[L_ACCNUM];
    char f_amount[L_AMOUNT];
    char t_amount[L_AMOUNT];
} REPLY;

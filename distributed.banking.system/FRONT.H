/*
 * header for an entry form
 */
#define MAX_ENTRY_LEN 51  /* maximum entry length */
#define MAX_ENTRY_NUM 10  /* maximum number of entry in a form */

#define ECHO_ON       1
#define ECHO_OFF      0

/*
 * type of a entry in a form
 */
#define T_PLAIN_TEXT   0
#define T_OPERID       1
#define T_PASSWORD     2
#define T_ACCNUM       3
#define T_ACCNUM2      4
#define T_AMOUNT       5
#define T_CUSTNAME     6

/*
 * amount error
 */
#define AMT_ERR        0
#define AMT_OK         1
#define AMT_ZERO       2
#define AMT_EXCEED_MAX 3
/*
 * response from backend
 */
#define ACCEPT         0
#define REJECT         1
#define SYSTEM_ERR     2
#define DUPLICATE_REC  3
#define REC1_NOT_FOUND 4
#define EXCEED_BALANCE 5
#define TRAN_AMT_ERR   6
#define REC2_NOT_FOUND 7
#define INVALID_OPER   8
#define PASSWORD_ERR   9

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
#define IPC_WAIT      0

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
    int    tran_code;
    char   tran_cust_name[L_CUSTNAME+1];
    char   tran_operator_num[L_OPERID+1];
    char   tran_operator_passwd[L_PASSWORD+1];
    char   tran_account1[L_ACCNUM+1];
    char   tran_account2[L_ACCNUM+1];
    char   tran_amount[L_AMOUNT+1];
    int    tran_state;
} TRANSACTION;

typedef struct reply {
    char code[L_RESPONSE];
    char operator[L_OPERID];
    char account[L_ACCNUM];
    char f_amount[L_AMOUNT];
    char t_amount[L_AMOUNT];
} REPLY;

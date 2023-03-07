/*----------------------------------------------------------------------------
 * Institution : City Polytechnic of Hong Kong
 * Course Title: M.Sc.(Computer Science)
 * Course-Year : 54802-2
 * Module Name : Workshop II
 * Module Code : CS1292
 * Group No.   : 1
 * File Name   : DBMS.C
 * Purpose     : A DBMS function package for implementation of the data
 *               manipulation functions for DB operations.
 *--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/*                Macro Constant Definitions                                */
/*--------------------------------------------------------------------------*/
#define TRUE                1           /* Boolean TRUE                     */
#define FALSE               0           /* Boolean FALSE                    */
#define FREE                0           /* Record is free                   */
#define OCCUPIED            1           /* Record is occupied               */
#define PERMS               0666        /* File RW access for owner, others */
#define SUCCESS             0           /* Successful DB operation          */
#define OPEN_ERROR          -1          /* File open error                  */
#define PUT_ERROR           -2          /* File put error                   */
#define GET_ERROR           -3          /* File get error                   */
#define DEL_ERROR           -4          /* File delete error                */
#define OUT_OF_MEM          -5          /* Out of memory heap               */
#define DB_REC_DUP          -6          /* Duplicate record found           */
#define DB_REC_NTF          -7          /* Data base record not found       */
#define IDX_REC_NTF         -8          /* Index record not found           */
#define MAX_FILES            5          /* Maximum no. of opened files      */
#define MAX_INDEX           10          /* Maximum no. of opened indices    */
#define MAX_RECLEN         256          /* Maximum record length            */
#define FNAME_LEN           13          /* File name length                 */
#define EOFLIST             -1          /* End of opened file list          */

/*----------------------------- End of File --------------------------------*/

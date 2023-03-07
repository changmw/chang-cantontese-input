/*-----------------------------------------------------------------------------
 * Institution : City Polytechnic of Hong Kong
 * Course      : M.Sc.(Computer Science)
 * Course-Year : 54802-2
 * Module Name : Workshop II
 * Module Code : CS1292
 * Group No.   : 1
 * File Name   : BACKEND.C
 * Purpose     : This is the backend process that handles all transactions
 *               from the frontend processes.
 *----------------------------------------------------------------------------*/

#include <ctype.h>
#include <string.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/time.h>
#include "dbms.h"
#include "banksch.h"
#include "backend.h"
#include "util.c"

struct customer cust, cust2;  /* Customer database work area */
struct operator oper;         /* Operator database work area */
struct tran_log tran;         /* Transaction database work area */
static int files[] = {CUSTOMER, OPERATOR, TRAN_LOG, EOFLIST};
struct qtype message,buff;
struct timeval tp;            /* Structures to get date */
struct timezone tzp;
struct tm *tm1;

int qid,i,j,rcode ;           /* Working variables */
int seq=0,operator;
char operator_id[3];          

/*
  this function pads a given string with the given padding characters
  used to pad "0" on the left of a given numeric string.

  example: char s[9]="12345";
           padl(s,9,'0');
           result would be "000012345";
*/
char *padl(instring, length, padchar)    
char *instring;
char padchar;
int length;
{
  int i, j, k;
  char outstring[80];

  for (i=0; i< (length-strlen(instring)); i++)
    *(outstring+i) = padchar;         
  for (j=0; j<strlen(instring); j++)
    *(outstring+i+j) = *(instring+j);
  strncpy(instring, outstring,length);
  printf("Instring%s\n",instring);    
  return(outstring);
}

void check_passwd(mtext)
/*
    Purpose : This function checks the password of the operator, if
	      it is correct, a response of '00' will be returned, else
              an error '04' will be returned.
    Input   : User entered password
    Output  : Status code
*/

char* mtext;
{
  char password[8];

  printf("Check passwd %s\n",mtext);
  memcpy(password,&mtext[3],8);
  password[8]=NULL;
     printf("key=%s*\n",operator_id);
     printf("Passwd=%s*\n",password);
  rcode = db_obtain(OPERATOR,01,operator_id,&oper);
  if (rcode == SUCCESS)
  {
       if (strcmp(password,oper.password) == 0) /* Password equal ? */
          strcpy(message.mtext,OK);             /* Yes */
       else
          strcpy(message.mtext,PWERR);          /* No */
  }
  else
       strcpy(message.mtext,REC1ERR);
}

void open_acct(mtext)
/*
    Purpose : This function opens an account, if it is not already exists, and
	      return an error code to the calling process
    Input   : Account number
    Output : Status code
*/

char* mtext;
{
  printf("Open account %s\n",mtext);
  memcpy(tran.operator_no,&mtext[0],3);
  memcpy(cust.customer_name,&mtext[9],50);
  cust.customer_name[50]=NULL;
  memcpy(cust.account_no,&mtext[3],6);
  cust.account_no[6]=NULL;
  printf("%sX%sX\n",cust.customer_name,cust.account_no);
  strcpy(cust.balance,"000000000");   /* Set initial balance to 0 */      
  rcode = db_obtain(CUSTOMER,01,cust.account_no,&cust);
  if (rcode == SUCCESS)
       strcpy(message.mtext,DUP);
  else
  {
     rcode = db_insert(CUSTOMER,&cust);
     if (rcode == SUCCESS)
     {
	  itoa(seq++,tran.tran_seq);
	  padl(tran.tran_seq,6,'0');
	  tran.tran_type[0]='1';
	  strcpy(tran.acct_no,cust.account_no);
	  strcpy(tran.tran_amount,"000000000");
	  strcpy(tran.upd_balance,"000000000");
	  rcode = db_insert(TRAN_LOG,&tran);  
          strcpy(message.mtext,OK);
     }
     else
          strcpy(message.mtext,SYSERR);
   }
}

void acct_inq(mtext)
/*
   Purpose : This function checks to see if an account exist. If exist, returns 
	     the current balance
   Input   : Account number
   Output  : Status code
	     Current balance (if account exists)
*/

char* mtext;
{
  char acctno[6];
  
  printf("Account inquiry %s\n",mtext);
  memcpy(tran.operator_no,&mtext[0],3);
  memcpy(acctno,&mtext[3],6);
  acctno[6]=NULL;
  printf("%s*\n",acctno);
  rcode = db_obtain(CUSTOMER,01,acctno,&cust);
  if (rcode==SUCCESS)
  {
       itoa(seq++,tran.tran_seq);
       padl(tran.tran_seq,6,'0');
       tran.tran_type[0]='2';
       rcode = db_insert(TRAN_LOG,&tran);  
       strcpy(message.mtext,OK);
       strcat(message.mtext,cust.balance);
       message.mtext[11]=NULL;
  }
  else
       strcpy(message.mtext,REC1ERR);
}

void deposit(mtext)
/*
   Purpose : This function handles the deposit request of the calling process
	     by adding the transaction amount to the current balance
   Input   : Account number
	     Amount
   Output  : Status code
	     Updated balance (if account exist)
*/

char* mtext;
{
   char acctno[6];
   char amount[9];
   int bal,amt;

   printf("Deposit %s\n",mtext);
   memcpy(tran.operator_no,&mtext[0],3);
   memcpy(acctno,&mtext[3],6);
   acctno[6]=NULL;
   memcpy(amount,&mtext[9],9);
   amount[9]=NULL;
   printf("%s*%s*\n",acctno,amount);
   rcode = db_obtain(CUSTOMER,01,acctno,&cust);
   if (rcode != SUCCESS)
       strcpy(message.mtext,REC1ERR);
   else
   {
       bal=atoi(cust.balance);
       amt=atoi(amount);
       printf("Amount=%dBeforeBal=%d\n",amt,bal);
       bal += amt;                                /* Update the balance */
       itoa(bal,cust.balance);
       padl(cust.balance,9,'0'); 
       rcode = db_update(CUSTOMER,&cust);
       itoa(seq++,tran.tran_seq);
       padl(tran.tran_seq,6,'0');
       tran.tran_type[0]='3';
       strcpy(tran.acct_no,cust.account_no);
       strcpy(tran.tran_amount,amount);
       strcpy(tran.upd_balance,cust.balance);
       rcode = db_insert(TRAN_LOG,&tran);         /* Write transaction log */
       strcpy(message.mtext,OK);
       strcat(message.mtext,cust.balance);
       message.mtext[11]=NULL;
   } 
}

void withdraw(mtext)
/*
   Purpose : This function handles the withdrawal request of the calling
	     process. It will first checks if the current balance can satisfy
	     the request, then deduct the current balance with the transaction
	     amount.
   Input   : Account number
	     Transaction amount
   Output  : Status code
	     Updated balance (if account exists and have sufficient balance)
*/

char* mtext;
{
   char acctno[6];
   char amount[9];
   int  bal,amt;

  printf("Withdraw %s\n",mtext);
  memcpy(tran.operator_no,&mtext[0],3);
   memcpy(acctno,&mtext[3],6);
   acctno[6]=NULL;
  memcpy(amount,&mtext[9],9);
  amount[9]=NULL;
  printf("%s*%s*\n",acctno,amount);
   rcode = db_obtain(CUSTOMER,01,acctno,&cust);
   if (rcode != SUCCESS)
       strncpy(message.mtext,REC1ERR);
   else
   {
       bal = atoi(cust.balance);
       amt = atoi(amount);
       if (bal < amt)
       {
           strcpy(message.mtext,BALERR);
	   strcat(message.mtext,cust.balance);
       }
       else
       {
           bal -= amt;
           itoa(bal,cust.balance);
	   padl(cust.balance,9,'0');
           rcode = db_update(CUSTOMER,&cust);
	   itoa(seq++,tran.tran_seq);
	   padl(tran.tran_seq,6,'0');
  	   tran.tran_type[0]='4';
	   strcpy(tran.acct_no,cust.account_no);
	   strcpy(tran.tran_amount,amount);
	   strcpy(tran.upd_balance,cust.balance);
	   rcode = db_insert(TRAN_LOG,&tran);  
           strcpy(message.mtext,OK);
	   strcat(message.mtext,cust.balance);
       }
       message.mtext[11]=NULL;
   }
}

void transfer(mtext)
/*
  Purpose : Handle transfer request of call process, if from account exists
	    and have sufficient balance
  Input   : From account number
	    To account number
	    Transaction amount
  Output  : Status code
	    From account balance (if transaction sucessful)
	    To account balance (if transaction successful)
*/

char* mtext;
{
   char acctno1[6];
   char acctno2[6];
   char amount[9];
   int  bal1,bal2,amt;

   printf("Transfer %s\n",mtext);
   memcpy(tran.operator_no,&mtext[0],3);
   memcpy(acctno1,&mtext[3],6);
   acctno1[6]=NULL;
   memcpy(acctno2,&mtext[9],6);
   acctno2[6]=NULL;
   memcpy(amount,&mtext[15],9);
   amount[9]=NULL;
   printf("%s*%s*%s*\n",acctno1,acctno2,amount);
   rcode = db_obtain(CUSTOMER,01,acctno1,&cust);
   if (rcode != SUCCESS)
       strcpy(message.mtext,REC1ERR);
   else
   {
       rcode = db_obtain(CUSTOMER,01,acctno2,&cust2);
       if (rcode != SUCCESS)
       {
          strncpy(message.mtext,REC2ERR,2);
	  message.mtext[2]=NULL;
       }
       else
       {
          bal1 = atoi(cust.balance);
          bal2 = atoi(cust2.balance);
          amt  = atoi(amount);
	  printf("%d %d %d\n",bal1,bal2,amt);
          if (bal1 < amt)
	  {
             strcpy(message.mtext,BALERR);
	     strcat(message.mtext,cust.balance);
	     message.mtext[11]=NULL;
	  }   
          else
          {
             bal1 -= amt;
             bal2 += amt;
             itoa (bal2,cust2.balance);
	     padl(cust2.balance,9,'0');
	     printf("* %s %s %d %d\n",cust.balance,cust2.balance,bal1,bal2);
	     printf("* %s %s \n",cust.account_no,cust2.account_no);
             rcode = db_update(CUSTOMER,&cust2);
	     rcode = db_obtain(CUSTOMER,01,acctno1,&cust);
             itoa (bal1,cust.balance);
	     padl(cust.balance,9,'0');
             rcode = db_update(CUSTOMER,&cust);
	     if (rcode != SUCCESS)
		printf("Not ok 2\n");
	     itoa(seq++,tran.tran_seq);
	     padl(tran.tran_seq,6,'0');
	     tran.tran_type[0]='5';
             strcpy(tran.acct_no,cust.account_no);
	     strcpy(tran.tran_amount,amount);
	     strcpy(tran.upd_balance,cust.balance);
	     rcode = db_insert(TRAN_LOG,&tran);  
	     itoa(seq++,tran.tran_seq);
	     padl(tran.tran_seq,6,'0');
             strcpy(tran.acct_no,cust2.account_no);
	     strcpy(tran.upd_balance,cust2.balance);
	     rcode = db_insert(TRAN_LOG,&tran);  
             strcpy(message.mtext,OK);
	     strcat(message.mtext,cust.balance);
	     message.mtext[11]=NULL;
             strcat(message.mtext,cust2.balance);
	     message.mtext[20]=NULL;
          }
       }
   }
}

void closeacct(mtext)
/*
  Purpose : Remove account from database
  Input   : Account number to close
  Output  : Status code
	    Closing balance
*/

char* mtext;
{
   char acctno[6];

   printf("Close account *%s\n",mtext);
   memcpy(tran.operator_no,&mtext[0],3);
   memcpy(acctno,&mtext[3],6);
   acctno[6]=NULL;
   printf("%s*\n",acctno);
   rcode = db_obtain(CUSTOMER,01,acctno,&cust);
   if (rcode != SUCCESS)
       strcpy(message.mtext,REC1ERR);
   else
   {
       rcode = db_delete(CUSTOMER);
       if (rcode != SUCCESS)
            strcpy(message.mtext,REC2ERR);
       else
       {
	  itoa(seq++,tran.tran_seq);
	  padl(tran.tran_seq,6,'0');
	  tran.tran_type[0]='6';
	  strcpy(tran.acct_no,cust.account_no);
	  strcpy(tran.tran_amount,"000000000");
	  strcpy(tran.upd_balance,cust.balance);
	  rcode = db_insert(TRAN_LOG,&tran);  
          strcpy(message.mtext,OK);
          strcat(message.mtext,cust.balance);
	  message.mtext[11]=NULL;
       }
   }
}

void main()
{
    char temp[9];
    db_open(files);
    gettimeofday(&tp,&tzp);
    tm1=gmtime(&tp);
    strcpy(tran.org_city_bra,"FFFFFF");
    strcpy(tran.tar_city_bra,"TTTTTT");
    strftime(temp,9,"%D",tm1); /* Get system date for tran log */
    tran.tran_date[0]=temp[6];
    tran.tran_date[1]=temp[7];
    tran.tran_date[2]=temp[0];
    tran.tran_date[3]=temp[1];
    tran.tran_date[4]=temp[3];
    tran.tran_date[5]=temp[4];
    tran.reserved[0]='\n';
    qid = msgget((key_t) 1234, IPC_CREAT | 0666);
    if (qid == -1)
    {
       perror ("msgget failed");
       exit(1);
    }
    printf("qid = %d\n",qid);
    while (1)
    {
       for (i=1;i<8;i++)
       {
	  if(msgrcv(qid,&buff,60,i,IPC_NOWAIT)!=-1)
	  {
         strncpy(operator_id,buff.mtext,3);
	 operator=atoi(operator_id);
         switch (i) 
	      {
                 case 1 : check_passwd(buff.mtext); break;
                 case 2 : open_acct(buff.mtext); break;
                 case 3 : acct_inq(buff.mtext); break;
                 case 4 : deposit(buff.mtext); break;
                 case 5 : withdraw(buff.mtext); break;
                 case 6 : transfer(buff.mtext); break;
		 case 7 : closeacct(buff.mtext); break;
              }
	      message.mtype=operator;
	      printf("Message=%s\n",message.mtext);
	      if (msgsnd(qid,&message,60,0) == -1)
	      {
		 perror("msgsnd failed");
		 exit(1);
              }
          }
      }
   }
}

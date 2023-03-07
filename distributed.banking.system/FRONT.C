#include <stdio.h>
#include <stdlib.h>
#include <curses.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include "menu.h"
#include "front.h"

#define REPEAT  99          /* repeat the entry */
#define DEBUG
#define CANNOT_SEND         -1
#define NO_RESPONSE         -2
#define COMMS_OK             1

MENU mainmenu;
BASE_FORM loginf, openf, ainqf, acwdf, adepf, atfrf, closf;
TRANSACTION transaction;
REPLY response;
int current_tran;
char operator_num [L_OPERID+1];

struct msgb {
  long mtype;
  char mtext[60];
} message;

/* init_form  to initialise all form values */
void init_form() {
    int i,j;                                              /* as looping index */
    /* login form */
    loginf.title = "<< PLEASE LOGIN >>";
    loginf.no_of_entry = 2;
    loginf.formx = 1;
    loginf.formy = 2;

    for (i = 0; i < loginf.no_of_entry; i++) {
        loginf.entry[i].e_echo = ECHO_ON;
    }

    loginf.entry[0].e_name = "Operator ID: ";
    loginf.entry[0].e_type = T_OPERID;
    loginf.entry[0].e_length = L_OPERID;
    loginf.entry[0].namex = 25;
    loginf.entry[0].namey = 16;
    loginf.entry[0].valuex = 43;
    loginf.entry[0].valuey = 16;

    loginf.entry[1].e_name = "Password:    ";
    loginf.entry[1].e_type = T_PASSWORD;
    loginf.entry[1].e_length = L_PASSWORD;
    loginf.entry[1].e_echo = ECHO_OFF;
    loginf.entry[1].namex = 25;
    loginf.entry[1].namey = 18;
    loginf.entry[1].valuex = 43;
    loginf.entry[1].valuey = 18;

    /* open form */
    openf.title = "***    OPEN ACCOUNT    ***";
    openf.no_of_entry = 2;
    openf.formx = 2;
    openf.formy = 11;

    for (i = 0; i < openf.no_of_entry; i++) {
        openf.entry[i].e_echo = ECHO_ON;
    }

    openf.entry[0].e_name = "Account Number : ";
    openf.entry[0].e_type = T_ACCNUM;
    openf.entry[0].e_length = L_ACCNUM;
    openf.entry[0].namex = 5;
    openf.entry[0].namey = 14;
    openf.entry[0].valuex = 21;
    openf.entry[0].valuey = 14;

    openf.entry[1].e_name = "Customer Name  : ";
    openf.entry[1].e_type = T_CUSTNAME;
    openf.entry[1].e_length = L_CUSTNAME;
    openf.entry[1].namex = 5;
    openf.entry[1].namey = 16;
    openf.entry[1].valuex = 21;
    openf.entry[1].valuey = 16;

    /* ainq form */
    ainqf.title = "***   ACCOUNT ENQUIRY  ***";
    ainqf.no_of_entry = 1;
    ainqf.formx = 1;
    ainqf.formy = 11;

    for (i = 0; i < ainqf.no_of_entry; i++) {
        ainqf.entry[i].e_echo = ECHO_ON;
    }

    ainqf.entry[0].e_name = "Account Number : ";
    ainqf.entry[0].e_type = T_ACCNUM;
    ainqf.entry[0].e_length = L_ACCNUM;
    ainqf.entry[0].namex = 5;
    ainqf.entry[0].namey = 14;
    ainqf.entry[0].valuex = 21;
    ainqf.entry[0].valuey = 14;

    /* acwd form */
    acwdf.title = "***   CASH WITHDRAWAL  *** ";
    acwdf.no_of_entry = 2;
    acwdf.formx = 1;
    acwdf.formy = 11;

    for (i = 0; i < acwdf.no_of_entry; i++) {
        acwdf.entry[i].e_echo = ECHO_ON;
    }

    acwdf.entry[0].e_name = "Account Number : ";
    acwdf.entry[0].e_type = T_ACCNUM;
    acwdf.entry[0].e_length = L_ACCNUM;
    acwdf.entry[0].namex = 5;
    acwdf.entry[0].namey = 14;
    acwdf.entry[0].valuex = 21;
    acwdf.entry[0].valuey = 14;

    acwdf.entry[1].e_name = "Amount         : ";
    acwdf.entry[1].e_type = T_AMOUNT;
    acwdf.entry[1].e_length = L_AMOUNT;
    acwdf.entry[1].namex = 5;
    acwdf.entry[1].namey = 16;
    acwdf.entry[1].valuex = 21;
    acwdf.entry[1].valuey = 16;

    /* adep form */
    adepf.title = "***    CASH DEPOSIT    *** ";
    adepf.no_of_entry = 2;
    adepf.formx = 1;
    adepf.formy = 11;

    for (i = 0; i < adepf.no_of_entry; i++) {
        adepf.entry[i].e_echo = ECHO_ON;
    }

    adepf.entry[0].e_name = "Account Number : ";
    adepf.entry[0].e_type = T_ACCNUM;
    adepf.entry[0].e_length = L_ACCNUM;
    adepf.entry[0].namex = 5;
    adepf.entry[0].namey = 14;
    adepf.entry[0].valuex = 21;
    adepf.entry[0].valuey = 14;

    adepf.entry[1].e_name = "Amount         : ";
    adepf.entry[1].e_type = T_AMOUNT;
    adepf.entry[1].e_length = L_AMOUNT;
    adepf.entry[1].namex = 5;
    adepf.entry[1].namey = 16;
    adepf.entry[1].valuex = 21;
    adepf.entry[1].valuey = 16;

    /* atfr form */
    atfrf.title = "***   FUND TRANSFER    ***";
    atfrf.no_of_entry = 3;
    atfrf.formx = 1;
    atfrf.formy = 11;

    for (i = 0; i < atfrf.no_of_entry; i++) {
        atfrf.entry[i].e_echo = ECHO_ON;
    }

    atfrf.entry[0].e_name = "From A/C Number: ";
    atfrf.entry[0].e_type = T_ACCNUM;
    atfrf.entry[0].e_length = L_ACCNUM;
    atfrf.entry[0].namex = 5;
    atfrf.entry[0].namey = 14;
    atfrf.entry[0].valuex = 21;
    atfrf.entry[0].valuey = 14;

    atfrf.entry[1].e_name = "To A/C Number  : ";
    atfrf.entry[1].e_type = T_ACCNUM2;
    atfrf.entry[1].e_length = L_ACCNUM;
    atfrf.entry[1].namex = 5;
    atfrf.entry[1].namey = 16;
    atfrf.entry[1].valuex = 21;
    atfrf.entry[1].valuey = 16;

    atfrf.entry[2].e_name = "Amount         : ";
    atfrf.entry[2].e_type = T_AMOUNT;
    atfrf.entry[2].e_length = L_AMOUNT;
    atfrf.entry[2].namex = 5;
    atfrf.entry[2].namey = 18;
    atfrf.entry[2].valuex = 21;
    atfrf.entry[2].valuey = 18;

    /* clos form */
    closf.title = "***   CLOSE ACCOUNT    ***";
    closf.no_of_entry = 1;
    closf.formx = 11;
    closf.formy = 1;

    for (i = 0; i < closf.no_of_entry; i++) {
        closf.entry[i].e_echo = ECHO_ON;
    }

    closf.entry[0].e_name = "Account Number : ";
    closf.entry[0].e_type = T_ACCNUM;
    closf.entry[0].e_length = L_ACCNUM;
    closf.entry[0].namex = 5;
    closf.entry[0].namey = 14;
    closf.entry[0].valuex = 21;
    closf.entry[0].valuey = 14;

} /* end init form */

void build_request(code) 
int code;
{
  int i, j;

  message.mtype=code;
  if (current_tran == OPER) 
      strncpy(message.mtext, loginf.entry[0].e_value, L_OPERID);
  else
      strncpy(message.mtext, operator_num, L_OPERID);
  switch (code) 
  {
    case OPER:
      strncpy(message.mtext+L_OPERID, loginf.entry[1].e_value, L_PASSWORD);
      break;
    case OPEN:
      strncpy(message.mtext+L_OPERID, openf.entry[0].e_value, L_ACCNUM);
      strncpy(message.mtext+L_OPERID+L_ACCNUM, transaction.tran_cust_name, L_CUSTNAME);
      break;
    case AINQ:
      strncpy(message.mtext+L_OPERID, ainqf.entry[0].e_value, L_ACCNUM);
      break;
    case ADEP:
      strncpy(message.mtext+L_OPERID, adepf.entry[0].e_value, L_ACCNUM);
      strncpy(message.mtext+L_OPERID+L_ACCNUM, transaction.tran_amount, L_AMOUNT);
      break;
    case ACWD:
      strncpy(message.mtext+L_OPERID, acwdf.entry[0].e_value, L_ACCNUM);
      strncpy(message.mtext+L_OPERID+L_ACCNUM, transaction.tran_amount, L_AMOUNT);
      break;
    case ATFR:
      strncpy(message.mtext+L_OPERID, atfrf.entry[0].e_value, L_ACCNUM);
      strncpy(message.mtext+L_OPERID+L_ACCNUM, atfrf.entry[1].e_value, L_ACCNUM);
      strncpy(message.mtext+L_OPERID+2*L_ACCNUM, transaction.tran_amount, L_AMOUNT);
      break;
    case CLOS:
      strncpy(message.mtext+L_OPERID, closf.entry[0].e_value, L_ACCNUM);
      break;
  }
}

/*
 * display_balance
 * function: 1. display the balance for transaction
 *
 * input   : response message
 * output  : a balance display on screen
 */

void display_balance ()
{
    int i,j;
    char bal[20];
    strncpy (bal, message.mtext+L_RESPONSE, L_AMOUNT);
    bal[10] = '\0';
    bal[9] = bal[8];
    bal[8] = bal[7];
    bal[7] = '.';
    for (i=0; i<6; i++)
       if (bal[i] == '0')
	   bal[i] = ' ';
       else break;	   
    outtextxy (33,7,"Current Balance: ");
    outtextxy (50,7,"$");
    outtextxy (51,7, bal);
}
/*
 * process_response
 * function: 1. compare the transaction to and from dbms
 *           2. handle the transaction response
 *           3. display appropriate message
 *
 * input   : NIL
 * output  : NIL
 */

void process_response ()
{
    int response_code,i,disp_line;
	char s[2];
    char e;

    i = 0;
	strncpy (s,message.mtext,L_RESPONSE);
    response_code = atoi(s);
    i += 2;
    if (current_tran == OPER)
       disp_line = 21;
	else if (current_tran == OPEN) 
	   disp_line = 5;
	else disp_line = 5;
       transaction.tran_state = response_code;
       switch (response_code) {
          case ACCEPT:
             if (current_tran != OPER)
                 outtextxy (33,disp_line,"Transaction Accepted");
                 if ( (current_tran == AINQ) || (current_tran == ADEP) ||
                      (current_tran == ACWD) || (current_tran == ATFR))
                       display_balance();
                 break;
            case REJECT:
                 outtextxy (33,disp_line,"Transaction Cancelled");
                 break;
            case SYSTEM_ERR:
                 outtextxy (33,5,"Transaction Cancelled");
                 outtextxy (33,6,"**** System Error");
                 break;
            case DUPLICATE_REC:
                 outtextxy (33,5,"Transaction Cancelled");
                 outtextxy (33,6,"**** Duplicate Record Found");
                 break;
            case REC1_NOT_FOUND:
                 if (current_tran == OPER) {
                    outtextxy (1,21,"**** Operator record not found");
                 }
                 else {
                    outtextxy (33,5,"Transaction Cancelled");
                    outtextxy (33,6,"**** Operated From Account not Found");
                 }
                 break;
            case EXCEED_BALANCE:
                 display_balance();
                 outtextxy (33,5,"Transaction Cancelled");
                 outtextxy (33,6,"**** Transaction Amount Exceeded Balance");
                 display_balance();
                 break;
            case TRAN_AMT_ERR:
                 outtextxy (33,5,"Transaction Cancelled");
                 outtextxy (33,6,"**** Transaction Amount Error");
                 break;
            case REC2_NOT_FOUND:
                 outtextxy (33,5,"Transaction Cancelled");
                 outtextxy (33,6,"**** Transfer To Account not Found");
                 break;
            case INVALID_OPER:
                 outtextxy (33,5,"Transaction Cancelled");
                 outtextxy (33,6,"**** Invalid Operator Identifier");
                 break;
            case PASSWORD_ERR:
                 outtextxy (1,21, "**** Invalid Password");
                 break;
            default:
                 outtextxy(33,5,"Transaction Cancelled");
                 outtextxy(33,6,"**** Unknown Reject Code");
                 break;
       }
    if (current_tran != OPER) {
       e = getch();
       clear_window (5,33,8,79);
    }
}   /* end of process_response */

int send_request()
{
  int request_qid;

  request_qid=msgget((key_t)REQUEST_QNAME, 0);
  if (request_qid==-1) {
    perror("Error getting qid!");
    return (CANNOT_SEND);
  }
  else
    msgsnd(request_qid, &message, 60, 0);
    return (COMMS_OK);
}

int receive_reply()
{
  int request_qid;

  request_qid=msgget((key_t)REQUEST_QNAME, 0);
  if (request_qid == -1)
     return (NO_RESPONSE);
  msgrcv(request_qid, &message, 60, atoi(loginf.entry[0].e_value), IPC_WAIT);
  return (COMMS_OK);
}

/*
 * authorise transaction to get authorization from host process 
 */
void authorise_transaction ()
{
int return_val;

    build_request(transaction.tran_code);
    
    return_val = send_request();
    if (return_val == CANNOT_SEND) {
        outtextxy (33,5,"Transaction Cancelled, cannot send");
        transaction.tran_state = REJECT;
    }
    else {                                                 /* send successful */
        return_val = receive_reply();
        if (return_val == NO_RESPONSE) {
            outtextxy (33,5,"Transaction Cancelled, timeout");
            transaction.tran_state = REJECT;
        }
        else {                                          /* receive a response */
            process_response();
            if ((transaction.tran_state == ACCEPT) && (current_tran == OPER)) {
                strcpy (operator_num, transaction.tran_operator_num);
            }
        }
    }
}

/*
 * check numeric format
 *  input: numeric string
 *         length of the numeric string
 * output: if correct length and all from 1 - 9  return 1
 *         else return 0;
 */
int check_numeric_format (s,l)
char * s;
int l;
{
 int i;
    if (strlen(s) < l)
        return 0;
    for (i = 0; i < strlen(s); i ++) {
        if ((s[i] < '0') || (s[i] > '9'))
           return 0;
    }
    return 1;
}

/*
 * put leading zero for a floating string
 * input  : amount string AFTER check amount format
 *          max length of amount with decimal point
 * output : amount string with decimal point removed and packed with
 *          leading zeros
 */
int put_leading_zeros (s, l)
char * s;
int l;
{
	int i,j,k;
	/*
	 * remove the decimal point and turn the string into digits
	 * replace the first character by '0'
	 */

	j = strlen (s);
	k = j - 1 - 2;
	for (i = k-1; i >=0; i --, k--)
		s[k] = s[i];

	/*
	 * pack the string with leading zeros
	 */
	j = strlen(s);
	for (i= 0; s[i] == ' '; i++)
		s[i] = '0';
        s[k] = '0';
	return 1;
}

/*
 * check amount format
 * input: amount string
 *        max amount length including decimal point
 * output: return AMT_OK if
 *                    all characters are from 1 to 9
 *                    only 1 decimal point
 *                    at most 2 decimal places
 *         return AMT_ERR if format error
 *         return AMT_ZERO if 0 is entered
 *         return AMT_EXCEED_MAX if value too large for xactn
 */

int check_amount_format (in_s, l)
char * in_s;
int l;
{
	char  s[10];
	int i,j,k, decimal_count, decimal_pos, start_digit, end_digit, end_digit_pos;
	float test_amount;

	i=0; j=strlen(in_s); decimal_count=0; decimal_pos=0;
	start_digit=0; end_digit =0; end_digit_pos = 0;
	strcpy (s,in_s);

        /*
         * check validity of all characters in the amount string
         */
        j = strlen(s);
        for (i=0; i<j-1; i ++) {
            if ((! isdigit(s[i])) && (s[i] != '.') && (s[i] != ' ') )
                return AMT_ERR;
        }
	/*
	 * left align the amount string by trim off the leading spaces
	 */
	j = strlen(s);
	for (k =0; k< j-1,s[k] == ' '|| (s[k] == '0'&&s[k+1]!='.') ; k++);
	for (i=0; k<=j-1; i++,k++)
		s[i] = s[k];
	s[i] = '\0';

	/*
	 * pack leading zeros  and  trim trailing spaces
	 */

	j = strlen (s);
	for (i = 0; i < j; i ++) {
		if ( (s[i] != ' ')    &&
			 (!isdigit(s[i])) &&
			 (s[i] != '.')        ) /* false if not SPACE or digit or DECIMAL */
			return (AMT_ERR);
		if ((! start_digit) && (s[i] == ' '))  /* pack with leading zeros */
			s[i] = '0';
		else if (s[i] == '.') {
			decimal_count ++;
			decimal_pos = i;
		}
		else if ((start_digit) && (!isdigit(s[i]))) {  /* end of amount before */
			end_digit_pos = i;                      /* end of string */
			end_digit = 1;
                        break;
		}
		else if (isdigit(s[i])) {
			if (end_digit)
				return (AMT_ERR);
			start_digit++;
		}
		else
			return (AMT_ERR);
	}

        /*
         * check size of the input amount
         */
	if (   ( (start_digit > l -1) &&
			 (decimal_count <=1))
		|| (decimal_count > 1) )
		return (AMT_ERR);

	if (end_digit)
	   s[end_digit_pos] = '\0'; /* to cut the trailing space */

/*
        j = strlen(s);
        for (i = j-1; i>=0, s[i] == '0'; i--) {
            s[i] = '\0';
        }
	    */

	/*
	 * convert the string to 99999.99 format
	 */

	j = strlen(s);

	if (decimal_count == 0) {
		s[j] = '.';
		s[j+1] ='0';
		s[j+2] ='0';
		s[j+3] ='\0';
	}
	else if (decimal_count == 1) {
		if (decimal_pos == (j-1)) {
			s[j]   = '0';
			s[j+1] = '0';
			s[j+2] = '\0';
		}
		else if (decimal_pos == (j-1-1)) {
			s[j]   = '0';
			s[j+1] = '\0';
		}
		else if (decimal_pos == (j-1-2)) {
		}
		else if (decimal_pos < (j-1-2))     /* too many decimal place */
			return (AMT_ERR);
	}
	else
		return (AMT_ERR);

	/*
	 * test if amount string is correct ie. not zero or exceed max
	 */

	j = strlen(s);
	test_amount = 0;
	for (i = 0; i<j; i ++) {
		if (isdigit(s[i]))
			test_amount = test_amount * 10 + (s[i] - '0');
	}
	test_amount = test_amount / 100;
	if (test_amount <= 0)
		return (AMT_ZERO);
	if (test_amount > 999999.99)
		return (AMT_EXCEED_MAX);

	/*
	 * right align the amount string
	 */

	j = strlen(s) -1;
	for (i=l-1; j>=0; i--,j--)
		s[i] = s[j];
	for (k=0; k<=i; k++)
		s[k] = ' ';
	s[l] = '\0';


	/*
	 * copy back the result string
	 */
	strcpy (in_s, s);
	return (AMT_OK);

}

/*
 * all_field_entered
 * function: to check if all the field in the form has entered a value
 * input   : NIL
 * output  : if all fields has value then return 1
 *           else return 0;
 */

int all_field_entered (a_form)
BASE_FORM * a_form;
{
    int i;
    char s[5];
    for (i =0; i<a_form->no_of_entry; i++) {
        if (strlen(a_form->entry[i].e_value) <=0)
           return 0;
    }
    return 1;
}

/*
 * reset_transaction
 * function: to initialise the TRANSACTION type record for each transaction
 * input   : NIL
 * output  : NIL
 */

void reset_transaction ()
{
    transaction.tran_code = 0;
    transaction.tran_cust_name[0] = '\0';
    transaction.tran_operator_num[0] = '\0';
    transaction.tran_operator_passwd[0] = '\0';
    transaction.tran_account1[0] = '\0';
    transaction.tran_account2[0] = '\0';
    transaction.tran_amount[0] = '\0';
    transaction.tran_state = 2;
    current_tran = 0;
}

/*
 * function:  clear_form
 *            to clear the past values in the required form
 * input :    the pointer of the form
 * output:    the values of the form will be cleared 
 */
void clear_form (a_form)
BASE_FORM * a_form;
{
   int i ;
   for (i=0; i<a_form->no_of_entry; i++) {
      a_form->entry[i].e_value[0] = '\0';
   }
}

/* process form to display and accept entries from user */
int process_form(a_form)
BASE_FORM *a_form;
{
    int i, quit_form, j, check_amt_retn;
    chtype ch;
    int num_entry;
    int return_val;
    char hh[10];

    move(1,1);
    attron(A_BOLD);
    outtextxy(27,11,a_form->title);
    attroff(A_BOLD);

    for (i = 0; i < a_form->no_of_entry; i ++) {
      outtextxy (a_form->entry[i].namex, a_form->entry[i].namey,
                 a_form->entry[i].e_name);
    }

    /* function key */
    attron(A_STANDOUT);
    outtextxy (05,23,"Ctrl-W");
    outtextxy (65,23,"ESC");
    attroff(A_STANDOUT);
    attron(A_BOLD);
    outtextxy (15,23,"CONFIRM");
    outtextxy (70,23,"CANCEL");
    attroff(A_BOLD);

    i = 0;
    quit_form = 0;
    return_val = 1;
    while ( !(quit_form) ) {
       return_val = intextxy (a_form->entry[i].valuex,
                              a_form->entry[i].valuey,
                              a_form->entry[i].e_value,
                              a_form->entry[i].e_length,
                              a_form->entry[i].e_echo);
       if (return_val == K_ESC) {
	  quit_form = 1;
	  return (return_val);
       }
       else {     /* check entry validity */
          if (a_form->entry[i].e_type == T_CUSTNAME){
             for (j=0; j<L_CUSTNAME; j++)
                 transaction.tran_cust_name[j] = ' ';
             transaction.tran_cust_name[L_CUSTNAME] = '\0';
             strncpy (transaction.tran_cust_name, a_form->entry[i].e_value,
                      strlen (a_form->entry[i].e_value));
          }
          else if (a_form->entry[i].e_type == T_AMOUNT) {
	     check_amt_retn = check_amount_format (a_form->entry[i].e_value,
						   a_form->entry[i].e_length);
             if (check_amt_retn == 1) {
                strcpy(transaction.tran_amount, a_form->entry[i].e_value);
                put_leading_zeros (transaction.tran_amount,
                                   a_form->entry[i].e_length);
                clear_window (5,30,7,30);
             }
             else {
	       	 if (check_amt_retn == AMT_EXCEED_MAX){
		     outtextxy (33,5,"Amount Exceed Maximum");
                 }
                 else if (check_amt_retn == AMT_ZERO) {
                     outtextxy (33,5,"Zero Amount Entered");
		 }
		 else
                     outtextxy (33,5,"Invalid Amount Entry");
		 outtextxy (33,6,"Please Entered Again.");
                 return_val = REPEAT;
             }
          }
          else {                                /* other types of digits */
             if (check_numeric_format(a_form->entry[i].e_value,
                                      a_form->entry[i].e_length) == 1 ) {
                clear_window (5,33,7,79);
                switch (a_form->entry[i].e_type) {
                   case T_ACCNUM:
                              strcpy (transaction.tran_account1,
                                       a_form->entry[i].e_value);
                              break;
                   case T_ACCNUM2:
                              strcpy (transaction.tran_account2,
                                       a_form->entry[i].e_value);
                              break;
                   case T_OPERID:
                              strcpy (transaction.tran_operator_num,
                                       a_form->entry[i].e_value);
                              break;
                   case T_PASSWORD:
                              strcpy (transaction.tran_operator_passwd,
                                      a_form->entry[i].e_value);
                              break;
                }
             }
             else {
		if (current_tran == OPER)
		   outtextxy (1,21,"**** Invalid Numeric Entry");
                else
                   outtextxy (33,5,"Invalid Numeric Entry");
                return_val = REPEAT;
             }
          }
       }
       if (return_val == K_CTRL_W) {
          if (all_field_entered(a_form) == 1) {
             authorise_transaction (&transaction);
             if (transaction.tran_state == ACCEPT)
                return(1);
          }
          else
                return_val == REPEAT;
       }
       else if (return_val == REPEAT)
          i = i;
       else
          i = (i+1) % a_form->no_of_entry;
    }   /* end while */
    ch = getch();
}   /* end function process_form */

void f_mainmenu() {
  switch (mainmenu.option) {
    case 1:  /* open account */
        clear_window(11,1,23,79);
        transaction.tran_code = OPEN;
	current_tran = transaction.tran_code;
        process_form(&openf);
        clear_form(&openf);
        clear_window(11,1,23,79);
        break;
    case 2:  /* enquiry */
        clear_window(11,1,23,79);
        transaction.tran_code = AINQ;
	current_tran = transaction.tran_code;
        process_form (&ainqf);
	clear_form(&ainqf);
        clear_window(11,1,23,79);
        break;
    case 3:  /* deposit */
        clear_window(11,1,23,79);
        transaction.tran_code = ADEP;
	current_tran = transaction.tran_code;
        process_form (&adepf);
	clear_form(&adepf);
        clear_window(11,1,23,79);
        break;
    case 4:  /* withdrawal */
        clear_window(11,1,23,79);
        transaction.tran_code = ACWD;
	current_tran = transaction.tran_code;
        process_form (&acwdf);
	clear_form(&acwdf);
        clear_window(11,1,23,79);
        break;
    case 5:  /* transfer */
        clear_window(11,1,23,79);
        transaction.tran_code = ATFR;
	current_tran = transaction.tran_code;
        process_form (&atfrf);
	clear_form(&atfrf);
        clear_window(11,1,23,79);
        break;
    case 6:  /* close account */
        clear_window(11,1,23,79);
        transaction.tran_code = CLOS;
	current_tran = transaction.tran_code;
        process_form (&closf);
	clear_form(&closf);
        clear_window(11,1,23,79);
        break;
    default:
        break;
  }
  reset_transaction();
}

/* init menu to initialise mainmenu */
void init_menu() {
    /* mainmenu */
    mainmenu.title = "Operation";
    mainmenu.noofentry= 6;
    mainmenu.entry[0] = "Open A/C";
    mainmenu.entry[1] = "Enquiry";
    mainmenu.entry[2] = "Deposit";
    mainmenu.entry[3] = "Withdrawal";
    mainmenu.entry[4] = "Transfer";
    mainmenu.entry[5] = "Close A/C";
    mainmenu.menux = 1;
    mainmenu.menuy = 2;
    mainmenu.func = f_mainmenu;
}   /* end init menu */

void main() {
  int looping, i;
  char s[80+1];

  init_menu ();
  init_form ();
  initscr ();
  keypad(stdscr, TRUE);
  raw();

  /* screen header */
  strcpy(s,"  CS1292 BANKING SYSTEM");
  for (i=strlen(s);i<80;i++) strcat(s," ");
  attron(A_REVERSE);
  outtextxy(0,0,s);
  attroff(A_REVERSE);

  transaction.tran_code = OPER;
  current_tran = OPER ;
  clear_window(1,1,23,79);
  clear_form (&loginf);
  while (process_form(&loginf) != K_ESC) {
     if (transaction.tran_state == ACCEPT) {
        clear_window(11,1,23,79) ;
        attron(A_REVERSE);               /* display the operator num */
        outtextxy(65,0,"Operator: ");
        outtextxy(76,0,loginf.entry[0].e_value);
        attroff(A_REVERSE);
        display_menu (&mainmenu, 1, 1);
        /* show main menu */
        clear_form (&loginf);
        clear_window (1,1,23,79);         /* clear the screen */
        attron(A_REVERSE);                /* hide the operator number */
        outtextxy(65,0,"          ");
        outtextxy(76,0,"   ");
        attroff(A_REVERSE);
        transaction.tran_code = OPER;
        current_tran = OPER ;
     }
     else
        outtextxy(60,5,"Access Denied!!"); 
  }
  clear_window(1,1,23,79);
  endwin();
  printf ("Thanks for using CS 1292 Banking System\n");
}


       IDENTIFICATION DIVISION.
       PROGRAM-ID. GL024P.
      *
      *
      *   PROGRAM : GL024P FISCAL YEAR END FILE PROGRCESSING
      *
      *   CS 0951-3   WORKSHOP I-III
      *
      *   COURSE      : BScCS
      *   COURSE CODE : 5421
      *   YEAR        :  3
      *   NAME        : CHAN MING LAP
      *   STUDENT ID  : 86032790
      *   GROUP       :  4
      *
      *
      *   DESRIPTION :
      *        This program is the last process at te end of each fiscal
      *   year. It prepares all files for the next fiscal year. In GLMASTF,
      *   each G/L account has two records, current and historical. The
      *   program updates the historical records by copying the information
      *   from their corresponding current records. Also, for all current
      *   records (i.e. GLMA-CURHIS = space), it computes the beginning
      *   balance, clears all period amounts, and sets GLMA-STATUS to 'D'
      *   if the new beginning balance is zero.
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. NCR-TOWER-800.
       OBJECT-COMPUTER. NCR-TOWER-800.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT GLSYSPF ASSIGN TO INPUT  'GLSYSPF'.
       SELECT GLMASTF ASSIGN TO RANDOM 'GLMASTF'
           ORGANIZATION IS INDEXED
           ACCESS MODE IS SEQUENTIAL
           RECORD KEY IS GLMA-KEY.

       DATA DIVISION.
       FILE SECTION.
       COPY "GLSYSPSL.DEF".
       COPY "GLMASTSL.DEF".
       
       WORKING-STORAGE SECTION.
       01  WS-MASTER-REC.
           05  WS-ACCTNO                        PIC 9(6).
           05  WS-CURHIS                        PIC X.
           05  WS-DESC                          PIC X(30).
           05  WS-DRCR                          PIC S9 COMP-3.
           05  WS-ACCTYPE                       PIC X.
           05  WS-BEGINBAL                      PIC S9(9)V99 COMP-3.
           05  WS-PERIODAMT                     PIC S9(9)V99 COMP-3
                                                    OCCURS 13 TIMES.
           05  WS-BUDGETAMT                     PIC S9(9)V99 COMP-3
                                                    OCCURS 12 TIMES.
           05  WS-CREATEDAT                     PIC 9(6).
           05  WS-STATUS                        PIC X.
       01  WS-SYSTEM-DATE.
           05  WS-YEAR                          PIC 99.
           05  WS-MONTH                         PIC 99.
           05  WS-DAY                           PIC 99.
       01  WS-SCREEN-DATE.
           05  WS-DAY                           PIC 99.
           05  FILLER                           PIC X VALUE '/'.
           05  WS-MONTH                         PIC 99.
           05  FILLER                           PIC X VALUE '/'.
           05  WS-YEAR                          PIC 99.
       01  WS-EOF-INDICATOR                     PIC 9 VALUE 0.
           88  EOF                              VALUE 1.
       01  WS-EXIST-IND                         PIC 9 VALUE 0.
           88  RECORD-NOT-EXIST                 VALUE 1.
       01  WS-OPTION                            PIC X.
           88  VALID-OPTION                     VALUE 'Y' 'N'.
       01  SUB1                                 PIC 99.

       PROCEDURE DIVISION.
       P000-MAIN.
           OPEN INPUT GLSYSPF
                I-O   GLMASTF.
           READ GLSYSPF.
           MOVE SPACE TO WS-OPTION.
           PERFORM P030-DISPLAY-MENU UNTIL VALID-OPTION.
           IF WS-OPTION = 'Y'
               DISPLAY 'PROCESSING IN PROGRESS' LINE 24 POSITION 29
               PERFORM P050-UPDATE-MASTER
                   UNTIL EOF.
           CLOSE GLSYSPF 
                 GLMASTF.
           STOP RUN.
           
       P030-DISPLAY-MENU.
           ACCEPT WS-SYSTEM-DATE FROM DATE.
           MOVE CORR WS-SYSTEM-DATE TO WS-SCREEN-DATE.
           DISPLAY 'GL024S'       LINE 1 POSITION 1 ERASE.
           DISPLAY GLSP-CONAME    LINE 1 POSITION 21.
           DISPLAY WS-SCREEN-DATE LINE 1 POSITION 73.
           DISPLAY 'GENEREAL LEDGER SYSTEM'  LINE 2 POSITION 30.
           DISPLAY 'FISCAL YEAR END FILE PROCESSING' LINE 3 POSITION 25.
           DISPLAY 'YOU HAVE TO CLEAR & CLOSE INCOME STATEMENT'
               LINE 9 POSITION 21.
           DISPLAY 'ACCOUNTS BEFORE FISCAL YEAR END FILE'
               LINE 10 POSITION 21.
           DISPLAY 'PROCESSING.' LINE 11 POSITION 21.
           DISPLAY 'DO YOU WANT TO CONTINUE ? (Y/N)'
               LINE 13 POSITION 21.
           ACCEPT WS-OPTION LINE 13 POSITION 53 TAB NO BEEP.

       P050-UPDATE-MASTER.
           READ GLMASTF NEXT RECORD
               AT END MOVE 1 TO WS-EOF-INDICATOR.
           IF NOT EOF
               MOVE GLMA-RECORD TO WS-MASTER-REC
               PERFORM P150-UPDATE-CURRENT
               PERFORM P100-UPDATE-HISTORY.

       P100-UPDATE-HISTORY.
           READ GLMASTF NEXT RECORD
               AT END MOVE 1 TO WS-EOF-INDICATOR. 
           IF NOT EOF
               MOVE 'H' TO WS-CURHIS
               MOVE WS-MASTER-REC TO GLMA-RECORD
               REWRITE GLMA-RECORD.

       P150-UPDATE-CURRENT.
           MOVE SPACE TO GLMA-CURHIS.
           COMPUTE GLMA-BEGINBAL = GLMA-BEGINBAL +                    
                                   GLMA-PERIODAMT (13).
           PERFORM P200-CLEAR-PERIOD-AMT VARYING SUB1
               FROM 1 BY 1 UNTIL SUB1 > 13.
           PERFORM P250-CLEAR-BUDGET-AMT VARYING SUB1
               FROM 1 BY 1 UNTIL SUB1 > 13.
           ACCEPT WS-SYSTEM-DATE FROM DATE.
           MOVE WS-SYSTEM-DATE TO GLMA-CREATEDAT.
           IF GLMA-BEGINBAL = 0
               MOVE 'D' TO GLMA-STATUS.
           REWRITE GLMA-RECORD.
      
       P200-CLEAR-PERIOD-AMT.
           MOVE 0 TO GLMA-PERIODAMT (SUB1).

       P250-CLEAR-BUDGET-AMT.
           MOVE 0 TO GLMA-BUDGETAMT (SUB1).


       IDENTIFICATION DIVISION.
       PROGRAM-ID.       GL015P-TRAN-JRN-ENTRY.
       AUTHOR.           LO YAT WAH.
      *
      *****************************************************************
      ***                                                           ***
      ***  Program function :                                       ***
      ***                                                           ***
      ***          This pragram aims to accept transactions and     ***
      ***  store it into Transaction Journal File (GLJRNLF).        ***
      ***  During transaction input, the transaction will firstly   ***
      ***  be validated and error message will display in case of   ***
      ***  wrong transactions is encountered and the transaction    ***
      ***  will then be rejected.                                   ***
      ***                                                           ***
      *****************************************************************
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  NCR-800.
       OBJECT-COMPUTER.  NCR-800.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT GLSYSPF   ASSIGN       TO INPUT 'GLSYSPF'.
           SELECT GLMASTF   ASSIGN       TO RANDOM 'GLMASTF'
                            ORGANIZATION IS INDEXED
                            ACCESS MODE  IS DYNAMIC
                            RECORD KEY   IS GLMA-KEY.
           SELECT GLJRNLF   ASSIGN       TO RANDOM 'GLJRNLF'.
           SELECT GLTEMPF   ASSIGN       TO RANDOM 'GLTEMPF'.
      *
       DATA DIVISION.
       FILE SECTION.
      *
      *  System parameter file
           COPY "GLSYSPSL.DEF".
      *
      *  General Ledger Master file
           COPY "GLMASTSL.DEF".
      *
      *  Transaction journal file
           COPY "GLJRNLSL.DEF".
      *
      *  Temporary file to store voucher input
       FD  GLTEMPF
           BLOCK CONTAINS 8 RECORDS
           RECORD CONTAINS 81 CHARACTERS
           LABEL RECORDS ARE STANDARD.
      *
       01  GLTP-RECORD.
           05  GLTP-OVERWRITE     PIC X.
           05  GLTP-REC.
               10  GLTP-VOUCHERNO     PIC X(6).
               10  GLTP-VOUCHERDT     PIC 9(6).
               10  GLTP-PARTICULAR    PIC X(40).
               10  GLTP-SOURCE        PIC XX.
               10  GLTP-AMOUNT        PIC S9(9)V99.
               10  GLTP-ACCTNO        PIC 9(6).
               10  GLTP-SYSDATE       PIC 9(6).
               10  GLTP-FILLER        PIC X(2).
      *
       WORKING-STORAGE SECTION.
      *
       01  WS-VARIABLE.
           05  WS-VOUCHERNO           PIC X(6).
           05  WS-INPUTDATE.
               10  WS-IDD             PIC 9(2).
               10  WS-IMM             PIC 9(2).
               10  WS-IYY             PIC 9(2).
           05  WS-VOUCHERDT.
               10  WS-VYEAR           PIC 9(2).
               10  WS-VMONTH          PIC 9(2).
               10  WS-VDAY            PIC 9(2).
           05  WS-SYSDATE.
               10  WS-SYEAR           PIC 9(2).
               10  WS-SMONTH          PIC 9(2).
               10  WS-SDAY            PIC 9(2).
           05  WS-DIS-DATE.
               10  WS-DIS-DD          PIC Z9.
               10  FILLER             PIC X      VALUE "/".
               10  WS-DIS-MM          PIC Z9.
               10  FILLER             PIC X      VALUE "/".
               10  WS-DIS-YY          PIC Z9.
           05  WS-MONTHDAY            PIC X(24)  VALUE
               "312931303130313130313031".
           05  WS-MONTHDAY-R REDEFINES WS-MONTHDAY.
               10  WS-DAYINMTH        PIC 99     OCCURS 12.
           05  WS-SCN-LINE-1.
               10  WS-LINE-11         PIC X(80)  VALUE ALL "-".
           05  WS-SCN-LINE-2.
               10  WS-LINE-2          PIC X(12)  VALUE ALL "=".
           05  WS-ACCTNO              PIC 9(6).
           05  WS-PARTICULAR          PIC X(40).
           05  WS-DEBIT               PIC S9(8)V99.
           05  WS-CREDIT              PIC S9(8)V99.
           05  WS-TOT-CR              PIC 9(9)V99.
           05  WS-TOT-DR              PIC 9(9)V99.
           05  WS-AMOUNT              PIC S9(9)V99.
           05  WS-LINE-NUMBER         PIC 99.
           05  WS-CONAME              PIC X(40).
           05  WS-SYS-NAME            PIC X(21)  VALUE
               "GENERAL LEDGER SYSTEM".
           05  WS-PRG-NAME            PIC X(26)  VALUE
               "TRANSACTION JOURNAL ENTRY".
           05  WS-SLASH               PIC X      VALUE "/".
           05  WS-EDIT                PIC -(8)9.99  BLANK WHEN ZERO.
      *
       01  WS-FLAG.
           05  WS-DATA-OK             PIC X.
           05  WS-VOUCH-OK            PIC X.
           05  WS-EOF                 PIC X.
           05  WS-TEMP-EOF            PIC X.
           05  WS-MAS-VALID           PIC X.
           05  WS-DATE-VALID          PIC X.
           05  WS-OVERWRITE           PIC X.
           05  WS-ACCT-OK             PIC X.
           05  WS-AMT-OK              PIC X.
           05  WS-CREDIT-OK           PIC X.
      *
       01  WS-ERR-MESSAGE.
           05  WS-ERR-MESS-1          PIC X(51)  VALUE
               "ERR-070 : INVALID VOUCHER DATE".
           05  WS-ERR-MESS-2          PIC X(51)  VALUE
               "ERR-080 : LINE LIMIT EXCEEDED".
           05  WS-ERR-MESS-3          PIC X(51)  VALUE
               "         VOUCHER REJECTED".
           05  WS-ERR-MESS-4          PIC X(51)  VALUE
               "PRESS ANY KEY TO QUIT".
           05  WS-ERR-MESS-5          PIC X(51)  VALUE
               "ERR-090 : ACCOUNT NOT FOUND IN GLMASTF".
           05  WS-ERR-MESS-6          PIC X(51)  VALUE
               "ERR-100 : INVALID DEBIT AMOUNT".
           05  WS-ERR-MESS-7          PIC X(51)  VALUE
               "ERR-110 : INVALID CREDIT AMOUNT".
           05  WS-ERR-MESS-8          PIC X(60)  VALUE
               "ERR-060 : CREDITS TOTAL AND DEBIT TOTALS NOT BALANCED".
           05  WS-ERR-MESS-9          PIC X(51)  VALUE
               "PRESS ANY KEY TO REINPUT VOUCHER".
           05  WS-ERR-MESS-10         PIC X(51)  VALUE
               "ERR-050 : ERROR IN REWRITING GLMASTR".
      *
       01  WS-MESSAGE.
           05  WS-MESS-1              PIC X(51)  VALUE
               "VOUCHER ALREADY EXIST, OVERWRITE IT ? (Y,N) ".
           05  WS-MESS-2              PIC X(51)  VALUE
               "VOUCHER UPDATED TO GLJRNLF".
           05  WS-MESS-3              PIC X(30)  VALUE
               "PRESS ANY KEY TO CONTINUE ...".
      /
       PROCEDURE DIVISION.
      *
       PROGRAM-SUMMARY.
      *
           OPEN I-O     GLMASTF.
           MOVE "000000" TO WS-VOUCHERNO.
           PERFORM P100-START-INPUT UNTIL WS-VOUCHERNO = SPACE.
           PERFORM P999-END.
      *
       P100-START-INPUT.
           OPEN INPUT  GLSYSPF
                I-O    GLJRNLF
                OUTPUT GLTEMPF.
           PERFORM P110-INITIAL.
           PERFORM P120-DIS-SCN.
           PERFORM P200-ACPT-INPUT.
           IF   WS-VOUCHERNO NOT = SPACE
                PERFORM P300-PROCESS-INPUT.
           CLOSE GLSYSPF.
      *
       P110-INITIAL.
           PERFORM P510-READ-PARA.
           MOVE GLSP-CONAME TO WS-CONAME.
           MOVE 0 TO WS-CREDIT WS-DEBIT WS-TOT-CR WS-TOT-DR.
           MOVE 9 TO WS-LINE-NUMBER.
           MOVE SPACE TO WS-DATA-OK WS-VOUCH-OK WS-EOF
                         WS-TEMP-EOF WS-OVERWRITE WS-ACCT-OK
                         WS-AMT-OK WS-CREDIT-OK.
      *
       P120-DIS-SCN.
           ACCEPT WS-SYSDATE FROM DATE.
           DISPLAY WS-CONAME         LINE  1 POSITION 23, ERASE
                   WS-SDAY           LINE  1 POSITION 73
                   WS-SLASH          LINE  1 POSITION 75
                   WS-SMONTH         LINE  1 POSITION 76
                   WS-SLASH          LINE  1 POSITION 78
                   WS-SYEAR          LINE  1 POSITION 79
                   WS-SYS-NAME       LINE  2 POSITION 30
                   WS-PRG-NAME       LINE  3 POSITION 28
                   "VOUCHER NO: "    LINE  5 POSITION 1
                   "VOUCHER DATE (DDMMYY) : "
                                     LINE  5 POSITION 50
                   WS-SCN-LINE-1     LINE  6 POSITION 1
                   "A/C NO."         LINE  7 POSITION 2
                   "A/C PARTICULAR"  LINE  7 POSITION 24
                   "DEBIT ($)"       LINE  7 POSITION 55
                   "CREDIT ($)"      LINE  7 POSITION 68
                   WS-SCN-LINE-1     LINE  8 POSITION 1
                   WS-SCN-LINE-1     LINE 20 POSITION 1
                   "DATA OK (Y,N) ?" LINE 21 POSITION 1.
      *
       P200-ACPT-INPUT.
           MOVE "N" TO WS-VOUCH-OK.
           PERFORM P210-ACPT-VOUCH UNTIL WS-VOUCH-OK = "Y".
           IF WS-VOUCHERNO NOT = SPACE
              MOVE 999999 TO WS-ACCTNO
              PERFORM P250-ACPT-DET UNTIL WS-ACCTNO = 0.
      *
      *  Accept and check voucher number and date
      *
       P210-ACPT-VOUCH.
           MOVE "N" TO WS-DATA-OK.
           PERFORM P220-ACPT-VOUCH-DET UNTIL WS-DATA-OK = "Y".
           PERFORM P230-CHECK-VOUCH.
      *
       P220-ACPT-VOUCH-DET.
           DISPLAY SPACE LINE 5 POSITION 13 SIZE 6
                   SPACE LINE 5 POSITION 73 SIZE 8.
           ACCEPT WS-VOUCHERNO LINE 5 POSITION 13 NO BEEP.
           IF WS-VOUCHERNO NOT = SPACE
              ACCEPT WS-INPUTDATE LINE 5 POSITION 73 NO BEEP
              MOVE WS-IDD TO WS-DIS-DD
              MOVE WS-IMM TO WS-DIS-MM
              MOVE WS-IYY TO WS-DIS-YY
              DISPLAY WS-DIS-DATE LINE 5 POSITION 73.
           MOVE SPACE TO WS-DATA-OK.
           PERFORM P221-ACPT-OK UNTIL WS-DATA-OK = "Y"
                                   OR WS-DATA-OK = "N".
      *
       P221-ACPT-OK.
           DISPLAY SPACE LINE 21 POSITION 20 SIZE 1.
           ACCEPT WS-DATA-OK LINE 21 POSITION 20 NO BEEP.
      *
       P230-CHECK-VOUCH.
           MOVE SPACE TO WS-VOUCH-OK.
           MOVE WS-IYY TO WS-VYEAR.
           MOVE WS-IMM TO WS-VMONTH.
           MOVE WS-IDD TO WS-VDAY.
           IF   WS-VOUCHERNO = SPACE
                MOVE "Y" TO WS-VOUCH-OK
           ELSE IF   WS-VOUCHERDT < GLSP-POSDATE OR
                     WS-VOUCHERDT > WS-SYSDATE
                     DISPLAY WS-ERR-MESS-1 LINE 24 BEEP
                     MOVE "N" TO WS-VOUCH-OK
                ELSE PERFORM P231-CHECK-DATE
                     IF    WS-DATE-VALID = "Y"
                           DISPLAY SPACE LINE 24 SIZE 80
                           PERFORM P520-READ-GLJR
                                  UNTIL WS-VOUCHERNO = GLJR-VOUCHERNO
                                     OR WS-EOF = "Y"
                           IF   WS-VOUCHERNO = GLJR-VOUCHERNO
                                DISPLAY WS-MESS-1 LINE 24
                                PERFORM P232-ACPT-RES UNTIL
                                        WS-VOUCH-OK = "Y"
                                     OR WS-VOUCH-OK = "N"
                                MOVE WS-VOUCH-OK TO WS-OVERWRITE
                           ELSE MOVE "Y" TO WS-VOUCH-OK
                                MOVE "N" TO WS-OVERWRITE
                      ELSE DISPLAY WS-ERR-MESS-2 LINE 24 BEEP
                           MOVE "N" TO WS-VOUCH-OK.
      *
       P231-CHECK-DATE.
            MOVE "Y" TO WS-DATE-VALID.
            IF WS-VMONTH NOT > 0 OR WS-VMONTH > 12 OR
               WS-VDAY = 0 OR WS-VDAY > WS-DAYINMTH (WS-VMONTH)
               MOVE "N" TO WS-DATE-VALID.
      *
       P232-ACPT-RES.
           DISPLAY SPACE LINE 24 POSITION 52 SIZE 1.
           ACCEPT WS-VOUCH-OK LINE 24 POSITION 52 NO BEEP.
      *
      *  Transaction detail acceptance and validating routines
      *
       P250-ACPT-DET.
           MOVE "N" TO WS-DATA-OK.
           PERFORM P260-ACPT-LINE UNTIL WS-DATA-OK = "Y".
           IF   WS-ACCTNO NOT = 0
                PERFORM P270-PROCESS-LINE.
      *
       P260-ACPT-LINE.
           IF   WS-LINE-NUMBER > 19
                DISPLAY WS-ERR-MESS-2 LINE 23 BEEP
                        WS-ERR-MESS-3 LINE 24 POSITION 1
                        WS-ERR-MESS-4 LINE 24 POSITION 40
                ACCEPT WS-DATA-OK
                PERFORM P999-END.
           MOVE "N" TO WS-ACCT-OK WS-AMT-OK.
           MOVE SPACE TO WS-DATA-OK.
           PERFORM P261-ACPT-ACCT UNTIL WS-ACCT-OK = "Y".
           IF   WS-ACCTNO NOT = 0
                PERFORM P262-ACPT-AMT UNTIL WS-AMT-OK = "Y".
           PERFORM P221-ACPT-OK UNTIL WS-DATA-OK = "Y"
                                OR    WS-DATA-OK = "N".
           IF   WS-DATA-OK = "Y"
                ADD 1 TO WS-LINE-NUMBER.
      *
       P261-ACPT-ACCT.
           DISPLAY SPACE LINE WS-LINE-NUMBER POSITION 2 SIZE 80.
           ACCEPT WS-ACCTNO LINE WS-LINE-NUMBER POSITION 2 CONVERT
                  NO BEEP.
           DISPLAY SPACE LINE 24 POSITION 1 SIZE 80.
           IF   WS-ACCTNO = 0
                MOVE "Y" TO WS-ACCT-OK
           ELSE MOVE WS-ACCTNO TO GLMA-ACCTNO
                MOVE SPACE TO GLMA-CURHIS
                PERFORM P530-READ-MAST
                IF   WS-MAS-VALID = "N"
                     DISPLAY WS-ERR-MESS-5 LINE 24 BEEP
                ELSE DISPLAY SPACE LINE 24 POSITION 1 SIZE 80
                     ACCEPT WS-PARTICULAR LINE WS-LINE-NUMBER
                             POSITION 12
                     MOVE "Y" TO WS-ACCT-OK.
      *
       P262-ACPT-AMT.
           DISPLAY SPACE LINE WS-LINE-NUMBER POSITION 54 SIZE 26.
           ACCEPT WS-DEBIT LINE WS-LINE-NUMBER POSITION 54
                  CONVERT NO BEEP.
           MOVE WS-DEBIT TO WS-EDIT.
           DISPLAY WS-EDIT LINE WS-LINE-NUMBER POSITION 54.
           IF   WS-DEBIT < 0
                DISPLAY WS-ERR-MESS-6 LINE 24 BEEP
           ELSE DISPLAY SPACE LINE 24 POSITION 1 SIZE 50
                IF   WS-DEBIT = 0
                     MOVE SPACE TO WS-CREDIT-OK
                     PERFORM P263-ACPT-CREDIT UNTIL WS-CREDIT-OK = "Y"
                     MOVE "Y" TO WS-AMT-OK
                ELSE MOVE "Y" TO WS-AMT-OK.
      *
       P263-ACPT-CREDIT.
           DISPLAY SPACE LINE WS-LINE-NUMBER POSITION 67 SIZE 13.
           ACCEPT WS-CREDIT LINE WS-LINE-NUMBER POSITION 67
                  CONVERT NO BEEP.
           MOVE WS-CREDIT TO WS-EDIT.
           DISPLAY WS-EDIT LINE WS-LINE-NUMBER POSITION 67.
           IF   WS-CREDIT < 0
                DISPLAY WS-ERR-MESS-7 LINE 24 BEEP
           ELSE DISPLAY SPACE LINE 24 POSITION 1 SIZE 80
                MOVE "Y" TO WS-CREDIT-OK.
      *
      *  Store transaction to temporary file
      *
       P270-PROCESS-LINE.
           MOVE WS-VOUCHERNO TO GLTP-VOUCHERNO.
           MOVE WS-VOUCHERDT TO GLTP-VOUCHERDT.
           MOVE WS-ACCTNO TO GLTP-ACCTNO.
           MOVE WS-PARTICULAR TO GLTP-PARTICULAR.
           MOVE WS-SYSDATE TO GLTP-SYSDATE.
           MOVE "GL" TO GLTP-SOURCE.
           IF   WS-DEBIT > 0
                MOVE WS-DEBIT TO GLTP-AMOUNT
                ADD WS-DEBIT TO WS-TOT-DR
           ELSE MULTIPLY WS-CREDIT BY -1 GIVING WS-AMOUNT
                MOVE WS-AMOUNT TO GLTP-AMOUNT
                ADD WS-CREDIT TO WS-TOT-CR.
           MOVE WS-OVERWRITE TO GLTP-OVERWRITE.
           MOVE SPACE TO WS-OVERWRITE.
           PERFORM P550-WRITE-GLTP.
      *
      *  Validate and process transactions after a whole voucher is
      *      entered
      *
       P300-PROCESS-INPUT.
           MOVE WS-TOT-DR TO WS-EDIT.
           DISPLAY WS-EDIT LINE 22 POSITION 54.
           MOVE WS-TOT-CR TO WS-EDIT.
           DISPLAY WS-EDIT LINE 22 POSITION 68.
           IF   WS-TOT-DR NOT = WS-TOT-CR
                DISPLAY WS-ERR-MESS-8 LINE 23 BEEP
                        WS-ERR-MESS-9 LINE 24 POSITION 1
                        ACCEPT WS-DATA-OK LINE 24 POSITION 40 NO BEEP
                               OFF
                        CLOSE GLTEMPF
                              GLJRNLF
           ELSE PERFORM P310-COPY-RECORD
                DISPLAY WS-MESS-2 LINE 24 POSITION 1
                DISPLAY WS-MESS-3 LINE 24 POSITION 45
                ACCEPT WS-DATA-OK LINE 24 POSITION 80 NO BEEP OFF.
      *
       P310-COPY-RECORD.
           CLOSE GLTEMPF.
           OPEN INPUT GLTEMPF.
           PERFORM P540-READ-GLTP.
           PERFORM P320-MOVE-RECORD UNTIL WS-TEMP-EOF = "Y".
           CLOSE GLTEMPF.
           CLOSE GLJRNLF.
      *
       P320-MOVE-RECORD.
           IF   GLTP-OVERWRITE = "Y"
                PERFORM P330-REWRITE-RECORD.
           CLOSE GLJRNLF.
           OPEN EXTEND GLJRNLF.
           MOVE GLTP-REC TO GLJR-RECORD.
           PERFORM P560-WRITE-GLJR.
           PERFORM P350-UPDATE-MAST.
           PERFORM P540-READ-GLTP.
      *
       P330-REWRITE-RECORD.
           CLOSE GLJRNLF.
           OPEN I-O GLJRNLF.
           MOVE "N" TO WS-EOF.
           PERFORM P520-READ-GLJR.
           PERFORM P340-DELETE-RECORD UNTIL WS-EOF = "Y".
      *
       P340-DELETE-RECORD.
           IF   GLJR-VOUCHERNO = GLTP-VOUCHERNO
                PERFORM P570-REWRITE-GLJR.
           PERFORM P520-READ-GLJR.
      *
       P350-UPDATE-MAST.
            MOVE GLJR-ACCTNO TO GLMA-ACCTNO.
            MOVE SPACE TO GLMA-CURHIS.
            PERFORM P530-READ-MAST.
            IF   GLMA-STATUS = "D"
                 MOVE SPACE TO GLMA-STATUS
                 PERFORM P580-REWRITE-MAST.
      *
      *  Read, Write routines
      *
       P510-READ-PARA.
           READ GLSYSPF RECORD.
      *
       P520-READ-GLJR.
           READ GLJRNLF RECORD AT END MOVE "Y" TO WS-EOF.
      *
       P530-READ-MAST.
           MOVE "Y" TO WS-MAS-VALID
           READ GLMASTF RECORD INVALID KEY
                MOVE "N" TO WS-MAS-VALID.
      *
       P540-READ-GLTP.
           READ GLTEMPF RECORD AT END MOVE "Y" TO WS-TEMP-EOF.
      *
       P550-WRITE-GLTP.
           WRITE GLTP-RECORD.
      *
       P560-WRITE-GLJR.
           WRITE GLJR-RECORD.
      *
       P570-REWRITE-GLJR.
           REWRITE GLJR-RECORD FROM SPACE.
      *
       P580-REWRITE-MAST.
            REWRITE GLMA-RECORD INVALID KEY
                    DISPLAY WS-ERR-MESS-10 LINE 23
                            GLMA-KEY LINE 23 POSITION 50.
      *
       P999-END.
           CLOSE GLMASTF.
           STOP RUN.

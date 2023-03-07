       IDENTIFICATION DIVISION.
      *
      *
      *    Program Name : G/L Activity List
      *    System Name  : General Ledger
      *
      *    Program Description :
      *         This program reports the activities of each G/L account
      *    for a selected range of periods.  It prompts for the
      *    beginning date and the ending date (by months).  The output
      *    gives the transaction details of each G/L account that have
      *    been made within the selected range of periods.
      *
      *    Input file(s)  : GLT001F, GLMASTF, GLSYSPF
      *    Output file(s) : GL019R
      *
      *
       PROGRAM-ID.      GL019P-PRINT-ACTIVITY-LIST.
       AUTHOR.          CHAN-HON-PIU.
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.   NCR-T800.
       OBJECT-COMPUTER.   NCR-T800.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT GLJRNLHF ASSIGN TO INPUT 'GLT001F'.
       SELECT GLSYSPF ASSIGN TO INPUT 'GLSYSPF'.
       SELECT GLMASTF ASSIGN TO RANDOM 'GLMASTF'
              ACCESS MODE IS DYNAMIC
              ORGANIZATION IS INDEXED
              RECORD KEY IS GLMA-KEY.
       SELECT GLACTLST ASSIGN TO PRINT 'GL019R'.
      *
       DATA DIVISION.
       FILE SECTION.
       COPY "GLMASTSL.DEF".
       COPY "GLSYSPSL.DEF".
       COPY "GLJRNHSL.DEF".
      *
       FD  GLACTLST
           LABEL RECORDS ARE OMITTED
           DATA RECORD IS REPORT-LINE.
       01  REPORT-LINE              PIC X(80).
      *
       WORKING-STORAGE SECTION.
       01  WS-HEADING-1.
           05  FILLER           PIC X(6)  VALUE 'GL019R'.
           05  FILLER           PIC X(14) VALUE SPACES.
           05  WS-COMPANY-NAME  PIC X(40).
           05  FILLER           PIC X(12).
           05  WS-REPORT-DATE.
               10  WS-REPORT-DAY      PIC 99/.
               10  WS-REPORT-MONTH    PIC 99/.
               10  WS-REPORT-YEAR     PIC 99.
      *
       01  WS-HEADING-2.
           05  FILLER           PIC X(30) VALUE SPACES.
           05  FILLER           PIC X(17) VALUE
               'G/L ACTIVITY LIST'.
           05  FILLER           PIC X(25) VALUE SPACES.
           05  FILLER           PIC X(5)  VALUE 'PAGE '.
           05  WS-PAGE-NUMBER   PIC 9(3).
      *
       01  WS-HEADING-3.
           05  FILLER           PIC X(11) VALUE 'A/C NO.  : '.
           05  WS-ACCOUNT-NUMBER  PIC X(6).
           05  FILLER           PIC X(8)  VALUE SPACES.
           05  FILLER           PIC X(18) VALUE 'A/C DESCRIPTION : '.
           05  WS-DESCRIPTION   PIC X(30).
           05  FILLER           PIC X(7)  VALUE SPACES.
      *
       01  WS-HEADING-4.
           05  FILLER           PIC X(10) VALUE 'DATE'.
           05  FILLER           PIC X(49) VALUE 'PARTICULAR'.
           05  FILLER           PIC X(14) VALUE 'DEBITS'.
           05  FILLER           PIC X(7)  VALUE 'CREDITS'.
      *
       01  WS-REPORT-LINE.
           05  WS-VOUCHER-DATE.
               10  WS-VOUCHER-DAY   PIC 99/.
               10  WS-VOUCHER-MONTH PIC 99/.
               10  WS-VOUCHER-YEAR  PIC 99.
           05  FILLER               PIC X(2) VALUE SPACES.
           05  WS-PARTICULAR        PIC X(40).
           05  FILLER               PIC X(3) VALUE SPACES.
           05  WS-DEBITS            PIC Z(8)9.99.
           05  FILLER               PIC X(3) VALUE SPACES.
           05  WS-CREDITS           PIC Z(8)9.99.
      *
       01  WS-TOTAL-LINE.
           05  FILLER              PIC X(53) VALUE SPACES.
           05  WS-DEBITS-TOTAL     PIC Z(8)9.99.
           05  FILLER              PIC X(3) VALUE SPACES.
           05  WS-CREDITS-TOTAL    PIC Z(8)9.99.
      *
       01  WS-UNDERLINE.
           05  FILLER              PIC X(52) VALUE SPACES.
           05  FILLER              PIC X(13) VALUE ALL '-'.
           05  FILLER              PIC X(2)  VALUE SPACES.
           05  FILLER              PIC X(13) VALUE ALL '-'.
      *
       01  WS-EQUAL-LINE.
           05  FILLER              PIC X(52) VALUE SPACES.
           05  FILLER              PIC X(13) VALUE ALL '='.
           05  FILLER              PIC X(2)  VALUE SPACES.
           05  FILLER              PIC X(13) VALUE ALL '='.
      *
       01  WS-BLANK-LINE           PIC X(80) VALUE SPACE.
      *
       01  WS-SCREEN-HEADING-1.
           05  FILLER              PIC X(6)  VALUE 'GL019S'.
           05  FILLER              PIC X(14) VALUE SPACES.
           05  WS-SCREEN-CONAME    PIC X(40).
           05  FILLER              PIC X(12) VALUE SPACES.
           05  WS-SCREEN-DATE.
               10  WS-SCREEN-DAY   PIC 99/.
               10  WS-SCREEN-MONTH PIC 99/.
               10  WS-SCREEN-YEAR  PIC 99.
      *
       01  WS-SCREEN-HEADING-2.
           05  FILLER              PIC X(29) VALUE SPACES.
           05  FILLER              PIC X(21) VALUE
               'GENERAL LEDGER SYSTEM'.
           05  FILLER              PIC X(30) VALUE SPACES.
      *
       01  WS-SCREEN-HEADING-3.
           05  FILLER              PIC X(32) VALUE SPACES.
           05  FILLER              PIC X(17) VALUE
               'G/L ACTIVITY LIST'.
           05  FILLER              PIC X(31) VALUE SPACES.
      *
       01  WS-SCREEN-BODY-1.
           05  FILLER              PIC X(23) VALUE SPACES.
           05  FILLER              PIC X(30) VALUE
               'TRANSACTION DATE FROM  :   /  '.
           05  FILLER              PIC X(27) VALUE '   (MM/YY)'.
      *
       01  WS-SCREEN-BODY-2.
           05  FILLER              PIC X(40) VALUE SPACES.
           05  FILLER              PIC X(13) VALUE
               'TO    :   /  '.
           05  FILLER              PIC X(27) VALUE '   (MM/YY)'.
      *
       01  WS-SCREEN-VERIFY.
           05  FILLER              PIC X(32) VALUE SPACES.
           05  FILLER              PIC X(20) VALUE 'VERIFY (Y/N) ?'.
           05  FILLER              PIC X(28) VALUE SPACES.
      *
       01  WS-SCREEN-MESSAGE       PIC X(60).
      *
       01  WS-END-LINE.
           05  FILLER              PIC X(29) VALUE SPACES.
           05  FILLER              PIC X(23) VALUE
               '<--  END OF REPORT  -->'.
           05  FILLER              PIC X(28) VALUE SPACES.
      *
       01  WS-LEAP        PIC 99.
       01  WS-DUMMY       PIC 99.
       01  TEMP-ACCT-NO            PIC 9(6).
       01  TEMP-MONTH              PIC 99.
       01  TEMP-INDEX              PIC 99.
      *
       01  WS-BALANCE-B-D          PIC S9(9)V99.
       01  WS-BALANCE-C-D          PIC S9(9)V99.
      *
       01  WS-DUMMY-COUNT          PIC 999.
       01  WS-MAX-COUNT            PIC 999 VALUE 500.
       01  WS-OFFSET               PIC 99.
       01  WS-INDEX                PIC 99.
       01  WS-START-INDEX          PIC 99.
       01  WS-END-INDEX            PIC 99.
       01  WS-EOF                  PIC X.
       01  WS-LINE-COUNT           PIC 99.
       01  WS-PAGE-NO              PIC 999.
       01  WS-TOTAL-CREDITS        PIC S9(9)V99.
       01  WS-TOTAL-DEBITS         PIC S9(9)V99.
       01  WS-DATE-VALID           PIC X VALUE 'N'.
       01  WS-VALID                PIC X VALUE 'N'.
       01  WS-VERIFY               PIC X VALUE 'Y'.
       01  WS-VALID-RECORD         PIC X VALUE 'N'.
       01  WS-BLANK                PIC XX VALUE SPACES.
      *
       01  X     PIC 99.
       01  Y     PIC 99.
      *
       01  WS-SYS-DATE.
           05  WS-SYS-YEAR         PIC 99.
           05  WS-SYS-MONTH        PIC 99.
           05  WS-SYS-DAY          PIC 99.
      *
       01  WS-POST-DATE.
           05  WS-POST-YEAR        PIC 99.
           05  WS-POST-MONTH       PIC 99.
           05  WS-POST-DAY         PIC 99.
      *
       01  WS-JRN-DATE.
           05  WS-JRN-YEAR         PIC 99.
           05  WS-JRN-MONTH        PIC 99.
           05  WS-JRN-DAY          PIC 99.
      *
       01  WS-START-DATE.
           05  WS-START-YEAR       PIC 99.
           05  WS-START-MONTH      PIC 99.
           05  WS-START-DAY        PIC 99.
      *
       01  WS-END-DATE.
           05  WS-END-YEAR         PIC 99.
           05  WS-END-MONTH        PIC 99.
           05  WS-END-DAY          PIC 99.
      *
       01  WS-TEMP-DATE.
           05  WS-TEMP-YEAR        PIC 99.
           05  WS-TEMP-MONTH       PIC 99.
           05  WS-TEMP-DAY         PIC 99.
      *
       01  WS-KEY       PIC X.
      /
       PROCEDURE DIVISION.
      *
      *
      *    Main body of the program.
      *
      *
       P000-MAIN.
           OPEN INPUT GLJRNLHF, GLSYSPF, GLMASTF
                OUTPUT GLACTLST.
           PERFORM P050-INIT.
           PERFORM P100-DISPLAY-SCREEN.
           PERFORM P150-INITIALIZATION-VARIABLE.
           PERFORM P200-READ-AND-PROCESS UNTIL WS-EOF = 'Y'.
           IF WS-VALID-RECORD = 'Y'
               PERFORM P900-PRINT-BALANCE-C-D
               PERFORM P950-PRINT-ENDING
               MOVE 'GL019R GENERATED.' TO WS-SCREEN-MESSAGE
               DISPLAY WS-SCREEN-MESSAGE LINE 24
           ELSE
               MOVE 'NO RECORD WITHIN THE PERIOD.' TO WS-SCREEN-MESSAGE
               DISPLAY WS-SCREEN-MESSAGE LINE 24.
           PERFORM P990-DELAY.
           CLOSE GLJRNLHF, GLSYSPF, GLMASTF, GLACTLST.
           STOP RUN.
      *
      *
      *    Display the interactive screen on terminal while execution.
      *
      *
       P100-DISPLAY-SCREEN.
           MOVE 1 TO WS-START-DAY.
           MOVE 99 TO WS-END-DAY.
           DISPLAY WS-SCREEN-HEADING-1 LINE 1 ERASE.
           DISPLAY WS-SCREEN-HEADING-2 LINE 2.
           DISPLAY WS-SCREEN-HEADING-3 LINE 3.
           DISPLAY WS-SCREEN-BODY-1 LINE 10.
           DISPLAY WS-SCREEN-BODY-2 LINE 12.
           DISPLAY WS-SCREEN-VERIFY LINE 18.
           PERFORM P150-ACCEPT-PERIOD UNTIL WS-DATE-VALID = 'Y'.
           MOVE 'PROCESSING... PLEASE WAIT.' TO WS-SCREEN-MESSAGE.
           DISPLAY WS-SCREEN-MESSAGE LINE 24.
      *
      *
      *    Accept user's input of period for printing activity list.
      *    Also prompt the user to let him to verify his input.
      *
      *    Then check the period, if the period is not valid,
      *    display message to user and accept another input.
      *
      *
       P150-ACCEPT-PERIOD.
           ACCEPT WS-START-MONTH LINE 10 POSITION 49 NO BEEP
           ACCEPT WS-START-YEAR LINE 10 POSITION 52 NO BEEP
           ACCEPT WS-END-MONTH LINE 12 POSITION 49 NO BEEP
           ACCEPT WS-END-YEAR LINE 12 POSITION 52 NO BEEP
           ACCEPT WS-VERIFY LINE 18 POSITION 49 NO BEEP TAB.
           IF WS-VERIFY = 'Y'
               PERFORM P160-TEST-DATE
           ELSE
               DISPLAY WS-BLANK LINE 10 POSITION 49
               DISPLAY WS-BLANK LINE 10 POSITION 52
               DISPLAY WS-BLANK LINE 12 POSITION 49
               DISPLAY WS-BLANK LINE 12 POSITION 52
               DISPLAY SPACE LINE 18 POSITION 49
               MOVE 'N' TO WS-DATE-VALID.
      *
      *
      *    Routine to test the period to print activity list is
      *    valid to the system.
      *
      *
       P160-TEST-DATE.
           IF WS-START-DATE > WS-END-DATE
               MOVE 'N' TO WS-DATE-VALID
               MOVE 'ERR-210 : INVALID PERIOD' TO WS-SCREEN-MESSAGE
               DISPLAY WS-SCREEN-MESSAGE LINE 24 BEEP
           ELSE
               IF GLSP-POSDATE < WS-END-DATE
                   MOVE 'ERR-290 : TRANSACTIONS NOT POSTED'
                   TO WS-SCREEN-MESSAGE
                   DISPLAY WS-SCREEN-MESSAGE LINE 24 BEEP
               ELSE
                   IF ((WS-START-YEAR < WS-END-YEAR) AND
                      (WS-START-MONTH < WS-END-MONTH))
                       MOVE 'ERR-210 : INVALID PERIOD' TO
                       WS-SCREEN-MESSAGE
                       DISPLAY WS-SCREEN-MESSAGE LINE 24 BEEP
                   ELSE
                       PERFORM P500-CALCULATE-WS-START-INDEX
                       PERFORM P600-CALCULATE-WS-END-INDEX
                       IF ((WS-START-YEAR < WS-END-YEAR) AND
                          (WS-START-INDEX NOT < WS-END-INDEX))
                           MOVE 'ERR-210 : INVALID PERIOD'
                           TO WS-SCREEN-MESSAGE
                           DISPLAY WS-SCREEN-MESSAGE LINE 24 BEEP
                       ELSE
                           MOVE 'Y' TO WS-DATE-VALID.
      *
       P500-CALCULATE-WS-START-INDEX.
           COMPUTE WS-START-INDEX = WS-START-MONTH - WS-OFFSET.
           IF WS-START-INDEX NOT > 0
               COMPUTE WS-START-INDEX = WS-START-INDEX + 12.
      *
       P600-CALCULATE-WS-END-INDEX.
           COMPUTE WS-END-INDEX = WS-END-MONTH - WS-OFFSET.
           IF WS-END-INDEX NOT > 0
               COMPUTE WS-END-INDEX = WS-END-INDEX + 12.
      *
      *
      *    Initialization of system with system date, company name, etc.
      *
      *
       P050-INIT.
           ACCEPT WS-SYS-DATE FROM DATE.
           MOVE WS-SYS-YEAR TO WS-REPORT-YEAR  WS-SCREEN-YEAR.
           MOVE WS-SYS-MONTH TO WS-REPORT-MONTH  WS-SCREEN-MONTH.
           MOVE WS-SYS-DAY TO WS-REPORT-DAY  WS-SCREEN-DAY.

           READ GLSYSPF.
           MOVE GLSP-CONAME TO WS-COMPANY-NAME  WS-SCREEN-CONAME.
           MOVE GLSP-STMONTH TO WS-OFFSET.
           MOVE GLSP-POSDATE TO WS-POST-DATE.
      *
      *
      *    Initialization of variable.
      *    And also reading the first record in transaction history
      *    file.
      *
      *
       P150-INITIALIZATION-VARIABLE.
           MOVE 'N' TO WS-EOF.
           MOVE ZERO TO WS-PAGE-NO.
           MOVE ZERO TO WS-LINE-COUNT.
           MOVE ZERO TO WS-TOTAL-CREDITS.
           MOVE ZERO TO WS-TOTAL-DEBITS.

           PERFORM P180-READ-FILE.
           IF WS-VALID = 'Y'
               MOVE 'Y' TO WS-VALID-RECORD
               PERFORM P700-PRINT-HEADING
               PERFORM P800-PRINT-BALANCE-B-D.
      *
      *
      *    Procedure to print heading in activity list (GL019R).
      *
      *
       P700-PRINT-HEADING.
           MOVE ZERO TO WS-LINE-COUNT.
           ADD 1 TO WS-PAGE-NO.
           MOVE WS-PAGE-NO TO WS-PAGE-NUMBER.
           WRITE REPORT-LINE FROM WS-HEADING-1 AFTER PAGE.
           WRITE REPORT-LINE FROM WS-HEADING-1 AFTER 0.
           WRITE REPORT-LINE FROM WS-HEADING-2 AFTER 2.
           WRITE REPORT-LINE FROM WS-HEADING-2 AFTER 0.

           MOVE GLJRH-ACCTNO TO TEMP-ACCT-NO.
           MOVE GLJRH-VOUCHERDT TO WS-JRN-DATE.
           MOVE WS-JRN-MONTH TO TEMP-MONTH.
           PERFORM P550-COMPUTE-WS-INDEX.

           MOVE TEMP-ACCT-NO TO GLMA-ACCTNO.
           MOVE SPACE TO GLMA-CURHIS.
           READ GLMASTF.
           MOVE GLMA-ACCTNO TO WS-ACCOUNT-NUMBER.
           MOVE GLMA-DESCRIPTION TO WS-DESCRIPTION.
           WRITE REPORT-LINE FROM WS-HEADING-3 AFTER 5.
           MOVE SPACE TO WS-ACCOUNT-NUMBER.
           MOVE SPACE TO WS-DESCRIPTION.
           WRITE REPORT-LINE FROM WS-HEADING-3 AFTER 0.
           WRITE REPORT-LINE FROM WS-HEADING-4 AFTER 2.
           WRITE REPORT-LINE FROM WS-HEADING-4 AFTER 0.
           WRITE REPORT-LINE FROM SPACES AFTER 1.
           ADD 8 TO WS-LINE-COUNT.
      *
       P550-COMPUTE-WS-INDEX.
           COMPUTE WS-INDEX = WS-JRN-MONTH - WS-OFFSET.
           IF WS-INDEX NOT > 0
               COMPUTE WS-INDEX = WS-INDEX + 12.
      *
      *
      *    Routine to calculate the value of balance brought down
      *    in the period specified.
      *
      *
       P810-CALCULATE-BALANCE-B-D.
           MOVE 1 TO X.
           MOVE ZERO TO WS-BALANCE-B-D.
           PERFORM P820-ACCUMULATE-B-D UNTIL X > TEMP-INDEX.
           ADD GLMA-BEGINBAL TO WS-BALANCE-B-D.
      *
       P820-ACCUMULATE-B-D.
           ADD GLMA-PERIODAMT(X) TO WS-BALANCE-B-D.
           ADD 1 TO X.
      *
      *
      *    Procedure to print the report line for balance broght
      *    down.
      *    Also total debits / total credits is re-initialized.
      *
      *
       P800-PRINT-BALANCE-B-D.
           IF WS-LINE-COUNT > 50
               PERFORM P700-PRINT-HEADING.
           PERFORM P410-MOVE-START-DATE.
           IF WS-INDEX = 1
               PERFORM P830-MOVE-BEGINBAL
           ELSE
               COMPUTE TEMP-INDEX = WS-INDEX - 1
               PERFORM P810-CALCULATE-BALANCE-B-D
               IF WS-BALANCE-B-D NOT < 0
                   IF GLMA-DRCR = +1
                       MOVE WS-BALANCE-B-D TO WS-DEBITS
                       ADD WS-BALANCE-B-D TO WS-TOTAL-DEBITS
                   ELSE
                       MOVE WS-BALANCE-B-D TO WS-CREDITS
                       SUBTRACT WS-BALANCE-B-D FROM WS-TOTAL-CREDITS
               ELSE
                   IF GLMA-DRCR = +1
                       MOVE WS-BALANCE-B-D TO WS-CREDITS
                       ADD WS-BALANCE-B-D TO WS-TOTAL-CREDITS
                   ELSE
                       MOVE WS-BALANCE-B-D TO WS-DEBITS
                       SUBTRACT WS-BALANCE-B-D FROM WS-TOTAL-DEBITS.
           MOVE 'BALANCE B/D' TO WS-PARTICULAR.
           WRITE REPORT-LINE FROM WS-REPORT-LINE AFTER 1.
           MOVE SPACE TO WS-REPORT-LINE.
           ADD 1 TO WS-LINE-COUNT.
      *
       P830-MOVE-BEGINBAL.
           IF GLMA-BEGINBAL NOT < 0
               IF GLMA-DRCR = +1
                   MOVE GLMA-BEGINBAL TO WS-DEBITS
                   ADD GLMA-BEGINBAL TO WS-TOTAL-DEBITS
               ELSE
                   MOVE GLMA-BEGINBAL TO WS-CREDITS
                   SUBTRACT GLMA-BEGINBAL FROM WS-TOTAL-CREDITS
           ELSE
               IF GLMA-DRCR = +1
                   MOVE GLMA-BEGINBAL TO WS-CREDITS
                   ADD GLMA-BEGINBAL TO WS-TOTAL-CREDITS
               ELSE
                   MOVE GLMA-BEGINBAL TO WS-DEBITS
                   SUBTRACT GLMA-BEGINBAL FROM WS-TOTAL-DEBITS.
      *
      *
      *    Routine to calculate the balance carried down in the
      *    period specified.
      *
      *
       P910-CALCULATE-BALANCE-C-D.
           MOVE 1 TO Y.
           MOVE ZERO TO WS-BALANCE-C-D.
           PERFORM P920-ACCUMULATE-C-D UNTIL Y > WS-INDEX.
           ADD GLMA-BEGINBAL TO WS-BALANCE-C-D.
      *
       P920-ACCUMULATE-C-D.
           ADD GLMA-PERIODAMT(Y) TO WS-BALANCE-C-D.
           ADD 1 TO Y.
      *
      *
      *    Precedure to print the report line of balance carried
      *    down.
      *
      *
       P900-PRINT-BALANCE-C-D.
           PERFORM P420-MOVE-END-DATE.
           PERFORM P910-CALCULATE-BALANCE-C-D.
           IF WS-BALANCE-C-D NOT < 0
               IF GLMA-DRCR = +1
                   MOVE WS-BALANCE-C-D TO WS-CREDITS
                   SUBTRACT WS-BALANCE-C-D FROM WS-TOTAL-CREDITS
               ELSE
                   MOVE WS-BALANCE-C-D TO WS-DEBITS
                   ADD WS-BALANCE-C-D TO WS-TOTAL-DEBITS
           ELSE
               IF GLMA-DRCR = +1
                   MOVE WS-BALANCE-C-D TO WS-DEBITS
                   SUBTRACT WS-BALANCE-C-D FROM WS-TOTAL-DEBITS
               ELSE
                   MOVE WS-BALANCE-C-D TO WS-CREDITS
                   ADD WS-BALANCE-C-D TO WS-TOTAL-CREDITS.
           MOVE 'BALANCE C/D' TO WS-PARTICULAR.
           WRITE REPORT-LINE FROM WS-REPORT-LINE AFTER 1.
           WRITE REPORT-LINE FROM WS-UNDERLINE AFTER 1.
           MOVE WS-TOTAL-DEBITS TO WS-DEBITS-TOTAL.
           MOVE WS-TOTAL-CREDITS TO WS-CREDITS-TOTAL.
           WRITE REPORT-LINE FROM WS-TOTAL-LINE AFTER 1.
           WRITE REPORT-LINE FROM WS-EQUAL-LINE AFTER 1.
           WRITE REPORT-LINE FROM SPACES AFTER 1.
           ADD 5 TO WS-LINE-COUNT.
           MOVE SPACE TO WS-REPORT-LINE.
           MOVE ZERO TO WS-TOTAL-CREDITS.
           MOVE ZERO TO WS-TOTAL-DEBITS.
      *
      *
      *    Routine to read a valid record in journal transaction
      *    history file with the period to be printed.
      *
      *
       P180-READ-FILE.
           MOVE 'N' TO WS-VALID.
           PERFORM P190-READ UNTIL (WS-VALID = 'Y' OR WS-EOF = 'Y').
      *
       P190-READ.
           READ GLJRNLHF AT END MOVE 'Y' TO WS-EOF.
           IF ((GLJRH-VOUCHERDT NOT < WS-START-DATE) AND
               (GLJRH-VOUCHERDT < WS-END-DATE))
               MOVE GLJRH-VOUCHERDT TO WS-JRN-DATE
               MOVE 'Y' TO WS-VALID.
      *
      *
      *    One control break for account number.
      *
      *
       P200-READ-AND-PROCESS.
           IF GLJRH-ACCTNO = TEMP-ACCT-NO
              PERFORM P500-TRANSACTION-RTN
           ELSE
              PERFORM P250-PRINT-ACCOUNT-RTN.
           PERFORM P180-READ-FILE.
      *
      *
      *    One control break for month.
      *
      *
       P500-TRANSACTION-RTN.
           IF WS-JRN-MONTH = TEMP-MONTH
               PERFORM P1000-PROCESS-RECORD
           ELSE
               PERFORM P900-PRINT-BALANCE-C-D
               PERFORM P550-COMPUTE-WS-INDEX
               MOVE WS-JRN-MONTH TO TEMP-MONTH
               PERFORM P800-PRINT-BALANCE-B-D
               PERFORM P1000-PROCESS-RECORD.
      *
      *
      *    Routine to process a history record.
      *    Add to total credits / total debits when appropriate.
      *
      *
       P1000-PROCESS-RECORD.
           MOVE WS-JRN-YEAR TO WS-VOUCHER-YEAR
           MOVE WS-JRN-MONTH TO WS-VOUCHER-MONTH
           MOVE WS-JRN-DAY TO WS-VOUCHER-DAY.
           MOVE GLJRH-PARTICULAR TO WS-PARTICULAR.
           IF GLJRH-AMOUNT > 0
              IF GLMA-DRCR = +1
                  MOVE GLJRH-AMOUNT TO WS-DEBITS
                  ADD GLJRH-AMOUNT TO WS-TOTAL-DEBITS
              ELSE
                  MOVE GLJRH-AMOUNT TO WS-CREDITS
                  SUBTRACT GLJRH-AMOUNT FROM WS-TOTAL-CREDITS
           ELSE
              IF GLMA-DRCR = +1
                  MOVE GLJRH-AMOUNT TO WS-CREDITS
                  ADD GLJRH-AMOUNT TO WS-TOTAL-CREDITS
              ELSE
                  MOVE GLJRH-AMOUNT TO WS-DEBITS
                  SUBTRACT GLJRH-AMOUNT FROM WS-TOTAL-DEBITS.
           WRITE REPORT-LINE FROM WS-REPORT-LINE AFTER 1.
           MOVE SPACE TO WS-REPORT-LINE.
           ADD 1 TO WS-LINE-COUNT.

           MOVE WS-JRN-YEAR TO WS-TEMP-YEAR.
           MOVE WS-JRN-MONTH TO WS-TEMP-MONTH.
           MOVE WS-JRN-DAY TO WS-TEMP-DAY.
      *
       P250-PRINT-ACCOUNT-RTN.
           PERFORM P900-PRINT-BALANCE-C-D.
           PERFORM P700-PRINT-HEADING.
           PERFORM P800-PRINT-BALANCE-B-D.
           PERFORM P1000-PROCESS-RECORD.
      *
       P410-MOVE-START-DATE.
           MOVE 1 TO WS-VOUCHER-DAY.
           MOVE WS-JRN-MONTH TO WS-VOUCHER-MONTH.
           MOVE WS-JRN-YEAR TO WS-VOUCHER-YEAR.
      *
       P420-MOVE-END-DATE.
           IF ((WS-TEMP-MONTH = 1) OR (WS-TEMP-MONTH = 3)
              OR (WS-TEMP-MONTH = 5) OR (WS-TEMP-MONTH = 7) OR
              (WS-TEMP-MONTH = 8) OR (WS-TEMP-MONTH = 10) OR
              (WS-TEMP-MONTH = 12))
              MOVE 31 TO WS-VOUCHER-DAY
           ELSE
              IF (WS-TEMP-MONTH NOT = 2)
                  MOVE 30 TO WS-VOUCHER-DAY
              ELSE
                  PERFORM P430-CHECK-LEAP-YEAR.
           MOVE WS-TEMP-MONTH TO WS-VOUCHER-MONTH.
           MOVE WS-TEMP-YEAR TO WS-VOUCHER-YEAR.
      *
       P430-CHECK-LEAP-YEAR.
           DIVIDE WS-TEMP-YEAR BY 4 GIVING WS-DUMMY
               REMAINDER WS-LEAP.
           IF ((WS-LEAP NOT = 0) OR (WS-TEMP-YEAR = 0))
               MOVE 28 TO WS-VOUCHER-DAY
           ELSE
               MOVE 29 TO WS-VOUCHER-DAY.
      *
       P950-PRINT-ENDING.
           WRITE REPORT-LINE FROM WS-END-LINE AFTER 1.
           WRITE REPORT-LINE FROM WS-END-LINE AFTER 0.
      *
       P990-DELAY.
           DISPLAY 'PRESS ANY TO CONTINUE ...' LINE 24 POSITION 50.
           ACCEPT WS-KEY LINE 24 POSITION 79 NO BEEP OFF.

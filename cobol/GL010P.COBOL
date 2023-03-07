       IDENTIFICATION DIVISION.
       PROGRAM-ID.    GL010P-GL-SYSTEM-PARAMETERS-FILE-MAINTENANCE.
      *+---------------------------------------------------------------+
      *|   OBJECTIVE : This program maintains the G/L System Parameter |
      *|               File. The user must enter the correct password  |
      *|               to run the program. If OK, the user can change  |
      *|               the company name and password in file. Other    |
      *|               paramters are user-inaccessible                 |
      *|   I-O FILES : GLSYSPF                                         |
      *+---------------------------------------------------------------+
       AUTHOR.        CHANG-MAN-WAI.
       DATE-WRITTEN.  AUGUST-21-1988.
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.     NCR-T800.
       OBJECT-COMPUTER.     NCR-T800.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT GLSYSPF  ASSIGN TO RANDOM  'GLSYSPF'.
      *
       DATA DIVISION.
       FILE SECTION.
       COPY "GLSYSPSL.DEF".
      *
       WORKING-STORAGE SECTION.
       01 WS-BLANK-LINE        PIC  X(80) VALUE SPACES.
       01 WS-MAX-COUNT         PIC  999   VALUE 250.
       01 WS-SCREEN-CODE       PIC  X(6)  VALUE 'GL010S'.
       01 WS-SYSNAME           PIC  X(21)
          VALUE "GENERAL LEDGER SYSTEM".
       01 WS-SUBSYSNAME        PIC  X(38)
          VALUE "G/L SYSTEM PARAMETERS FILE MAINTENANCE".
       01 WS-NEW-PASSWORD      PIC  X(8).
       01 WS-EDITING-DONE      PIC  X.
       01 WS-COUNT             PIC  999.
       01 WS-AUTHORISED-ACCESS PIC  X.
      *
       01 WS-SYSDATE.
          03 YEAR              PIC  99.
          03 MONTH             PIC  99.
          03 WS-DAY            PIC  99.
      *
       01 WS-SCREEN-DATE.
          03 WS-DAY            PIC  99/.
          03 MONTH             PIC  99/.
          03 YEAR              PIC  99.
      *
       01 WS-INPUT-VALIDATION  PIC X.
          88 WS-INPUT-VALID    VALUE "T".
          88 WS-INPUT-INVALID  VALUE "F".
      *
       PROCEDURE DIVISION.
       P000-MAIN.
           OPEN I-O GLSYSPF.
           PERFORM P001-GET-DATE.
           PERFORM P002-READ-GLSYSPF.
           PERFORM P006-SHOW-HEADINGS.
           PERFORM P007-GET-OLD-PASSWORD.
           IF WS-AUTHORISED-ACCESS = 'Y'
             PERFORM P006-SHOW-HEADINGS
             PERFORM P004-GET-NEW-REC-DEFINITION
                     UNTIL WS-EDITING-DONE = 'Y' OR
                           WS-EDITING-DONE = '9'
             IF WS-EDITING-DONE = "Y"
               PERFORM P003-WRITE-GLSYSPF
             ELSE
               NEXT SENTENCE
           ELSE
             DISPLAY "ERR 24 : UNAUTHORISED ACCESS" LINE 24 BEEP
           CLOSE GLSYSPF.
           STOP RUN.
      *
       P001-GET-DATE.
           ACCEPT WS-SYSDATE FROM DATE.
           MOVE CORR WS-SYSDATE TO WS-SCREEN-DATE.
      *
       P002-READ-GLSYSPF.
           READ GLSYSPF.
      *
       P003-WRITE-GLSYSPF.
           REWRITE GLSP-RECORD.
      *
       P004-GET-NEW-REC-DEFINITION.
           PERFORM P005-DISPLAY-RECORD.
           PERFORM P009-GET-CONAME.
           MOVE "F" TO WS-INPUT-VALIDATION.
           PERFORM P010-GET-PASSWD
                   UNTIL WS-INPUT-VALID.
           PERFORM P104-GET-CONFIRMATION.
      *
       P005-DISPLAY-RECORD.
           DISPLAY "COMPANY NAME:" LINE  7 POSITION 17.
           DISPLAY "PASSWORD:"     LINE 11 POSITION 21.
           DISPLAY GLSP-CONAME LINE  7 POSITION 31.
           DISPLAY GLSP-PASSWD LINE 11 POSITION 31.
      *
       P006-SHOW-HEADINGS.
           DISPLAY GLSP-CONAME    LINE 1 POSITION 21 ERASE.
           DISPLAY WS-SCREEN-CODE LINE 1 POSITION  1.
           DISPLAY WS-SCREEN-DATE LINE 1 POSITION 73.
           DISPLAY WS-SYSNAME     LINE 2 POSITION 30.
           DISPLAY WS-SUBSYSNAME  LINE 3 POSITION 21.
      *
       P007-GET-OLD-PASSWORD.
           DISPLAY "ENTER PASSWORD :" LINE 9 POSITION 21.
           ACCEPT  WS-NEW-PASSWORD LINE 9 POSITION 38
                   NO BEEP OFF TAB PROMPT.
           MOVE 'N' TO WS-AUTHORISED-ACCESS.
           IF WS-NEW-PASSWORD = GLSP-PASSWD
             MOVE 'Y' TO WS-AUTHORISED-ACCESS.
      *
       P009-GET-CONAME.
           ACCEPT GLSP-CONAME LINE 7 POSITION 31
                  NO BEEP TAB UPDATE.
           DISPLAY GLSP-CONAME LINE 7 POSITION 31.
      *
       P010-GET-PASSWD.
           ACCEPT GLSP-PASSWD LINE 11 POSITION 31
                  NO BEEP TAB UPDATE.
           DISPLAY GLSP-PASSWD LINE 11 POSITION 31.
           IF GLSP-PASSWD = SPACES
             MOVE "F" TO WS-INPUT-VALIDATION
             DISPLAY "ERR : PASSWORD CANNOT BE BLANK" LINE 24
             PERFORM P031-DELAY
             PERFORM P030-CLEAR-MESSAGE-AREA
           ELSE
             MOVE "T" TO WS-INPUT-VALIDATION.
      *
       P030-CLEAR-MESSAGE-AREA.
           DISPLAY WS-BLANK-LINE LINE 24.
      *
       P031-DELAY.
           MOVE 0 TO WS-COUNT.
           PERFORM P032-BUSY-LOOP
                   UNTIL WS-COUNT > WS-MAX-COUNT.
      *
       P032-BUSY-LOOP.
           ADD 1 TO WS-COUNT.
      *
       P103-CHECK-IF-DONE.
           MOVE SPACE TO WS-EDITING-DONE.
           PERFORM P030-CLEAR-MESSAGE-AREA.
           DISPLAY "TYPE 'Y' TO ACCEPT, 'N' TO RE-ENTER, '9' TO DISCARD
      -    "" LINE 24.
           ACCEPT WS-EDITING-DONE LINE 24 POSITION 53
                  NO BEEP TAB PROMPT.
           PERFORM P030-CLEAR-MESSAGE-AREA.
      *
       P104-GET-CONFIRMATION.
            MOVE SPACES TO WS-EDITING-DONE.
            PERFORM P103-CHECK-IF-DONE UNTIL
                    (WS-EDITING-DONE = "Y") OR
                    (WS-EDITING-DONE = "N") OR
                    (WS-EDITING-DONE = "9").

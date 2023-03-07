PROCEDURE border
PARAMETERS sys_title,scrn_title
CLEAR
@ 2, (80-LEN(sys_title))/2 SAY sys_title
@ 3, (80-LEN(scrn_title))/2 SAY scrn_title
@ 4, 1 TO 4, 78 DOUBLE
@ 1, 0 TO 23, 79
@ 20, 1 TO 20, 78
RETURN

PROCEDURE ddmain1
  PRIVATE option
  * Setup environment
  SET BELL OFF
  SET TALK OFF
  SET STATUS OFF
  SET SAFETY OFF
  SET DEVICE TO SCREEN
  SET PRINT OFF
  SET CONFIRM OFF
  SET DELETED ON
  CLOSE DATABASES
  CLEAR ALL
  RESTORE FROM ddmem
  RESTORE FROM print ADDITIVE

  * Main loop
  option=-1
  DO WHILE option#0
    DO border WITH "DATA DICTIONARY MANAGER", "MAIN MENU"

    * Display Menu
    option=0
    @  8, 28  SAY "1. Data Editing"
    @  9, 28  SAY "2. Print Report"
    @ 10, 28  SAY "3. Reindex"
    @ 11, 28  SAY "4. Pack Databases"
    @ 14, 28  SAY "0. EXIT TO DBASE DOT PROMPT"
    @ 21, 28  SAY "OPTION:" GET option PICTURE "9" RANGE 0,5
    READ
    @ 21, 1 SAY SPACE(77)

    * Do selected option
    DO CASE
       CASE option=1
	    DO ddmain2		 && Data Entry Functions
       CASE option=2
	    DO ddmain3		 && Queries and Reports
       CASE option=3
	    DO ddindex
       CASE option=4
	    DO ddpack
       OTHERWISE		 && Confirm option=0 before leaving
	    mq=.T.
	    @ 21, 20 SAY "Do you really want to quit (Y or N)?";
	      GET mq PICTURE 'Y'
	    READ
	    option=IIF(mq,0,-1) 	&& Reset option to -1 if (N)o
    ENDCASE
  * End of main loop
  ENDDO (option#0)

  * Restore system defaults and exit
  SET BELL ON
  SET TALK ON
  SET STATUS ON
  SET SAFETY ON
  SET CONFIRM ON
  SET DELETED OFF
  CLEAR ALL
  CLEAR
RETURN

PROCEDURE ddoption
PARAMETER option
     @	8, 28  SAY "1. Data Element"
     @	9, 28  SAY "2. Data Structure"
     @ 10, 28  SAY "3. Data Flow"
     @ 11, 28  SAY "4. Data Store"
     @ 12, 28  SAY "5. Process"
     @ 14, 28  SAY "0. EXIT"
     @ 21, 28  SAY "OPTION:" GET option PICTURE "9" RANGE 0,5
     READ
     @ 21, 1 SAY SPACE(77)
RETURN

PROCEDURE ddmain2
PRIVATE option
  * Main loop
  option=-1
  DO WHILE option#0
     DO border WITH "DATA DICTIONARY MANAGER", "DATA EDITING"
     option = 0
     DO ddoption WITH option
     * Do selected option
     DO CASE
	CASE option=1
	     DO delem
	CASE option=2
	     DO dstructm
	CASE option=3
	     DO dflowm
	CASE option=4
	     DO dstorem
	CASE option=5
	     DO dprocm
     ENDCASE
  * End of main loop
  ENDDO (option#0)
RETURN

PROCEDURE ddmain3
  PRIVATE option
  * Main loop
  option=-1
  DO WHILE option#0
     DO border WITH "DATA DICTIONARY MANAGER", "PRINT REPORT"
     option=0
     DO ddoption WITH option
     * Do selected option
     DO CASE
	CASE option=1
	     DO delep
	CASE option=2
	     DO dstructp
	CASE option=3
	     DO dflowp
	CASE option=4
	     DO dstorep
	CASE option=5
	     DO dprocp
     ENDCASE
  * End of main loop
  ENDDO (option#0)
RETURN

PROCEDURE ddindex
  DO border WITH "DATA DICTIONARY MANAGER", "REINDEX DATA BASES"
  @  8, 28 SAY "Reindexing data elements"
  USE dele0
  INDEX ON name TO dele00
  USE dele1
  INDEX ON key TO dele11
  USE dele2
  INDEX ON key TO dele22

  @  9, 28 SAY "Reindexing data structures"
  USE dstruct0
  INDEX ON name TO dstruct00
  USE dstruct1
  INDEX ON key TO dstruct11

  @ 10, 28 SAY "Reindexing data flows"
  USE dflow0
  INDEX ON name TO dflow00
  USE dflow1
  INDEX ON key TO dflow11

  @ 11, 28 SAY "Reindexing processes"
  USE dproc0
  INDEX ON name to dproc00
  USE dproc1
  INDEX ON key TO dproc11

  @ 12, 28 SAY "Reindex data stores"
  USE dstore0
  INDEX ON name TO dstore00
  USE dstore3
  INDEX ON key TO dstore33
RETURN

PROCEDURE ddpack
  DO border WITH "DATA DICTIONARY MANAGER", "PACK DATA BASES"
  @  8, 28 SAY "Pack data elements"
  USE dele0 INDEX dele00
  PACK
  USE dele1 INDEX dele11
  PACK
  USE dele2 INDEX dele22
  PACK

  @  9, 28 SAY "Pack data structures"
  USE dstruct0 INDEX dstruct00
  PACK
  USE dstruct1 INDEX dstruct11
  PACK

  @ 10, 28 SAY "Pack data flow"
  USE dflow0 INDEX dflow00
  PACK
  USE dflow1 INDEX dflow11
  PACK

  @ 10, 28 SAY "Pack processes"
  USE dproc0 INDEX dproc00
  PACK
  USE dproc1 INDEX dproc11
  PACK

  @ 11, 28 SAY " Pack data stores"
  USE dstore0 INDEX dstore00
  PACK
  USE dstore3 INDEX dstore33
  PACK
RETURN

PROCEDURE dstorem
  SELECT a
  USE dstore0 INDEX dstore00  && main
  SELECT d
  USE dstore3 INDEX dstore33  && content

  DO border WITH "DATA STORE","EDITING"
  DO WHILE .T.
    SELECT dstore0
    mstorename = SPACE(40)
    @ 8, 10 SAY "Enter data store name: " GET mstorename
    READ
    IF mstorename = SPACE(40)
      EXIT
    ENDIF
    SEEK mstorename
    IF EOF()
      moption = "Y"
      @ 21, 15 SAY "Data store not found. Creat(Y/N)?" GET moption
      READ
      @ 21, 1 SAY SPACE(77)
      IF moption = "Y"
	APPEND BLANK
	REPLACE key WITH datastore, name with mstorename
	DO dstorupd WITH .T., datastore
	datastore = datastore + 1
	SAVE TO ddmem ALL LIKE data*
      ENDIF
    ELSE
      moption = " "
      @ 21, 15 SAY "Edit / Delete ?" GET moption
      READ
      @ 21,  1 SAY SPACE(77)
      DO CASE
	 CASE moption$"Dd"
	   DO dstordel
	 CASE moption$"Ee"
	   DO dstorupd WITH .F.,dstore0->key
      ENDCASE
    ENDIF
  ENDDO
RETURN

PROCEDURE dstructm
  SELECT a
  USE dstruct0 INDEX dstruct00
  SELECT b
  USE dstruct1 INDEX dstruct11

  DO border WITH "DATA STRUCTURE","EDITING"
  SELECT a
  DO WHILE .T.
    SELECT dstruct0
    mdstruname=SPACE(40)
    @ 8, 10 SAY "Enter data structure name: " GET mdstruname
    READ
    IF mdstruname = SPACE(40)
      EXIT
    ENDIF
    SEEK mdstruname
    IF EOF()
      moption = "Y"
      @ 21, 15 SAY "Data structure not found. Creat(Y/N)?" GET moption
      READ
      @ 21, 1 SAY SPACE(77)
      IF moption = "Y"
	APPEND BLANK
	REPLACE key WITH datastruct, name with mdstruname
	DO dstrupd WITH .T., datastruct
	datastruct = datastruct + 1
	SAVE TO ddmem ALL LIKE data*
      ENDIF
    ELSE
      moption = " "
      @ 21, 15 SAY "Edit / Delete ?" GET moption
      READ
      @ 21,  1 SAY SPACE(77)
      DO CASE
	 CASE moption$"Dd"
	   DO dstrdele
	 CASE moption$"Ee"
	   DO dstrupd WITH .F.,dstruct0->key
      ENDCASE
    ENDIF
  ENDDO
RETURN

PROCEDURE dflowm
  SELECT a
  USE dflow0 INDEX dflow00
  SELECT b
  USE dflow1 INDEX dflow11

  DO border WITH "DATA FLOW","EDITING"
  DO WHILE .T.
    SELECT dflow0
    mflowname = SPACE(40)
    @ 8, 10 SAY "Enter data flow name: " GET mflowname
    READ
    IF mflowname = SPACE(40)
      EXIT
    ENDIF
    SEEK mflowname
    IF EOF()
      moption = "Y"
      @ 21, 15 SAY "Data flow not found. Creat(Y/N)?" GET moption
      READ
      @ 21, 1 SAY SPACE(77)
      IF moption = "Y"
	APPEND BLANK
	REPLACE key WITH dataflow, name with mflowname
	DO dflowupd WITH .T., dataflow
	dataflow = dataflow + 1
	SAVE TO ddmem ALL LIKE data*
      ENDIF
    ELSE
      moption = " "
      @ 21, 15 SAY "Edit / Delete ?" GET moption
      READ
      @ 21,  1 SAY SPACE(77)
      DO CASE
	 CASE moption$"Dd"
	   DO dflowdel
	 CASE moption$"Ee"
	   DO dflowupd WITH .F.,dflow0->key
      ENDCASE
    ENDIF
  ENDDO
RETURN

PROCEDURE dprocm
  SELECT a
  USE dproc0 INDEX dproc00
  SELECT b
  USE dproc1 INDEX dproc11

  DO border WITH "PROCESS","EDITING"
  DO WHILE .T.
    SELECT dproc0
    mprocname = SPACE(40)
    @ 8, 10 SAY "Enter process name: " GET mprocname
    READ
    IF mprocname = SPACE(40)
      EXIT
    ENDIF
    SEEK mprocname
    IF EOF()
      moption = "Y"
      @ 21, 15 SAY "Process not found. Creat(Y/N)?" GET moption
      READ
      @ 21, 1 SAY SPACE(77)
      IF moption = "Y"
	APPEND BLANK
	REPLACE key WITH dataproc, name with mprocname
	DO dprocupd WITH .T., dataproc
	dataproc = dataproc + 1
	SAVE TO ddmem ALL LIKE data*
      ENDIF
    ELSE
      moption = " "
      @ 21, 15 SAY "Edit / Delete ?" GET moption
      READ
      @ 21,  1 SAY SPACE(77)
      DO CASE
	 CASE moption$"Dd"
	   DO dprocdel
	 CASE moption$"Ee"
	   DO dprocupd WITH .F.,dproc0->key
      ENDCASE
    ENDIF
  ENDDO
RETURN

PROCEDURE delem
  SELECT a
  USE dele0 INDEX dele00
  SELECT b
  USE dele1 INDEX dele11
  SELECT c
  USE dele2 INDEX dele22

  DO border WITH "DATA ELEMENT","EDITING"
  SELECT a
  DO WHILE .T.
    SELECT dele0
    mdelename=SPACE(40)
    @ 8, 10 SAY "Enter data element name: " GET mdelename
    READ
    IF mdelename = SPACE(40)
      EXIT
    ENDIF
    SEEK mdelename
    IF EOF()
      moption = "Y"
      @ 21, 15 SAY "Data element not found. Creat(Y/N)?" GET moption
      READ
      @ 21, 1 SAY SPACE(77)
      IF moption = "Y"
	APPEND BLANK
	REPLACE key WITH dataele, name with mdelename
	DO deleupd WITH .T., dataele
	dataele = dataele + 1
	SAVE TO ddmem ALL LIKE data*
      ENDIF
    ELSE
      moption = " "
      @ 21, 15 SAY "Edit / Delete ?" GET moption
      READ
      @ 21,  1 SAY SPACE(77)
      DO CASE
	 CASE moption$"Dd"
	   DO deledele
	 CASE moption$"Ee"
	   DO deleupd WITH .F.,dele0->key
      ENDCASE
    ENDIF
  ENDDO
RETURN

PROCEDURE deleupd
PARAMETER new, keyno
  DO border WITH "DATA ELEMENT","DATA EDITING"
  DO WHILE .T.
    @  6,  4 SAY "Name: " + dele0->name
    @  7,  4 SAY "Description: "
    @  7, 20 GET dele0->descript1
    @  8, 20 GET dele0->descript2
    @  9, 20 GET dele0->descript3
    @ 10, 20 GET dele0->descript4
    @ 11,  4 SAY "Type: (A/AN/N) " GET dele0->type
    @ 11, 40 SAY "Length: " GET dele0->length
    READ
    moption = "Y"
    @ 21, 28 SAY "Done(Y/N)?" GET moption
    READ
    @ 21,  1 SAY SPACE(77)
    IF moption = "Y"
      EXIT
    ENDIF
  ENDDO
  SET COLOR TO w+
  @ 12, 4 SAY "Alias: "
  SET COLOR TO
  SELECT dele1
  SET FILTER TO key = keyno
  SEEK keyno
  mline = 12
  mok = .F.
  DO WHILE .NOT. mok
    mnew = .F.
    IF new .OR. EOF()
      mnew = .T.
      APPEND BLANK
      REPLACE key WITH keyno
    ENDIF
    IF mline > 19
      @ 12, 10 CLEAR TO 19, 30
      mline = 12
    ENDIF
    SET COLOR TO n/w
    @ mline, 12 SAY alias
    SET COLOR TO
    IF mnew
      @ 21, 20 SAY "Blank all to exit"
      @ mline, 12 GET alias
      READ
      @ 21, 20 SAY SPACE(20)
      IF alias = SPACE(40)
	DELETE
	mok = .T.
      ELSE
	mnew = .F.
      ENDIF
    ENDIF
    IF .NOT. mnew
      mediting = .T.
      DO WHILE mediting
	@ 22, 30 SAY "ABORT/Edit/Delete/Next : "
	DO WHILE .T.
	  mchoice = " "
	  @ 22, 55 GET mchoice PICTURE "!"
	  READ
	  IF mchoice$"AEDN"
	    EXIT
	  ENDIF
	ENDDO
	@ 22, 1 SAY SPACE(77)
	DO CASE
	   CASE mchoice = "A"
		mok = .T.
		mediting = .F.
	   CASE mchoice = "D"
		CLEAR GETS
		@ mline, 10 CLEAR TO mline, 30
		DELETE
		mediting = .F.
	   CASE mchoice = "N"
		@ mline, 12 SAY alias
		mline = mline + 1
		mediting = .F.
	   CASE mchoice = "E"
		@ mline, 12 GET alias
		READ
		mediting = .T.
	ENDCASE
      ENDDO
    ENDIF
    SKIP
  ENDDO
  @ 12, 2 CLEAR TO 19, 77
  SET COLOR TO w+
  @ 12, 5 SAY "Value"
  @ 12, 35 SAY "Meaning"
  SET COLOR TO
  SELECT dele2
  SET FILTER TO key = keyno
  SEEK keyno
  mline = 13
  mok = .F.
  DO WHILE .NOT. mok
    mnew = .F.
    IF new .OR. EOF()
      mnew = .T.
      APPEND BLANK
      REPLACE key WITH keyno
    ENDIF
    IF mline > 19
      @ 13, 5 CLEAR TO 19, 77
      mline = 13
    ENDIF
    SET COLOR TO n/w
    @ mline, 5 SAY value
    @ mline, 35 SAY meaning
    SET COLOR TO
    IF mnew
      @ 21, 20 SAY "Blank all to exit"
      @ mline, 5 GET value
      @ mline, 35 GET meaning
      READ
      @ 21, 20 SAY SPACE(20)
      IF value = SPACE(10) .AND. meaning = SPACE(10)
	DELETE
	mok = .T.
      ELSE
	mnew = .F.
      ENDIF
    ENDIF
    IF .NOT. mnew
      mediting = .T.
      DO WHILE mediting
	@ 22, 30 SAY "ABORT/Edit/Delete/Next : "
	DO WHILE .T.
	  mchoice = " "
	  @ 22, 55 GET mchoice PICTURE "!"
	  READ
	  IF mchoice$"AEDN"
	    EXIT
	  ENDIF
	ENDDO
	@ 22, 1 SAY SPACE(77)
	DO CASE
	   CASE mchoice = "A"
		mok = .T.
		mediting = .F.
	   CASE mchoice = "D"
		CLEAR GETS
		@ mline, 5 CLEAR TO mline, 77
		DELETE
		mediting = .F.
	   CASE mchoice = "N"
		@ mline,  5 SAY value
		@ mline, 35 SAY meaning
		mline = mline + 1
		mediting = .F.
	   CASE mchoice = "E"
		@ mline,  5 GET value
		@ mline, 35 GET meaning
		READ
		mediting = .T.
	ENDCASE
      ENDDO
    ENDIF
    SKIP
  ENDDO
  PACK
  SET FILTER TO
  @  5, 2 CLEAR TO 19, 77
RETURN

PROCEDURE dstorupd
PARAMETER new, keyno

  DO border WITH "DATA STORE","DATA EDITING"
  DO WHILE .T.
    @  6,  4 SAY "Name: " + dstore0->name
    @  6, 54 SAY "Ref No: " GET dstore0->refno
    @  7,  4 SAY "Description: "
    @  7, 20 GET dstore0->descript1
    @  8, 20 GET dstore0->descript2
    @  9, 20 GET dstore0->descript3
    @ 10, 20 GET dstore0->descript4
    @ 12,  4 SAY "Access diagram: " GET dstore0->access
    READ
    moption = "Y"
    @ 21, 28 SAY "Done(Y/N)?" GET moption
    READ
    @ 21,  1 SAY SPACE(77)
    IF moption = "Y"
      EXIT
    ENDIF
  ENDDO
  SET COLOR TO w+
  @ 12,  1 SAY "Content: "
  SET COLOR TO
  SELECT dstore3
  SET FILTER TO key = keyno
  SEEK keyno
  mline = 13
  mok = .F.
  DO WHILE .NOT. mok
    mnew = .F.
    IF new .OR. EOF()
      mnew = .T.
      APPEND BLANK
      REPLACE key WITH keyno
    ENDIF
    IF mline > 19
      @ 12, 1 CLEAR TO 19, 78
      mline = 13
    ENDIF
    SET COLOR TO n/w
    @ mline,  1 SAY content
    SET COLOR TO
    IF mnew
      @ 21, 20 SAY "Blank all to exit"
      @ mline,	1 GET content
      READ
      @ 21, 20 SAY SPACE(20)
      IF content = SPACE(10)
	DELETE
	mok = .T.
      ELSE
	mnew = .F.
      ENDIF
    ENDIF
    IF .NOT. mnew
      mediting = .T.
      DO WHILE mediting
	@ 22, 30 SAY "ABORT/Edit/Delete/Next : "
	DO WHILE .T.
	  mchoice = " "
	  @ 22, 55 GET mchoice PICTURE "!"
	  READ
	  IF mchoice$"AEDN"
	    EXIT
	  ENDIF
	ENDDO
	@ 22, 1 SAY SPACE(77)
	DO CASE
	   CASE mchoice = "A"
		mok = .T.
		mediting = .F.
	   CASE mchoice = "D"
		CLEAR GETS
		@ mline, 1 CLEAR TO mline, 78
		DELETE
		mediting = .F.
	   CASE mchoice = "N"
		@ mline,  1 SAY content
		mline = mline + 1
		mediting = .F.
	   CASE mchoice = "E"
		@ mline,  1 GET content
		READ
		mediting = .T.
	ENDCASE
      ENDDO
    ENDIF
    SKIP
  ENDDO
  @ 5,1 CLEAR TO 19, 78
  SET FILTER TO
RETURN

PROCEDURE dstrupd
PARAMETER new, keyno
  DO border WITH "DATA STRUCTURE","DATA EDITING"
  DO WHILE .T.
    @  6,  4 SAY "Name: " + dstruct0->name
    @  7,  4 SAY "Description: "
    @  7, 20 GET dstruct0->descript1
    @  8, 20 GET dstruct0->descript2
    @  9, 20 GET dstruct0->descript3
    @ 10, 20 GET dstruct0->descript4
    READ
    moption = "Y"
    @ 21, 28 SAY "Done(Y/N)?" GET moption
    READ
    @ 21,  1 SAY SPACE(77)
    IF moption = "Y"
      EXIT
    ENDIF
  ENDDO
  SET COLOR TO w+
  @ 12,  1 SAY "Content"
  SET COLOR TO
  SELECT dstruct1
  SET FILTER TO key = keyno
  SEEK keyno
  mline = 13
  mok = .F.
  DO WHILE .NOT. mok
    mnew = .F.
    IF new .OR. EOF()
      mnew = .T.
      APPEND BLANK
      REPLACE key WITH keyno
    ENDIF
    IF mline > 19
      @ 12, 1 CLEAR TO 19, 78
      mline = 13
    ENDIF
    SET COLOR TO n/w
    @ mline,  1 SAY line
    SET COLOR TO
    IF mnew
      @ 21, 20 SAY "Blank all to exit"
      @ mline,	1 GET line
      READ
      @ 21, 20 SAY SPACE(20)
      IF line=SPACE(10)
	DELETE
	mok = .T.
      ELSE
	mnew = .F.
      ENDIF
    ENDIF
    IF .NOT. mnew
      mediting = .T.
      DO WHILE mediting
	@ 22, 30 SAY "ABORT/Edit/Delete/Next : "
	DO WHILE .T.
	  mchoice = " "
	  @ 22, 55 GET mchoice PICTURE "!"
	  READ
	  IF mchoice$"AEDN"
	    EXIT
	  ENDIF
	ENDDO
	@ 22, 1 SAY SPACE(77)
	DO CASE
	   CASE mchoice = "A"
		mok = .T.
		mediting = .F.
	   CASE mchoice = "D"
		CLEAR GETS
		@ mline, 1 CLEAR TO mline, 78
		DELETE
		mediting = .F.
	   CASE mchoice = "N"
		@ mline,  1 SAY line
		mline = mline + 1
		mediting = .F.
	   CASE mchoice = "E"
		@ mline,  1 GET line
		READ
		mediting = .T.
	ENDCASE
      ENDDO
    ENDIF
    SKIP
  ENDDO
  @ 5,1 CLEAR TO 19, 78
  SET FILTER TO
RETURN

PROCEDURE dflowupd
PARAMETER new, keyno
  DO border WITH "DATA FLOW","DATA EDITING"
  DO WHILE .T.
    @  6,  4 SAY "Name: " + dflow0->name
    @  7,  4 SAY "Description: "
    @  7, 20 GET dflow0->descript1
    @  8, 20 GET dflow0->descript2
    @  9, 20 GET dflow0->descript3
    @ 10, 20 GET dflow0->descript4
    @ 11,  4 SAY "Source process:"
    @ 12, 20 GET dflow0->source1
    @ 14,  4 SAY "Destin process:"
    @ 14, 20 GET dflow0->destin1
    READ
    moption = "Y"
    @ 21, 28 SAY "Done(Y/N)?" GET moption PICTURE "!"
    READ
    @ 21,  1 SAY SPACE(77)
    IF moption = "Y"
      EXIT
    ENDIF
  ENDDO
  @ 11, 1 CLEAR TO 19, 78
  SET COLOR TO w+
  @ 12,  1 SAY "Content: "
  SET COLOR TO
  SELECT dflow1
  SET FILTER TO key = keyno
  SEEK keyno
  mline = 13
  mok = .F.
  DO WHILE .NOT. mok
    mnew = .F.
    IF new .OR. EOF()
      mnew = .T.
      APPEND BLANK
      REPLACE key WITH keyno
    ENDIF
    IF mline > 19
      @ 12, 1 CLEAR TO 19, 78
      mline = 13
    ENDIF
    SET COLOR TO n/w
    @ mline,  1 SAY line
    SET COLOR TO
    IF mnew
      @ 21, 20 SAY "Blank all to exit"
      @ mline,	1 GET line
      READ
      @ 21, 20 SAY SPACE(20)
      IF line=SPACE(10)
	DELETE
	mok = .T.
      ELSE
	mnew = .F.
      ENDIF
    ENDIF
    IF .NOT. mnew
      mediting = .T.
      DO WHILE mediting
	@ 22, 30 SAY "ABORT/Edit/Delete/Next : "
	DO WHILE .T.
	  mchoice = " "
	  @ 22, 55 GET mchoice PICTURE "!"
	  READ
	  IF mchoice$"AEDN"
	    EXIT
	  ENDIF
	ENDDO
	@ 22, 1 SAY SPACE(77)
	DO CASE
	   CASE mchoice = "A"
		mok =.T.
		mediting = .F.
	   CASE mchoice = "D"
		CLEAR GETS
		@ mline, 1 CLEAR TO mline, 78
		DELETE
		mediting = .F.
	   CASE mchoice = "N"
		@ mline,  1 SAY line
		mline = mline + 1
		mediting = .F.
	   CASE mchoice = "E"
		@ mline,  1 GET line
		READ
		mediting = .T.
	ENDCASE
      ENDDO
    ENDIF
    SKIP
  ENDDO
  @ 5,1 CLEAR TO 19, 78
  SET FILTER TO
RETURN

PROCEDURE dprocupd
PARAMETER new, keyno
  DO border WITH "PROCESS","DATA EDITING"
  DO WHILE .T.
    @  6,  4 SAY "Name: " + dproc0->name
    @  6, 54 SAY "Number: " GET dproc0->number
    @  7,  4 SAY "Description: "
    @  7, 20 GET dproc0->descript1
    @  8, 20 GET dproc0->descript2
    @  9, 20 GET dproc0->descript3
    @ 10, 20 GET dproc0->descript4
    @ 11, 4 SAY "Physical Reference: " GET dproc0->phyref
    READ
    moption = "Y"
    @ 21, 28 SAY "Done(Y/N)?" GET moption PICTURE "!"
    READ
    @ 21,  1 SAY SPACE(77)
    IF moption = "Y"
      EXIT
    ENDIF
  ENDDO
  SET COLOR TO w+
  @ 12,  1 SAY "Input"
  @ 12, 20 SAY "Logic summary"
  @ 12, 61 SAY "Output"
  SET COLOR TO
  SELECT dproc1
  SET FILTER TO key = keyno
  SEEK keyno
  mline = 13
  mok = .F.
  DO WHILE .NOT. mok
    mnew = .F.
    IF new .OR. EOF()
      mnew = .T.
      APPEND BLANK
      REPLACE key WITH keyno
    ENDIF
    IF mline > 19
      @ 12, 0 CLEAR TO 19, 79
      mline = 13
    ENDIF
    SET COLOR TO n/w
    @ mline,  1 SAY input
    @ mline, 20 SAY logsum
    @ mline, 61 SAY output
    SET COLOR TO
    IF mnew
      @ 21, 20 SAY "Blank all to exit"
      @ mline,	1 GET input
      @ mline, 20 GET logsum
      @ mline, 61 GET output
      READ
      @ 21, 20 SAY SPACE(20)
      IF input=SPACE(10) .AND. logsum=SPACE(40) .AND. output=SPACE(10)
	DELETE
	mok = .T.
      ELSE
	mnew = .F.
      ENDIF
    ENDIF
    IF .NOT. mnew
      mediting = .T.
      DO WHILE mediting
	@ 22, 30 SAY "ABORT/Edit/Delete/Next : "
	DO WHILE .T.
	  mchoice = " "
	  @ 22, 55 GET mchoice PICTURE "!"
	  READ
	  IF mchoice$"AEDN"
	    EXIT
	  ENDIF
	ENDDO
	@ 22, 1 SAY SPACE(77)
	DO CASE
	   CASE mchoice = "A"
		mok = .T.
		mediting = .F.
	   CASE mchoice = "D"
		CLEAR GETS
		@ mline, 1 CLEAR TO mline, 79
		DELETE
		mediting = .F.
	   CASE mchoice = "N"
		@ mline,  1 SAY input
		@ mline, 20 SAY logsum
		@ mline, 61 SAY output
		mline = mline + 1
		mediting = .F.
	   CASE mchoice = "E"
		@ mline,  1 GET input
		@ mline, 20 GET logsum
		@ mline, 61 GET output
		READ
		mediting = .T.
	ENDCASE
      ENDDO
    ENDIF
    SKIP
  ENDDO
  @ 5,1 CLEAR TO 19, 78
  SET FILTER TO
RETURN

PROCEDURE dstorep
  PRIVATE mstring, mname

  SELECT a
  USE dstore0 INDEX dstore00
  SELECT b
  USE dstore3 INDEX dstore33
  DO border WITH "PRINT REPORT", "DATA STORE"
  mname=SPACE(40)
  @ 5, 10 SAY "Enter name of data store: " GET mname
  @ 6, 10 SAY "(Leave blank to print all data stores)"
  READ
  SELECT dstore0
  IF mname#SPACE(40)
    SET FILTER TO name = mname
    SEEK mname
  ELSE
     GO TOP
  ENDIF
  IF EOF()
    @ 21, 12 SAY "Data store not found"
    RETURN
  ENDIF
  @ 5, 2 CLEAR TO 19, 77
  manswer = "N"
  @  6, 10 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dstore0
    mline = 1
    DO WHILE .NOT. EOF()
      mstring = "Data Store"
      @ mline, (80-LEN(mstring))/2 SAY mstring
      DO insline WITH mline, 3
      @ mline,	5 SAY "Name: " + dstore0->name
      @ mline, 55 SAY "Ref No: " + dstore0->refno
      DO insline WITH mline, 2
      @ mline,	5 SAY "Description: "
      @ mline, 20 SAY dstore0->descript1
      DO insline WITH mline, 1
      @ mline, 20 SAY dstore0->descript2
      DO insline WITH mline, 1
      @ mline, 20 SAY dstore0->descript3
      DO insline WITH mline, 1
      @ mline, 20 SAY dstore0->descript4
      DO insline WITH mline, 2
      @ mline, 5  SAY "Content: "
      SELECT dstore3
      SET FILTER TO key = dstore0->key
      SEEK dstore0->key
      DO WHILE .NOT. EOF()
	@ mline, 14 SAY dstore3->content
	DO insline WITH mline, 1
       SKIP
      ENDDO
      DO insline WITH mline, 2
      @ mline, 5 SAY "Access diagram can be found in: " + dstore0->access
      DO insline WITH mline, 3
      SELECT dstore0
      SKIP
    ENDDO
    ?
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

PROCEDURE delep
PRIVATE mstring, mname, mbreak

  SELECT a
  USE dele0 INDEX dele00
  SELECT b
  USE dele1 INDEX dele11
  SELECT c
  USE dele2 INDEX dele22

  DO border WITH "PRINT REPORT", "DATA ELEMENTS"
  @ 5, 2 CLEAR TO 19, 77
  mname=SPACE(40)
  @ 5, 10 SAY "Enter name of process: " GET mname
  @ 6, 10 SAY "(Leave blank to print all processes)"
  READ
  SELECT dele0
  IF mname#SPACE(40)
    SET FILTER TO name = mname
    SEEK mname
  ELSE
     GO TOP
  ENDIF
  IF EOF()
    @ 21, 12 SAY "Data element not found"
    RETURN
  ENDIF
  manswer = "N"
  @  6, 12 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dele0
    mline=1
    mstring = "Data Element"
    DO WHILE .NOT. EOF()
      DO insline WITH mline, 0
      @ mline, (80-LEN(mstring))/2 SAY mstring
      DO insline WITH mline, 3
      @ mline, 5 SAY "Name: " + dele0->name
      DO insline WITH mline, 2
      @ mline, 5 SAY "Type: " + dele0->type
      @ mline, 45 SAY "Length: " + dele0->length
      DO insline WITH mline, 2
      @ mline, 5 SAY "Description: "
      @ mline, 20 SAY dele0->descript1
      DO insline WITH mline, 1
      @ mline, 20 SAY dele0->descript2
      DO insline WITH mline, 1
      @ mline, 20 SAY dele0->descript3
      DO insline WITH mline, 1
      @ mline, 20 SAY dele0->descript4
      DO insline WITH mline, 1
      @ mline, 5 SAY "Alias: "
      SELECT dele1
      SET FILTER TO key = dele0->key
      SEEK dele0->key
      DO insline WITH mline, 3
      DO WHILE .NOT. EOF()
	@ mline, 10 SAY dele1->alias
	DO insline WITH mline, 1
	SKIP
      ENDDO
      DO insline WITH mline, 2
      @ mline, 10 SAY "Value"
      @ mline, 40 SAY "Meaning"
      DO insline WITH mline, 2
      SELECT dele2
      SET FILTER TO key = dele0->key
      SEEK dele0->key
      DO WHILE .NOT. EOF()
	@ mline,  5 SAY dele2->value
	@ mline, 35 SAY dele2->meaning
	DO insline WITH mline, 1
	SKIP
      ENDDO
      DO insline WITH mline, 3
      SELECT dele0
      SKIP
    ENDDO
    ?
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

PROCEDURE dstructp
  PRIVATE mstring, mname

  SELECT a
  USE dstruct0 INDEX dstruct00
  SELECT b
  USE dstruct1 INDEX dstruct11
  DO border WITH "PRINT REPORT", "DATA STRUCTURE"
  mname=SPACE(40)
  @ 5, 10 SAY "Enter name of data structure: " GET mname
  @ 6, 10 SAY "(Leave blank to print all data structure)"
  READ
  SELECT dstruct0
  IF mname#SPACE(40)
    SET FILTER TO name = mname
    SEEK mname
  ELSE
     GO TOP
  ENDIF  
  IF EOF()
    @ 21, 12 SAY "Data structure not found"
    RETURN
  ENDIF
  @ 5, 2 CLEAR TO 19, 77
  manswer = "N"
  @ 5, 10 CLEAR TO 6, 78
  @  6, 10 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dstruct0
    mline = 1
    mstring = "Data Structure"
    DO WHILE .NOT. EOF()
      @ mline, (80-LEN(mstring))/2 SAY mstring
      DO insline WITH mline, 3
      @ mline, 5 SAY "Name: " + dstruct0->name
      DO insline WITH mline, 2
      @ mline, 5 SAY "Description: "
      @ mline, 20 SAY dstruct0->descript1
      DO insline WITH mline, 1
      @ mline, 20 SAY dstruct0->descript2
      DO insline WITH mline, 1
      @ mline, 20 SAY dstruct0->descript3
      DO insline WITH mline, 1
      @ mline, 20 SAY dstruct0->descript4
      DO insline WITH mline, 2
      @ mline, 1  SAY "Content: "
      SELECT dstruct1
      SET FILTER TO key = dstruct0->key
      SEEK dstruct0->key
      DO WHILE .NOT. EOF()
	@ mline, 10 SAY dstruct1->line
 	DO insline WITH mline, 1
	SKIP
      ENDDO
      DO insline WITH mline, 3
      SELECT dstruct0
      SKIP
    ENDDO
    ?
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

PROCEDURE dflowp
  PRIVATE mstring, mname

  SELECT a
  USE dflow0 INDEX dflow00
  SELECT b
  USE dflow1 INDEX dflow11

  DO border WITH "PRINT REPORT", "DATA FLOW"
  mname=SPACE(40)
  @ 5, 10 SAY "Enter name of data flow: " GET mname
  @ 6, 10 SAY "(Leave blank to print all data flows)"
  READ
  SELECT dflow0
  IF mname#SPACE(40)
    SET FILTER TO name = mname
    SEEK mname
  ELSE
    GO TOP
  ENDIF
  IF EOF()
    @ 21, 12 SAY "Data flow not found"
    RETURN
  ENDIF
  @ 5, 2 CLEAR TO 19, 77
  manswer = "N"
  @  6, 10 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dflow0
    mline = 3
    mstring = "Data Flow"
    DO WHILE .NOT. EOF()
      @ mline, (80-LEN(mstring))/2 SAY mstring
      DO insline WITH mline, 3
      @ mline, 5 SAY "Name: " + dflow0->name
      DO insline WITH mline, 2
      @ mline, 5 SAY "Description: "
      @ mline, 20 SAY dflow0->descript1
      DO insline WITH mline, 1
      @ mline, 20 SAY dflow0->descript2
      DO insline WITH mline, 1
      @ mline, 20 SAY dflow0->descript3
      DO insline WITH mline, 1
      @ mline, 20 SAY dflow0->descript4
      DO insline WITH mline, 2
      @ mline, 5 SAY "Source process: "
      @ mline, 25 SAY dflow0->source1
      DO insline WITH mline, 2
      @ mline,	5 SAY "Destin process: "
      @ mline, 25 SAY dflow0->destin1
      DO insline WITH mline, 2
      @ mline, 5  SAY "Content: "
      SELECT dflow1
      SET FILTER TO key = dflow0->key
      SEEK dflow0->key
      DO WHILE .NOT. EOF()
	@ mline, 15 SAY dflow1->line
	DO insline WITH mline, 1
	SKIP
      ENDDO
      DO insline WITH mline, 3
      SELECT dflow0
      SKIP
    ENDDO
    ?
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

PROCEDURE dprocp
PRIVATE mstring, mname

  SELECT a
  USE dproc0 INDEX dproc00
  SELECT b
  USE dproc1 INDEX dproc11

  DO border WITH "PRINT REPORT", "PROCESS"
  mname=SPACE(40)
  @ 5, 10 SAY "Enter name of process: " GET mname
  @ 6, 10 SAY "(Leave blank to print all processes)"
  READ
  SELECT dproc0
  IF mname#SPACE(40)
    SET FILTER TO name = mname
    SEEK mname
  ELSE
    INDEX ON number TO temp
    USE dproc0 INDEX temp
    GO TOP
  ENDIF
  IF EOF()
    @ 21, 12 SAY "Process not found"
    RETURN
  ENDIF
  @ 5, 2 CLEAR TO 19, 77
  manswer = "N"
  @  6, 10 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dproc0
    mline=3
    mstring = "Process"
    DO insline WITH mline, 2
    DO WHILE .NOT. EOF()
      @ mline, (80-LEN(mstring))/2 SAY mstring
      DO insline WITH mline, 3
      @ mline, 5 SAY "Name: " + dproc0->name
      @ mline, 55 SAY "Ref: " + dproc0->number
      DO insline WITH mline, 2
      @ mline, 5 SAY "Description: "
      @ mline, 20 SAY dproc0->descript1
      DO insline WITH mline, 1
      @ mline, 20 SAY dproc0->descript2
      DO insline WITH mline, 1
      @ mline, 20 SAY dproc0->descript3
      DO insline WITH mline, 1
      @ mline, 20 SAY dproc0->descript4
      DO insline WITH mline, 2
      @ mline,	1  SAY "Input"
      @ mline, 20 SAY "Logic Summary"
      @ mline, 61 SAY "Output"
      DO insline WITH mline, 2
      SELECT dproc1
      SET FILTER TO key = dproc0->key
      SEEK dproc0->key
      DO WHILE .NOT. EOF()
	@ mline,  1 SAY dproc1->input
	@ mline, 20 SAY dproc1->logsum
	@ mline, 61 SAY dproc1->output
	DO insline WITH mline, 1
	SKIP
      ENDDO
      DO insline WITH mline, 5
      SELECT dproc0
      SKIP
    ENDDO
    ?
    IF FILE("temp.ndx")
      DELETE FILE temp.ndx
    ENDIF
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

PROCEDURE insline
PARAMETER mline, inc
  mline = mline + inc
  IF mline > 55
    mline = 3
  ENDIF
RETURN

PROCEDURE deledele
  DO border WITH "DATA ELEMENT", "DELETE RECORD"
  mname = dele0->name
  mkey  = dele0->key
  manswer = "N"
  @ 5, 10 SAY "Name : " + dele0->name
  @ 21, 20 SAY "Confirm Delete(Y/N)? " GET manswer PICTURE "!"
  READ
  IF manswer = "Y"
    DELETE

    SELECT dele1
    SET FILTER TO key = mkey
    DELETE ALL

    SELECT dele2
    SET FILTER TO key = mkey
    DELETE ALL
  ENDIF
RETURN

PROCEDURE dprocdel
  DO border WITH "PROCESS", "DELETE RECORD"
  mname = dproc0->name
  mkey  = dproc0->key
  manswer = "N"
  @ 5, 10 SAY "Name : " + dproc0->name
  @ 21, 20 SAY "Confirm Delete(Y/N)? " GET manswer PICTURE "!"
  READ
  IF manswer = "Y"
    DELETE
    SELECT dproc1
    SET FILTER TO key = mkey
    DELETE ALL
  ENDIF
RETURN

PROCEDURE dstrdele
  DO border WITH "DATA STRUCTURE", "DELETE RECORD"
  mname = dstruct0->name
  mkey  = dstruct0->key
  manswer = "N"
  @ 5, 10 SAY "Name : " + dstruct0->name
  @ 21, 20 SAY "Confirm Delete(Y/N)? " GET manswer PICTURE "!"
  READ
  IF manswer = "Y"
    DELETE

    SELECT dstruct1
    SET FILTER TO key = mkey
    DELETE ALL
  ENDIF
RETURN

PROCEDURE dstordel
  DO border WITH "DATA STORE", "DELETE RECORD"
  mname = dstore0->name
  mkey  = dstore0->key
  manswer = "N"
  @ 5, 10 SAY "Name : " + dstore0->name
  @ 21, 20 SAY "Confirm Delete(Y/N)? " GET manswer PICTURE "!"
  READ
  IF manswer = "Y"
    DELETE

    SELECT dstore3
    SET FILTER TO key = mkey
    DELETE ALL
  ENDIF
RETURN

PROCEDURE dflowdel
  DO border WITH "DATA FLOW", "DELETE RECORD"
  mname = dflow0->name
  mkey  = dflow0->key
  manswer = "N"
  @ 5, 10 SAY "Name : " + dflow0->name
  @ 21, 20 SAY "Confirm Delete(Y/N)? " GET manswer PICTURE "!"
  READ
  IF manswer = "Y"
    DELETE

    SELECT dflow1
    SET FILTER TO key = mkey
    DELETE ALL
  ENDIF
RETURN                                                                                
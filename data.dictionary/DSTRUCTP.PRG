  PRIVATE mstring, mname
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
  SELECT a
  USE dstruct0 INDEX dstruct00
  SELECT b
  USE dstruct1 INDEX dstruct11

  RESTORE FROM print
  GO TOP
  @ 5, 2 CLEAR TO 19, 77
  mname = space(40)
  @ 5,2 SAY "name of structure -> " GET mname
  READ
  manswer = "N"
  @ 5, 10 CLEAR TO 6, 78
  @  6, 10 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dstruct0
    IF .NOT. (mname = " ")
      SET FILTER TO name = mname
      SEEK mname
    ENDIF
    mstring = "DATA STRUCTURE"
    DO WHILE .NOT. EOF()
      ?
      ?
      ?
      ? SPACE((80-LEN(mstring))/2) + &setdwidth + mstring + &rstdwidth
      ?
      ?
      ? SPACE(5) + &setdstrike + "Name        : " + &rstdstrike + dstruct0->name
      ?
      ? SPACE(5) + &setdstrike + "Description : " + &rstdstrike + dstruct0->descript1
      ? SPACE(19) + dstruct0->descript2
      ? SPACE(19) + dstruct0->descript3
      ? SPACE(19) + dstruct0->descript4
      ?
      SELECT dstruct1
      SET FILTER TO key = dstruct0->key
      SEEK dstruct0->key
      ? SPACE(5) + &setdstrike + "Content : " + &rstdstrike + dstruct1->line
      DO WHILE .NOT. EOF()
        SKIP
        ? SPACE(15) + dstruct1->line
      ENDDO
      SELECT dstruct0
      SKIP
      eject
    ENDDO
    ?
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

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
  USE dproc0 INDEX dproc00
  SELECT b
  USE dproc1 INDEX dproc11

  RESTORE FROM print
  @ 5, 2 CLEAR TO 19, 77
  mname = SPACE(40)
  @ 5,2 SAY "name of process" GET mname
  READ
  manswer = "N"
  @  6, 10 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dproc0
    IF .NOT. (mname = " ")
      SET FILTER TO name = mname
      SEEK mname
    ENDIF
    mstring = "PROCESS"
    DO WHILE .NOT. EOF()
      ?
      ?
      ?
      ? SPACE((80-LEN(mstring))/2) + &setdwidth + mstring + &rstdwidth
      ?
      ?
      ? SPACE(5) + &setdstrike + "Name        : " + &rstdstrike + dproc0->name + &setdstrike + "Ref No : " + &rstdstrike + dproc0->number
      ?
      ?
      ? SPACE(5) + &setdstrike + "Description : " + &rstdstrike + dproc0->descript1
      ? SPACE(19) + dproc0->descript2
      ? SPACE(19) + dproc0->descript3
      ? SPACE(19) + dproc0->descript4
      ?
      ?
      ? SPACE(5) + &setdstrike + "Physical Ref : " + &rstdstrike + dproc0->phyref
      ?
      ?
      ? &setdstrike + "Input" + SPACE(15) + "Logic Summary" + SPACE(28) + "Output" + &rstdstrike
      ?
      SELECT dproc1
      SET FILTER TO key = dproc0->key
      SEEK dproc0->key
      DO WHILE .NOT. EOF()
        ? dproc1->input + " " + dproc1->logsum + " " + dproc1->output
        SKIP
      ENDDO
      SELECT dproc0
      SKIP
      eject
    ENDDO
    ?
    IF FILE("temp.ndx")
      DELETE FILE temp.ndx
    ENDIF
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

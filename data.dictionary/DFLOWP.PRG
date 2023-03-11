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
  USE dflow0 INDEX dflow00
  SELECT b
  USE dflow1 INDEX dflow11
  RESTORE FROM print
  @ 5, 2 CLEAR TO 19, 77
  mname = space(40)
  @ 5, 4 SAY "Name of dataflow -> " GET mname
  READ
  @ 7, 5 SAY "Set up printer.."
  READ
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dflow0
    IF .NOT. (mname = " ")
      SET FILTER TO name=mname
      SEEK mname
    ENDIF
    IF EOF()
       RETURN
    ENDIF
    mstring = "DATA FLOW"
    DO WHILE .NOT. EOF()
      ?
      ?
      ?
      ? SPACE((80-LEN(mstring))/2) + &setdwidth + mstring + &rstdwidth
      ?
      ?
      ?
      ?
      ?
      ? SPACE(5) + &setdstrike + "Name: " + &rstdstrike + dflow0->name
      ?
      ? SPACE(5)  + &setdstrike + "Description: " + &rstdstrike + dflow0->descript1
      ? SPACE(18) + dflow0->descript2
      ? SPACE(18) + dflow0->descript3
      ? SPACE(18) + dflow0->descript4
      ?
      ? SPACE(5) + &setdstrike + "Source : " + &rstdstrike + dflow0->source1
      ?
      ? SPACE(5) + &setdstrike + "Destination : " + &rstdstrike + dflow0->destin1
      ?
      SELECT dflow1
      SET FILTER TO key = dflow0->key
      SEEK dflow0->key
      ? SPACE(5) + &setdstrike + "Content: " + &rstdstrike + dflow1->line
      DO WHILE .NOT. EOF()
        SKIP
        ? SPACE(14) + dflow1->line
      ENDDO
      ENDIF
      SELECT dflow0
      SKIP
      eject
    ENDDO
    ?
    SET PRINT OFF
    SET DEVICE TO SCREEN
RETURN

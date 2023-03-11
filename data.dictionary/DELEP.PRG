PRIVATE mstring, mname, mbreak
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
  USE dele0 INDEX dele00
  SELECT b
  USE dele1 INDEX dele11
  SELECT c
  USE dele2 INDEX dele22

  RESTORE FROM print
  @ 5, 2 CLEAR TO 19, 77
  mname = space(40)
  @ 5, 2 SAY "Name of data element -> " GET mname
  READ
  manswer = "N"
  @  6, 12 SAY "Set paper to top of page."
  @  8, 20 SAY "Printer ready (Y/N) ? " GET manswer
  READ
  IF manswer$"Yy"
    SET PRINT ON
    SET DEVICE TO PRINT
    SELECT dele0
    IF .NOT. (mname = " ")
      SET FILTER TO name = mname
      SEEK mname
    ENDIF
    mstring = "DATA ELEMENT"
    DO WHILE .NOT. EOF()
      ?
      ?
      ?
      ? SPACE((80-LEN(mstring)*2)/2) + &setdwidth + mstring + &rstdwidth
      ?
      ?
      ?
      ?
      ? SPACE(5) + &setdstrike + "Name        : " + &rstdstrike + dele0->name
      ?
      ?
      ? SPACE(5) + &setdstrike + "Type : " + &rstdstrike + dele0->type + &setdstrike + SPACE(43) + &setdstrike + "Length : " + &rstdstrike + dele0->length
      ?
      ?
      ? SPACE(5) + &setdstrike + "Description : " + &rstdstrike + dele0->descript1
      ? SPACE(19) + dele0->descript2
      ? SPACE(19) + dele0->descript3
      ? SPACE(19) + dele0->descript4
      ?
      ?
      ?
      SELECT dele1
      SET FILTER TO key = dele0->key
      SEEK dele0->key
      ? SPACE(5) + &setdstrike + "Alias : " + &rstdstrike + dele1->alias
      DO WHILE .NOT. EOF()
        SKIP
        ? SPACE(13) + dele1->alias
      ENDDO
      ?
      ?
      ?
      ? SPACE(5) + &setdstrike + "Value" + SPACE(25) + "Meaning" + &rstdstrike
      ?
      SELECT dele2
      SET FILTER TO key = dele0->key
      SEEK dele0->key
      DO WHILE .NOT. EOF()
        ? SPACE(5) + dele2->value + SPACE(10) + dele2->meaning
        SKIP
      ENDDO
      SELECT dele0
      SKIP
      eject
      ?
    ENDDO
    SET PRINT OFF
    SET DEVICE TO SCREEN
  ENDIF
RETURN

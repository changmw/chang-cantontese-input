#include "inkey.ch"
#include "dbedit.ch"

function A_SECTION()
  * edit section data
  local M_SCR, DBFIELD, DBHEAD

  DBFIELD := { "S_CODE", "S_NAME1" }
  DBHEAD  := { "CODE", "NAME" }

  save screen to M_SCR
  clear
  SHOWHEAD("SECTION DATA")
  do INITPF
  SHOWPF("INS","CREATE",01)
  SHOWPF("DEL","DELETE",15)
  SHOWPF("ENTER","MODIFY",30)

  use SECTION new
  set index to SECTION1

  dbedit(03,05,22,75,DBFIELD,"BROWSECT",NIL,DBHEAD)
  restore screen from M_SCR

  close databases
return NIL

function BROWSECT(M_MODE, M_FLDPTR)
 local M_RC:=DE_CONT, M_SELECT
 private M_SCODE, M_SNAME1

  M_SELECT := select()
  set cursor on
  do case
    case M_MODE==DE_HITTOP .or. M_MODE==DE_HITBOTTOM
      tone(50,1)
    case M_MODE < DE_EXCEPT
    case lastkey()==K_ESC
      M_RC=DE_ABORT
    case lastkey()==K_INS
      do while lastkey()!=K_ESC
        do SECTCLRM
        SECTGETM(.t.)
        if lastkey()!=K_ESC
          seek M_SCODE
          if found()
            SAYINBOX("Duplicated section code!")
          else
            select SECTION
            append blank
            do SECTMOVF
          endif
        endif
      enddo
      M_RC=DE_REFRESH
   case lastkey()==K_ENTER
     if !eof()    && database not empty
       do SECTMOVM
       do SECTGETM with .f.
       if lastkey()!=K_ESC
         do SECTMOVF
       endif
     endif
   case lastkey()==K_DEL
     if !eof()
       if BOXASK(S_MSG,"PRESS <ENTER> TO CONFIRM DELETION")=chr(K_ENTER)
         delete
         skip
       endif
     endif
     M_RC=DE_REFRESH
  endcase
  set cursor off
  select (M_SELECT)
return M_RC

function SECTMOVM()
  select SECTION
  M_SCODE=S_CODE
  M_SNAME1=S_NAME1
return

function SECTMOVF()
  select SECTION
  replace S_CODE with M_SCODE, S_NAME1 with M_SNAME1
  commit
return NIL

function SECTGETM(M_EDIT)
  local M_SCR

  save screen to M_SCR
  @ 06,10 clear to 11,70
  @ 06,10 to 11,70
  @ 07,12 say "SECTION CODE:" get M_SCODE picture '@!' when M_EDIT
  @ row()+1, 12 say "SECTION NAME" get M_SNAME1
  read
  restore screen from M_SCR
return NIL

function SECTCLRM()
 select SECTION
 M_SCODE=space(len(S_CODE))
 M_SNAME1=space(len(S_NAME1))
return NIL

function A_AWARD()
  local M_SCR, DBFIELD[3], DBHEAD[3]

  DBFIELD[1]="S_CODE"
  DBFIELD[2]="A_CODE"
  DBFIELD[3]="A_NAME1"

  DBHEAD[1]="SECTION"
  DBHEAD[2]="AWARD"
  DBHEAD[3]="AWARD NAME"

  save screen to M_SCR
  clear
  do SHOWHEAD with "AWARDS DATA"
  do INITPF
  do SHOWPF with "INS","CREATE",01
  do SHOWPF with "DEL","DELETE",15
  do SHOWPF with "ENTER","MODIFY",30

  use SECTION new
  set index to SECTION1

  use AWARD new
  set index to AWARD1

  dbedit(03,05,22,78,DBFIELD,"BROWAWAR",NIL,DBHEAD)
  restore screen from M_SCR

  close SECTION
  close AWARD
return NIL

function BROWAWAR(M_MODE, M_FLDPTR)
  local M_RC, M_SELECT
  private M_SCODE, M_ACODE, M_ANAME1

  M_SELECT := select()
  set cursor on
  M_RC=DE_CONT
  do case
    case M_MODE==DE_HITTOP .or. M_MODE==DE_HITBOTTOM
      tone(50,1)
    case M_MODE < DE_EXCEPT
    case lastkey()==K_ESC
      M_RC=DE_ABORT
    case lastkey()==K_INS
      M_RC=DE_REFRESH
      do while lastkey()!=K_ESC
        do AWARCLRM
        AWARGETM(.t.)
        if lastkey()!=K_ESC
          select AWARD
          append blank
          do AWARMOVF
        endif
     enddo
    case lastkey()==K_ENTER
      if !eof()    && database not empty
       do AWARMOVM
       AWARGETM(.f.)
       if lastkey()!=K_ESC
        do AWARMOVF
       endif
      endif
    case lastkey()==K_DEL
      if !eof()
       if BOXASK(S_MSG,"PRESS <ENTER> TO CONFIRM DELETION")=chr(K_ENTER)
        delete
        skip
       endif
       M_RC=DE_REFRESH
      endif
  endcase
  set cursor off
  select (M_SELECT)
return M_RC

function AWARMOVM()
  select AWARD
  M_SCODE=S_CODE
  M_ACODE=A_CODE
  M_ANAME1=A_NAME1
return NIL

function AWARMOVF()
  select AWARD
  replace S_CODE with M_SCODE, A_CODE with M_ACODE, A_NAME1 with M_ANAME1
  commit
return NIL

function AWARGETM(M_EDIT)
  local M_SCR

  save screen to M_SCR
  @ 06,10 clear to 12,70
  @ 06,10 to 12,70
  @ 07,12 say "AWARD CODE: " get M_ACODE picture '@!' ;
                     valid V_DUPAWAR(M_ACODE) when M_EDIT
  @ row()+1, 12 say "AWARD NAME:"
  @ row()+1, 12 get M_ANAME1
  @ row()+1, 12 say "SECTION CODE: " get M_SCODE picture '@!' ;
                    valid V_SECTION(M_SCODE)
  read
  restore screen from M_SCR
return NIL

function V_DUPAWAR(M_ACODE)
  local M_FOUND

  if empty(M_ACODE)
    SAYINBOX(S_ERR,"AWARD CODE CANNOT BE EMPTY",3)
    return .f.
  endif
  select AWARD
  seek M_ACODE
  if found()
   SAYINBOX(S_ERR,"Award code already in use", 3)
   return .f.
  endif
return .t.

function AWARCLRM()
 select AWARD
 M_SCODE=space(len(S_CODE))
 M_ACODE=space(len(A_CODE))
 M_ANAME1=space(len(A_NAME1))
return NIL

function V_SECTION(M_SCODE)
  select SECTION
  seek M_SCODE
  if !found()
    SAYINBOX(S_ERR, "Section not found", 3)
    return .f.
  endif
return .t.

function A_ENTRY()
  local M_SCR, DBFIELD, DBHEAD

  DBFIELD := { "MARKED(FLAG)", "E_INDEX", "left(E_COMPANY,25)", ;
               "left(E_TITLE,30)" }

  DBHEAD  := { space(1), "INDEX", "PRODUCT/SERVICES", "ENTRY TITLE" }

  save screen to M_SCR
  clear
  SHOWHEAD("ENTRIES DATA")
  INITPF()
  SHOWPF("INS","CREATE",01)
  SHOWPF("DEL","DELETE",15)
  SHOWPF("ENTER","MODIFY",30)
  SHOWPF("F1", "SORT", 45)
  SHOWPF("F2", "MARK/UNMARK", 60)

  use AWARD new
  set index to AWARD1

  use ENTRY new
  set index to ENTRY1, ENTRY2, ENTRY3, ENTRY4
  set order to 1

  dbedit(03,02,22,77,DBFIELD,"BROWENTR",NIL,DBHEAD)
  restore screen from M_SCR

  close AWARD
  close ENTRY
return NIL

function BROWENTR(M_MODE, M_FLDPTR)
  local M_RC, M_SCR, M_SORT[3], M_CHOICE, M_SELECT
  private M_ACODE, M_ECODE, M_ETITLE, M_ECOMPANY

  M_SORT[1]=" BY INDEX "
  M_SORT[2]=" BY TITLE "
  M_SORT[3]=" BY AWARD "

  M_SELECT := select()
  set cursor on
  M_RC := DE_CONT
  do case
    case M_MODE == DE_HITTOP .or. M_MODE == DE_HITBOTTOM
      tone(50,1)
    case M_MODE < DE_EXCEPT
    case lastkey()==K_ESC
      M_RC=DE_ABORT
    case lastkey()==K_F1   && sort score sheet
      save screen to M_SCR
      M_CHOICE=0
      do while M_CHOICE==0
        M_CHOICE=BOXMENU(10,10,M_SORT,M_CHOICE,NIL,NIL,NIL,NIL,S_MENU)
      enddo
      set order to M_CHOICE
      go top
      restore screen from M_SCR
      M_RC=DE_REFRESH
    case lastkey()==K_INS
      do ENTRCLRM
      M_ACODE=A_CODE
      do ENTRGETM with .t.
      if lastkey()!=K_ESC
        select ENTRY
        append blank
        do ENTRMOVF
        keyboard chr(K_INS)
      endif
      M_RC=DE_REFRESH
    case lastkey()==K_ENTER
      if !eof()    && database not empty
        do ENTRMOVM
        do ENTRGETM with .f.
        if lastkey()!=K_ESC
          do ENTRMOVF
        endif
      endif
    case lastkey()==K_DEL
      if BOXASK(S_MSG,"PRESS <ENTER> TO DELETE MARKED RECORDS")=chr(K_ENTER)
        go top
        do while !eof()
          if FLAG
            delete
          endif
          skip
        enddo
        M_RC=DE_REFRESH
      endif
    case lastkey()==K_F2
      replace FLAG with iif(FLAG,.F.,.T.)
      skip
    otherwise
      seek upper(chr(lastkey()))
      M_RC=DE_REFRESH
  endcase
  set cursor off
  select (M_SELECT)
return M_RC

function ENTRMOVM()
 select ENTRY
 M_ACODE  =A_CODE
 M_ECODE  =E_CODE
 M_ETITLE =E_TITLE
 M_ECOMPANY=E_COMPANY
return NIL

function ENTRMOVF()
 select ENTRY
 replace E_CODE with M_ECODE, E_TITLE with M_ETITLE, ;
         E_COMPANY with M_ECOMPANY, A_CODE with M_ACODE, ;
         E_INDEX with A_CODE+"/"+E_CODE
 commit
return NIL

function ENTRGETM(M_EDIT)
  local M_SCR

  save screen to M_SCR
  @ 05,10 clear to 13,65
  @ 05,10 to 13,65
  @ 06,12 say "INDEX: " get M_ACODE picture '99' ;
                        valid V_AWARD(@M_ACODE) when M_EDIT
  @ row(),col() say '/'
  @ row(),col() get M_ECODE picture '9999' ;
                valid V_ENTRY(@M_ECODE) .and. V_DUPENTR(M_ACODE+"/"+M_ECODE) ;
                      .or. lastkey()==K_LEFT ;
                when M_EDIT
  @ row()+1, 12 say "PRODUCT/SERVICES:"
  @ row()+1, 12 get M_ECOMPANY picture '@!'
  @ row()+1, 12 say "ENTRY TITLE:"
  @ row()+1, 12 get M_ETITLE picture '@!'
  read
  restore screen from M_SCR
return NIL

function V_ENTRY(M_ECODE)
  local M_TEMP

  if empty(M_ECODE)
    SAYINBOX(S_ERR,"ENTRY CODE CANNOT BE BLANK",3)
    return .f.
  endif

  * pad leading zero
  M_TEMP=alltrim(M_ECODE)
  if len(M_TEMP)<4
    M_ECODE=replicate("0",4-len(M_TEMP))+M_TEMP
    keyboard chr(K_ENTER)
    return .f.
  endif
return .t.

function V_AWARD(M_ACODE)
  local M_TEMP

  select AWARD
  M_TEMP := alltrim(M_ACODE)
  M_ACODE=replicate("0",2-len(M_TEMP))+M_TEMP
  seek M_ACODE
  if !found()
    SAYINBOX(S_ERR,"AWARD CODE NOT FOUND", 3)
    return .f.
  endif
return .t.

function V_DUPENTR(M_EINDEX)
  * check if duplicated entry code in a given award

  select ENTRY
  seek M_ACODE+M_EINDEX
  if found()
    SAYINBOX(S_ERR, "INDEX ALREADY ENTERED", 3)
    return .f.
  endif
return .t.

function ENTRCLRM()
  select ENTRY
  M_ACODE=space(len(A_CODE))
  M_ECODE=space(len(E_CODE))
  M_ETITLE=space(len(E_TITLE))
  M_ECOMPANY=space(len(E_COMPANY))
return NIL

function A_JUDGE()
  * edit section data
  local M_SCR, DBFIELD[3], DBHEAD[3]

  DBFIELD[2]="J_NAME"
  DBFIELD[1]="J_CODE"

  DBHEAD[2]="NAME"
  DBHEAD[1]="CODE"

  save screen to M_SCR
  clear
  SHOWHEAD("JUDGE DATA")
  INITPF()
  SHOWPF("INS","ADD",01)
  SHOWPF("DEL","DELETE",15)
  SHOWPF("ENTER","MODIFY",30)

  use JUDGE new
  set index to JUDGE1

  dbedit(03,05,22,75,DBFIELD,"BROWJUD",NIL,DBHEAD)
  restore screen from M_SCR

  close JUDGE
return NIL

function BROWJUD(M_MODE, M_FLDPTR)
  local M_RC := DE_CONT, M_SELECT
  private M_JCODE, M_JNAME

  set cursor on      
  M_SELECT := select()
  do case
    case M_MODE==DE_HITTOP .or. M_MODE==DE_HITBOTTOM
      tone(50,1)
    case M_MODE < DE_EXCEPT
    case lastkey()==K_ESC
      M_RC=DE_ABORT
    case lastkey()==K_INS
      M_RC=DE_REFRESH
      do while lastkey()!=K_ESC
        do JUDCLRM
        JUDGETM(.t.)
        if lastkey()!=K_ESC
          select JUDGE
          append blank
          do JUDMOVF
        endif
      enddo
    case lastkey()==K_ENTER
      if !eof()    && database not empty
        do JUDMOVM
        JUDGETM(.f.)
        if lastkey()!=K_ESC
          do JUDMOVF
        endif
      endif
    case lastkey()==K_DEL
      if BOXASK(S_MSG,"PRESS <ENTER> TO CONFIRM DELETION")=chr(K_ENTER)
        go top
        do while !eof()
          if FLAG
            delete
          endif
          skip
        enddo
      endif
      M_RC=DE_REFRESH
  endcase

  select (M_SELECT)
return M_RC

function JUDMOVM()
  select JUDGE
  M_JCODE  =J_CODE
  M_JNAME  =J_NAME
return NIL

function JUDMOVF()
  select JUDGE
  replace J_CODE with M_JCODE, J_NAME with M_JNAME
  commit
return NIL

function JUDGETM(M_EDIT)
  local M_SCR
  save screen to M_SCR
  @ 06,15 clear to 13,60
  @ 06,15 to 13,60
  @ 07,      17 say "JUDGE CODE: " ;
                get M_JCODE picture '@!' valid V_DUPJCODE(M_JCODE) when M_EDIT
  @ row()+1, 17 say "JUDGE NAME: " get M_JNAME
  read
  restore screen from M_SCR
return NIL

function V_DUPJCODE(M_JCODE)
  select JUDGE
  if empty(M_JCODE)
    SAYINBOX(S_ERR,"JUDGE CODE CANNOT BE EMPTY",3)
    return .f.
  endif
  seek M_JCODE
  if found()
    SAYINBOX(S_ERR,"JUDGE CODE ALREADY ENTERED",3)
    return .f.
  endif
return .t.

function JUDCLRM()
  select JUDGE
  M_JCODE =space(len(J_CODE))
  M_JNAME =space(len(J_NAME))
return NIL

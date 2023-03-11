*
* Scoring System for 4A's Creative Awards
*
* Date: April 20-May 3, 1991
* Programmed and Copyrighted by  Chang Man Wai
*
* Events: Apr 17 91 .. Receive priliminary spec
*         Apr 27 91 .. Entries data received from 4A
*         Apr 29 91 .. Data Entry section of program fully tested
*         Feb    92 .. revised with Clipper 5.01
*         Mar    92 .. revised with Clipper 5.01
*
*                   Data Entry started
*
* There are three types of awards:
*    1. Category Award
*    2. Kam Fan
*    3. Chinese Craft
*
* There are two scoring schemes:
*    1. Marks (1, 4, 8, and Abstain
*    2. YES/NO ratio
*
  #include "inkey.ch"

  local MANS, MANS0, M_SCR, MENU0[5], MENU1[5], MENU2[3], MENU4[3], MENUR[3]
  private SYSDATE, S_NORM, S_ERR, S_MSG, S_MENU[5]

  MENUR[1]=' 1. SECTION-AWARD LIST '
  MENUR[2]=' 2. ENTRIES LIST       '
  MENUR[3]=' 3. FINAL RESULTS      '

  MENU0[1]=' 1. MASTER FILES   '
  MENU0[2]=' 2. SCORE SHEETS   '
  MENU0[3]=' 3. REPORTS        '
  MENU0[4]=' 4. HOUSE-KEEPING  '
  MENU0[5]=' 5. DOS SHELL      '

  MENU1[1] =' 1. SECTION CODE & NAME   '
  MENU1[2] =' 2. AWARD INFORMATION     '
  MENU1[3] =' 3. ENTRY DATA            '
  MENU1[4] =' 4. JUDGE DATA            '
  MENU1[5] =' 5. ASSIGN JUDGE TO AWARD '

  MENU4[1]=' 1. REINDEX DATA FILES '
  MENU4[2]=' 2. PACK DATA FILES    '
  MENU4[3]=' 3. ZAP DATABASES      '

  * general system information
  SYSDATE = date()

  * video attributes
  S_NORM = 'W/N,N/W,,,W/N'
  S_MSG  = "N/W"
  S_ERR  = "W/R"

  * for BOXMENU()
  S_MENU[1] = 'N/W'              && White on Blue display
  S_MENU[2] = 'W/N'              && Black on Cyan menu bar
  S_MENU[3] = 'N/W'              && Bright Cyan on Blue Active Border
  S_MENU[4] = 'N/W'              && Regular Cyan on Blue In-active Border
  S_MENU[5] = 'W+/N'             && Yellow on Blue for the selected option

  * operating environment
  set exclusive on
  set scoreboard off
  set exact on
  set deleted on
  set unique off
  set confirm off
  set date british
  set delimiter on
  set delimiter to "[]"
  setcolor(S_NORM)

  LOGO()

  MANS0=1
  do while MANS0 != 0
    MANS0=BOXMENU(05,05,MENU0,MANS0,NIL,NIL,NIL,NIL,S_MENU)
    do case
      case MANS0==1         && file maintenance
        mans=1
        do while MANS!=0
          save screen to M_SCR
          MANS=BOXMENU(07,20,MENU1,MANS,NIL,NIL,NIL,NIL,S_MENU)
          restore screen from M_SCR
          do case
            case mans=1       && section name
              do A_SECTION
            case mans=2       && award names in each section
              do A_AWARD
            case mans=3       && entries for each award
              do A_ENTRY
            case mans=4       && judge information
              do A_JUDGE
            case mans=5
              do AWA_JUD
          endcase
        enddo
      case mans0==2                 && score sheets maintenance
        do SS_MAINT
      case mans0==3                 && reporting routines
        mans=1
        do while MANS!=0
          save screen to M_SCR
          MANS=BOXMENU(07,20,MENUR,MANS,NIL,NIL,NIL,NIL,S_MENU)
          restore screen from M_SCR
          do case
            case mans=1            && List awards
              do LISTAWAR
            case mans=2            && List entries
              do LISTENTR
            case mans=3
              do SPECIAL1
          endcase
        enddo
      case mans0==4                 && house-keeping
        mans=1
        do while MANS!=0
          save screen to M_SCR
          MANS=BOXMENU(10,20,MENU4,MANS,NIL,NIL,NIL,NIL,S_MENU)
          restore screen from M_SCR
          do case
            case mans=1
              do A_INDEX
            case mans=2
              do A_PACK
            case mans=3
              do A_ZAP
          endcase
        enddo
      case mans0==5
        save screen to M_SCR
        SAYINBOX(S_MSG,"TYPE 'EXIT' TO RETURN FROM DOS",3)
        clear
        run command
        restore screen from M_SCR
    endcase
  enddo

  clear all
  clear
return NIL

function A_PACK()
  local M_SCR
  private M_FNAME

  save screen to M_SCR
  SAYINBOX(S_MSG, "PACKING DATA FILES ...")

  * section master files
  SAYINBOX(S_MSG,"PACKING SECTION.DBF")
  use SECTION new
  set index to SECTION1
  pack
  close SECTION

  * award master file
  SAYINBOX(S_MSG,"PACKING AWARD.DBF")
  use AWARD new
  set index to AWARD1
  pack
  close AWARD

  * entry master file
  SAYINBOX(S_MSG,"PACKING ENTRY.DBF")
  use ENTRY new
  set index to ENTRY1, ENTRY2, ENTRY3, ENTRY4
  pack
  close ENTRY

  * judge master file
  SAYINBOX(S_MSG,"PACKING JUDGE.DBF")
  use JUDGE new
  set index to JUDGE1
  pack
  close JUDGE

  * relation files
  SAYINBOX(S_MSG,"PACKING AWARJUDG.DBF")
  use AWARJUDG new
  set index to AWARJUD1
  pack
  close AWARJUDG

  * re-construct index files for the scoresheets
  SAYINBOX(S_MSG,"PACKING SS.DBF")
  use SS new
  set index to SS1
  pack

  if BOXASK(S_MSG,"PRESS <ENTER> TO PACK SCORE SHEET DATABASES")=chr(K_ENTER)
    go top
    do while !eof()
      M_FNAME=rtrim(SS_NAME)
      SAYINBOX(S_MSG,"PACKING ... "+M_FNAME)
      use (M_FNAME) new
      set index to &M_FNAME.1, &M_FNAME.2
      pack
      close (M_FNAME)

      select SS
      skip
    enddo
  endif
  close SS

  restore screen from M_SCR
return NIL

function A_INDEX()
  local M_SCR
  private M_FNAME

  save screen to M_SCR
  // section master files
  SAYINBOX(S_MSG,"INDEXING SECTION.DBF ...")
  use SECTION new
  index on S_CODE to SECTION1
  close SECTION

  // award master file
  SAYINBOX(S_MSG,"INDEXING AWARD.DBF ...")
  use AWARD new
  index on A_CODE to AWARD1
  close AWARD

  // entry master file
  SAYINBOX(S_MSG,"INDEXING ENTRY.DBF ...")
  use ENTRY
  index on E_INDEX        to ENTRY1
  index on E_TITLE        to ENTRY2
  index on A_CODE         to ENTRY3
  index on A_CODE+E_INDEX to ENTRY4

  // judge master file
  SAYINBOX(S_MSG,"INDEXING JUDGE.DBF ...")
  use JUDGE
  index on J_CODE to JUDGE1

  // relation files
  SAYINBOX(S_MSG,"INDEXING AWARJUDG.DBF ...")
  use AWARJUDG
  index on A_CODE+J_CODE to AWARJUD1

  // re-construct index files for the scoresheets
  SAYINBOX(S_MSG,"INDEXING SS.DBF")
  use SS
  index on A_CODE to SS1
  set index to SS1

  if BOXASK(S_MSG,"PRESS <ENTER> TO INDEX SCORE SHEET DATABASES")=chr(K_ENTER)
    go top
    do while !eof()
      M_FNAME=rtrim(SS_NAME)
      SAYINBOX(S_MSG,"INDEXING ... "+M_FNAME)
      select 0
      use &M_FNAME.
      index on E_INDEX to &M_FNAME.1
      index on DESCEND(TOTALSCORE) to &M_FNAME.2
      use

      select SS
      skip
    enddo
  endif

  close databases
  restore screen from M_SCR
return NIL

function A_ZAP()
  local M_SCR, M_ZAP
  private M_FNAME

  save screen to M_SCR
  @ 05,15 clear to 10,65
  @ 05,15 to 10,65

  M_ZAP=space(3)
  @ 07,20 say 'PASSWORD: ' get M_ZAP
  read
  if M_ZAP="YES"
    SAYINBOX(S_MSG, "ZAPPING FILES ...")

    * section master files
    SAYINBOX(S_MSG,"CLEANING SECTION.DBF")
    use SECTION new
    set index to SECTION1
    zap
    close SECTION

    * award master file
    SAYINBOX(S_MSG,"CLEANING AWARD.DBF")
    use AWARD new
    set index to AWARD1
    zap
    close AWARD

    * entry master file
    SAYINBOX(S_MSG,"CLEANING ENTRY.DBF")
    use ENTRY new
    set index to ENTRY1, ENTRY2, ENTRY3
    zap
    close ENTRY

    * judge master file
    SAYINBOX(S_MSG,"CLEANING JUDGE.DBF")
    use JUDGE new
    set index to JUDGE1
    zap
    close JUDGE

    * relation files
    SAYINBOX(S_MSG,"CLEANING AWARJUDG.DBF")
    use AWARJUDG new
    set index to AWARJUD1
    zap
    close AWARJUDG

    * re-construct index files for the scoresheets
    use SS new
    set index to SS1
    go top
    do while !eof()
      SAYINBOX(S_MSG,"CLEANING "+SS_NAME)
      M_FNAME=alltrim(SS_NAME)+".DBF"
      delete file (M_FNAME)
      M_FNAME=alltrim(SS_NAME)+".NTX"
      delete file (M_FNAME)
      select SS
      skip
    enddo
    SAYINBOX(S_MSG,"CLEANING SS.DBF")
    select SS
    zap
    close SS
  endif
  restore screen from M_SCR
return NIL

function LOGO()
 local M_4A[10], M_I

 M_4A[1]="        €€€        ‹€€ﬂﬂﬂ€€‹ "
 M_4A[2]="       €€€        ‹€€     €€‹"
 M_4A[3]="      €€€  €€€    €€€     €€€"
 M_4A[4]="     €€€   €€€    €€€‹‹‹‹‹€€€"
 M_4A[5]="    €€€‹‹‹‹€€€‹   €€€     €€€"
 M_4A[6]="           €€€    €€€     €€€"
 M_4A[7]="           €€€    €€€     €€€ ' S    C R E A T I V E   A W A R D S"
 M_4A[8]="ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ"
 M_4A[9]="scoring system"

 clear

 setcolor("rg+/n")
 for M_I = 1 to 7
    @ 14+M_I, 05 say M_4A[M_I]
 next
 setcolor("w+/n")
 @ 22, 05 say M_4A[8]
 setcolor("b+/n")
 @ 23, 60 say "WAI@DP.SRH"
 setcolor("w/n")
 @ 23, 05 say M_4A[9]
return NIL

** END Main Program **

function CENTER(mtitle)
return((80-len(mtitle))/2)

function SHOWHEAD(subtitle)
  local mtitle

  mtitle="4A's CREATIVE AWARDS SCORING SYSTEM"
  setcolor("w+")
  @ 00, 00 clear to 02,79
  @ 00, (80-len(alltrim(MTITLE)))/2 SAY alltrim(MTITLE)
  @ 00, 70 say sysdate
  @ 01, (80-len(subtitle))/2 SAY subtitle
  setcolor(S_NORM)
return NIL

// Show PF keys label on screen
function SHOWPF(pkey, plabel, ppos)
  setcolor("w+/n")
  @ 24, ppos say pkey
  setcolor("n/w")
  @ 24, ppos+len(pkey)+1 say plabel
  setcolor(S_NORM)
return NIL

function HIDEPF(pkey, plabel, ppos)
  setcolor("n/w")
  @ 24, ppos say space(len(pkey))
  @ 24, ppos+len(pkey)+1 say space(len(plabel))
  setcolor(S_NORM)
return NIL

* clear PF key label area
function INITPF
  setcolor("n/w")
  @ 24, 0 clear to 24, 79
  setcolor(S_NORM)
return NIL

function WORDDATE(p_date)
return str(day(p_date),2,0)+space(1)+cmonth(p_date)+space(1)+;
       str(year(p_date),4,0)

function CONTROLW()
  keyboard chr(K_CTRL_W)
return NIL

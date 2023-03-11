clear all
set talk off
set exact on
set date british
set century off
set exclusive off
set deleted on
set escape off
set mouse on

  public G_TPATH, G_FILTER, G_USER
  private a_statname, a_status
  declare a_statname[3], a_status[3]

  g_tpath = "."
  g_filter = ""
  G_USER = getenv("USRID")

  a_statname[1]="NEW"
  a_statname[2]="FAILED"
  a_statname[3]="PASSED"

  a_status[1]="N"
  a_status[2]="F"
  a_status[3]="P"

  define window w_refresh ;
    from 00,00 to 03,10 ;
    title "refresh"

  DEFINE POPUP mnu_edit MARGIN SHADOW COLOR SCHEME 4
  DEFINE BAR 1 OF mnu_edit PROMPT "\<Modify (Coder)"
  DEFINE BAR 2 OF mnu_edit PROMPT "\<New    (Coder)"
  DEFINE BAR 3 OF mnu_edit PROMPT "\-"
  DEFINE BAR 4 OF mnu_edit PROMPT "\<Test   (Tester)"
  DEFINE BAR 5 OF mnu_edit PROMPT "\-"
  DEFINE BAR 6 OF mnu_edit PROMPT "\<Search"
  DEFINE BAR 7 OF mnu_edit PROMPT "\<Delete"
  DEFINE BAR 8 OF mnu_edit PROMPT "\<Report"
  ON SELECTION BAR 1 OF mnu_edit do =mp2("y2kjobed.spr","C")
  ON SELECTION BAR 2 OF mnu_edit do =mp2("y2kjobed.spr","N")
  ON SELECTION BAR 4 OF mnu_edit do =mp2("y2kjobed.spr","T")
  ON SELECTION BAR 6 of mnu_edit do =mp2("y2ksch.spr")
  ON SELECTION BAR 7 OF mnu_edit do =mp2("y2kjobdl")
  ON SELECTION BAR 8 OF mnu_edit do =mp2("y2krpt.spr")

  on error do errhand with error(), message(), message(1), program(), lineno()
  on error

  if !file("y2k.dbf")
    create table y2k ( ;
      system   C(3), ;
      menukey  C(5), ;
      menuname C(60), ;
      cdr_name C(3), ;
      cod_date D, ;
      tsr_name C(3), ;
      tst_date D, ;
      status   C(1), ;
      program  c(8), ;
      subprog  M, ;
      comment  M ;
    )
    index on SYSTEM+MENUKEY tag MASTER
    use in y2k
  endif

  use y2k shared
  if !used("y2k")
    wait window "File in use. Try later!"
    return
  endif
  set order to MASTER
  locate

  ** best browse combo
  set color of scheme 1 to
  set color of scheme 22 TO w/n, n/gb, g/g, rg+/g, n/w, n/w, n/w

  define window w_browse ;
    from 00,00 to 24,79 ;
    title "Y2K CHANGE LOG" ;
    footer "<ENTER> for menu" ;
    color scheme 22
  activate window w_browse

  push key clear
  on key label rightmouse do showmenu
  on key label enter    do showmenu
  on key label del      do y2kjobdl
  on key label ins      do y2kjobed.spr with "N"

  browse fields ;
    system:r:h="", ;
    menukey:r:h="Menu",  ;
    menuname:r:30:h="Description",    ;
    program:r:h="Program",  ;
    cdr_name:r:h="CODE", ;
    cod_date:r:h="Date", ;
    tsr_name:r:h="TEST", ;
    tst_date:r:h="Date", ;
    aa=padr(comment,40):r:h="Comment", ;
    bb=padr(subprog,50):r:h="Sub-Program" ;
    noappend nodelete ;
    in window w_browse

  close all

  release window w_browse
  release window w_refresh

  pop key

  on error

  set sysmenu off
  set escape on
  set help on
  set exact off
  set century off
return

procedure y2kjobdl
  push key clear
  wait window "Delete? (Y/N)"
  if upper(chr(lastkey()))="Y"
    delete
    skip
    if eof()
      go bottom
    endif
    activate window w_refresh
    deactivate window w_refresh
  endif
  pop key
return

procedure showmenu
  push key clear
  if row() < 15
    activate popup mnu_edit at row(), wcol()/2
  else
    activate popup mnu_edit at row()-7, wcol()/2
  endif
  pop key
return

function setprntr
parameter m.mode, m.landscape
  ?? prncmd("L","R")
  if m.mode>0
    if m.LANDSCAPE
      ?? prncmd("L","L")
    endif
    ?? prncmd("L","N")
  endif
return ""

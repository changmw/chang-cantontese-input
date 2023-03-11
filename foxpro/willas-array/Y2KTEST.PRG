#define K_ESC   27
#define K_C_W   23

set talk off
set escape off

* notes:
*
* 1. You can still input 2-digit years after setting century on
* 2. This method won't work with browse
*

set date british
set udfparms to value

public y2k_date, y2k_var
public mm_count
public Y2K_ROLOV

Y2K_ROLOV = ctod("01/01/1960")

mm_count = 0

=test5()

set procedure to
set talk on
set escape on
return

function test5
private m.xx
  set procedure to y2k
  m.xx = 9901
  ? m.xx, y2k_wkno(m.xx)
  m.xx = 0001
  ? m.xx, y2k_wkno(m.xx)
return

function test4
private m.xx
  set procedure to y2k
  m.xx = "VP99-121212"
  ? m.xx, y2k_dcnr(m.xx,3)
  m.xx = "VP1223-0005"
  ? m.xx, y2k_dcnr(m.xx,8)
  m.xx = "VP1223-0005"
  ? m.xx, y2k_dcnr(m.xx)
return

procedure test1
private a_cdate, ii
declare a_cdate[7,2]
  clear
  set century on
  set procedure to yy2k

  a_cdate[1,1]="01/02/00"
  a_cdate[1,2]=0
  a_cdate[2,1]="01\02/00"
  a_cdate[2,2]=0
  a_cdate[3,1]="01/01/93"
  a_cdate[3,2]=0
  a_cdate[4,1]="01/01/99"
  a_cdate[4,2]=99
  a_cdate[5,1]="29/02/00"
  a_cdate[5,2]=0
  a_cdate[6,1]="00/00/00"
  a_cdate[6,2]=0
  a_cdate[7,1]="01/01/  "
  a_cdate[7,2]=0

  for ii=1 to alen(a_cdate)/2
   if a_cdate[ii,2] != 0
     ? "y2k_ctod('"+a_cdate[ii,1]+"', "+str(a_cdate[ii,2],2)+")="
     ?? y2k_ctod(a_cdate[ii,1], a_cdate[ii,2])
   else
     ? "y2k_ctod('"+a_cdate[ii,1]+"')="
     ?? y2k_ctod(a_cdate[ii,1])
   endif
  endfor

  wait window "End of "+program()
return

procedure test2
private m.mydate
  *
  * the original code:
  *
  * @ 05,05 say "Date: " get m.ddate range {01/01/1998}, {01/01/3099}
  *
  private a_date, ii, dtmn, dtmx, m.dummy
  declare a_date[3]

  set procedure to yy2k

  a_date[1]= {}
  a_date[2]= {}
  m.mydate = {01/01/1902}
  m.dummy = space(1)

  dtmn = date()
  dtmx = date()+365

  clear
  clear typeahead

set safety off
  create table testdbf ( mydate D )
  append blank
set safety on

  set century off
  @ 05,05
* @ row()+1,05 say "a_date[1]: " get a_date[1] ;
*       picture "99/99/99" ;
*       when y2k_when() ;
*       valid y2k_valid()
* @ row()+1,05 say "a_date[2]: " get a_date[2] ;
*       picture "99/99/99" ;
*       when y2k_when() ;
*       valid y2k_valid() and !xempty(a_date[2])
  m.mydate = {}
  @ row()+1,05 say "m.mydate:  " get m.mydate ;
        picture "99/99/99" ;
        when y2k_when() ;
        valid y2k_valid() and m.mydate<ctod("01/01/2010")
  @ row()+1,05 say "m.dummy:  " ;
        get m.dummy ;
        when display()
  read  cycle
  =y2k_clear()
  set century on

  set century off
  select testdbf
  list
  use in testdbf
  erase testdbf.dbf
  set century on
  wait window "End of "+program() timeout 3
return

function display
  @ 04,     40 say "previous value"
  @ row()+1,40 say replicate("-",20)
  @ row()+1,40 say dtos(a_date[1])
  @ row()+1,40 say dtos(a_date[2])
  @ row()+1,40 say dtos(m.mydate)
  @ row(),  55 say dtos(testdbf.mydate)
return .t.

function myvalid
  wait window "MYVALID("+dtos(m.mydate)+")" timeout 1
  if m.mydate>ctod("01/01/2000")
    return .f.
  endif
return .t.

function xempty
parameter m.dd
  @ 20,10 clear
  @ 20,10 say type("m.dd")
  @ row(),col()+5 say m.dd
  @ row()+1,10 say "Iteration "+str(mm_count,5)
  mm_count = mm_count+1
return empty(m.dd)

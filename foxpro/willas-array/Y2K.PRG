*************************************************************
*    START OF Y2K ROUTINES
*************************************************************
*
* version: 19991220 (7TH REVISION)
*          19990103 (8th REVISION)
* requires variables: Y2K_VAR, Y2K_DATE, Y2K_RLOV
* initialization:     Y2K_ROLOV = {dd/mm/yyyy}
*                     Y2K_VAR  = .f.
*                     Y2K_DATE = .f.
*
* variables are usually declare in DPPGINGV.PRG
* routes are usually appended to PROCEDR2.PRG
*
function y2k_when
*
* convert the current get-object into a character string
* and start the read
*
  y2k_var  = varread()
  if left(y2k_var, 2) != "M."
    if !("("$y2k_var)
      y2k_var = "M."+y2k_var
    endif
  endif
  * store old value for y2k_clear()
  if type(y2k_var)!="C"
    y2k_date = eval(y2k_var)
    &y2k_var = dtoc(y2k_date)
  endif
return .t.

function y2k_valid
*
* this function must be called BEFORE all other validation
* logic in the user programs
*
* convert and store the date value in the current get object
* back to the variable
*
private m.outdate
  * note: the case of browse is not handled
  if type(Y2K_VAR) = "D"
    m.outdate = eval(Y2K_VAR)
    &y2k_var = dtoc(eval(y2k_var))
  else
    m.outdate = y2k_ctod(eval(Y2K_VAR))
  endif
  if eval(y2k_var) != "  /  /  "
    * user didn't enter empty date
    if empty(m.outdate)
      * invalid date after conversion
      return .f.
    endif
  endif
  &y2k_var = m.outdate
return .t.

function y2k_ctod
parameter m.cdate, m.nyear
private m.rollover, m.yy, o_date
*
* NOTE: y2k_date() uses american/british date!
*
* using m.nyear (default: 60 if Y2K_ROLOV not defined)
* as the rollover year, convert a character string into date
*
if len(m.cdate)>8
  * date's year has more than 2 digit
  return ctod(m.cdate)
else
  do case
    case parameters() > 1
      * caller specified rollover year
      m.rollover = m.nyear
    case type("Y2K_ROLOV")="D"
      m.rollover = mod(year(Y2K_ROLOV),100)
    otherwise
      m.rollover = 60
  endcase
  m.yy = right(m.cdate, 2)
  return ctod(left(m.cdate,6)+iif(val(m.yy) > m.rollover, "19", "20")+m.yy)
endif

function y2k_clear
*
* restore the old value of the affected variable
* should user aborted the read
*
* 2 methods to call y2k_clear():
* 1.   read
*      do y2k_clear
* 2.   read
*      =y2K_clear()
* 3.   read valid y2k_clear()
*
  if type("Y2K_VAR") = "C"
    if type(Y2K_VAR) != "D"
      * user pressed escape, y2k_valid() not executed!
      &y2k_var = y2k_date
    endif
  endif
  y2k_var = .f.
return .t.

function y2k_dcnr
parameter m.dcnr, m.yypos
private m.century
  if parameters() > 1
    * note: if Y2K_ROLOV is changed AFTER the index was built,
    * the index that used this function MUST be rebuilt!
    m.century = iif(val(substr(m.dcnr,m.yypos,2)) < mod(year(Y2K_ROLOV),100), "20", "19")
  else
    m.century = "00"
  endif
return m.century+m.dcnr

function y2k_wkno
parameter m.wkno
* format of wkno: yyww (* NUMBERIC *)
return iif(int(m.wkno/100) < mod(year(Y2K_ROLOV),100), 20, 19)*10000+m.wkno

function y2k_year
parameter m.yy
if type("m.yy")="N"
  return iif(m.yy > mod(year(Y2K_ROLOV),100),19,20)*100+m.yy
endif
return iif(val(m.yy) > mod(year(Y2K_ROLOV),100),"19","20")+m.yy

function y2k_yymm
parameter m.yymm
if type("m.yymm")="N"
 iif(val(left(m.yymm,2))>mod(year(Y2K_ROLOV),100),19,20)*100+m.yymm
endif
return iif(val(left(m.yymm,2))>mod(year(Y2K_ROLOV),100),"19","20")+m.yymm

************************************************************
*     END OF Y2K ROUTINES
************************************************************

*
* ULPG0033 -- A/R Pattern Report
*
* 19/03/00 : MW CHANG, created
*
parameter m.p1
private m.outfile, m.errfile

if parameter()=0 or empty(m.p1)
  m.outfile=G_DPATH+"\"+G_BSAB+"0033.TXT"
else
  m.outfile=m.p1
endif

wait window nowait "Preparing ..."

* load internal company's names
m.ok = .f.
select 0
use (g_dpath+"\INVENTRY") noupdate
if used()
  select 0
  use (g_dpath+"\COMPMFGR") noupdate
  if used()
    m.ok = .t.
  endif
endif
if !m.ok
  close database
  wait window nowait "unable to open INVENTRY"
  return
endif

select MFGR, DSTN, IMNR, INVENTRY.IMRD ;
  from INVENTRY, COMPMFGR ;
  where INVENTRY.MFNR==COMPMFGR.MFNR ;
    and QTYB > 0 ;
  order by MFGR, DSTN ;
  into cursor T_REPORT

select T_REPORT
set relation to IMRD into INVENTRY
set printer on
?? prncmd("PCL", "RESET")+prncmd("PCL","LANDSCAPE")+prncmd("PCL","12CPI")+prncmd("PCL","6LPI")
report form ulpg0000 to printer
?? prncmd("PCL", "RESET")
set printer off
set printer to
set printer to

close databases
return

function prncmd
parameter m.model, m.action, m.p3, m.p4, m.p5
private m.xx, m.esc, m.pcount
  m.pcount=parameters()
  m.esc = chr(27)
*
* example to print white text on black rectangle
*
* ??? prncmd("PCL", "GOTOXY", 100, 100)
* ??? prncmd("PCL", "RECTANGLE", 1500, 1500, 75)
* ??? prncmd("PCL", "REVERSE")
* ??? prncmd("PCL","PROPORT")+prncmd("PCL", "ARIAL", 30)
* ??? prncmd("PCL", "GOTOXY", 1500,713)
* ??? "ABCD"
* ??? prncmd("PCL", "RESET")
*
  do case
    case m.model=="PCL"
      * laserjet PCL commands
      do case
        case m.action="MANUAL FEED"
          return m.esc+"&l2H"
        case m.action="REVERSE"
          return m.esc+"*v0n1o1T"
        case m.action="RECTANGLE"
          if m.pcount<5
            m.p5=20
          endif
          return m.esc+"*c"+;
                 alltrim(str(m.p5))+"g"+;
                 alltrim(str(m.p3))+"a"+;
                 alltrim(str(m.p4))+"b"+;
                 "2P"
        case m.action=="PUSH"
          return m.esc+"&f0S"
        case m.action=="POP"
          return m.esc+"&f1S"
        case m.action=="COPIES"
          return m.esc+"&l"+alltrim(str(m.p3))+"X"
        case m.action=="ROTATE"
          return m.esc+"&a"+alltrim(str(m.p3))+"P"
        case m.action=="BOX"
          return m.esc+"&l6D"+m.esc+"(s10H"+m.esc+"(s0S"
        case m.action=="SIZE"
          return m.esc+"(s"+alltrim(str(m.p3))+"V"
        case m.action=="PC8"
          return m.esc+"(10U"
        case inlist(m.action, "ARIAL", "TIMES NEW ROMAN", "COURIER", "SYMBOL")
          do case
            case m.action=="ARIAL"
              m.xx = "16602"
            case m.action=="TIMES NEW ROMAN"
              m.xx = "16901"
            case m.action=="SYMBOL"
              m.xx = "16686"
            otherwise
              * courier
              m.xx = "4099"
          endcase
          if empty(m.p3)
            * size of font not specified
            return m.esc+"(s"+m.xx+"T"
          endif
          return m.esc+"(s"+alltrim(str(m.p3))+"v"+m.xx+"T"
        case m.action=="FIXED"
          return m.esc+"(s0P"
        case m.action=="PROPORT"
          return m.esc+"(s1P"
        case m.action=="ROW"
          return m.esc+"&a"+alltrim(str(m.p3))+"R"
        case m.action=="COL"
          return m.esc+"&a"+alltrim(str(m.p3))+"C"
        case m.action=="GOTOCR"
          return m.esc+"&a"+alltrim(str(m.p4))+"r"+alltrim(str(m.p3))+"C"
        case m.action=="GOTOXY"
          return m.esc+"*p"+alltrim(str(m.p4))+"x"+alltrim(str(m.p3))+"Y"
        case m.action=="RESET"
          return m.esc+chr(69)
        case m.action=="PORTRAIT"
          return m.esc+"&l0O"
        case m.action=="LANDSCAPE"
          return m.esc+"&l1O"
        case m.action=="PITCH"
          return m.esc+"(s"+alltrim(str(m.p3))+"H"
        case m.action=="16CPI"
          return m.esc+"&k2S"
        case m.action=="12CPI"
          return m.esc+"&k4S"
        case m.action=="10CPI"
          return m.esc+"&k0S"
        case m.action=="LPI"
          return m.esc+"&l"+alltrim(str(m.p3))+"D"
        case m.action=="6LPI"
          return prncmd("PCL","LPI",6)
        case m.action=="8LPI"
          return prncmd("PCL","LPI",8)
        case m.action=="NORMAL"
          return m.esc+"(s0p0s0b"
        case m.action=="THIN"
          return m.esc+"(s-5B"
        case m.action=="BOLD"
          return m.esc+"(s3B"
        case m.action=="ITALIC"
          return m.esc+"(s1S"
        case m.action=="CONDENSED"
          return m.esc+"(s4S"
        case m.action=="OUTLINE"
          return m.esc+"(s32S"
        case m.action=="SHADOW"
          return m.esc+"(s128S"
        case m.action=="UNDERLINE"
          return m.esc+"&d0D"
        case m.action=="UNDERLINE OFF"
          return m.esc+"&d@"
        otherwise
          wait window nowait "UNKNOWN ESC CODE: "+m.action
      endcase
    case m.model=="LQ570"
      do case
        case m.action=="RESET"
          return m.esc+"@"
        case m.action=="12CPI"
          return m.esc+"M"
        case m.action=="10CPI"
          return m.esc+"P"
        case m.action=="15CPI"
          return m.esc+"g"
        otherwise
          wait window nowait "UNKNOWN ESC CODE: "+m.action
      endcase
  endcase
return ""

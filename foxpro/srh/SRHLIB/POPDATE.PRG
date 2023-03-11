  *
  *--   Name: POPDATE.PRG
  *-- Author: Andrew Coupe, PC Mgazine
  *--  Usage: <expD>=POPDATE(<row>, <col>, [<default>])
  *--   Note: UDF to popup a data selection box in FoxPro 1.02
  *
  parameters ROW, COL, DEFAULT
  private THISMSG, I, NEWDATE, THISDATE
  define window W_CAL from ROW, COL to ROW+16, COL+22 double title '[CALENDAR]'

  THISMSG  = set('MESSAGE',1)
  THISDATE = _diarydate

  DEFAULT = iif(parameters()=3, DEFAULT, _diarydate)
  _diarydate = DEFAULT

  _diarydate = DEFAULT
  activate window W_CAL
  activate window CALENDAR in W_CAL
  move window CALENDAR to -1, -1
  do while lastkey()#27
    I=inkey(0,'H')
    do case
      case I=13 .or. I==27                && Enter or Esc
        exit
      case I=84 .or. I=116                && 'T' for Today
        _diarydate=date()
      case I=24                           && Down Arrow
        _diarydate=_diarydate+7
      case I=5                            && Up Arrow
        _diarydate=_diarydate-7
      case I=19                           && Left Arrow
        _diarydate=_diarydate-1
      case I=4                            && Right Arrow
        _diarydate=_diarydate+1
      case I=3                            && Page Up
        _diarydate=gomonth(_diarydate,1)
      case I=18                           && Page Down
        _diarydate=gomonth(_diarydate,-1)
      case I=30                           && ^Page Down
        _diarydate=gomonth(_diarydate,12)
      case I=31                           && ^Page Up
        _diarydate=gomonth(_diarydate,-12)
    endcase
  enddo
  set message to (THISMSG)
  release window W_CAL
  NEWDATE = iif(lastkey()=27, DEFAULT, _diarydate)
  _diarydate=THISDATE
return NEWDATE

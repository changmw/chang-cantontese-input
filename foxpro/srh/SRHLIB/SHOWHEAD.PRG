*- display system title and sub-title
*- current date is shown in the upper right corner
*- EXTERNAL SYSNAME, SYSDATE, U_NAME
*-
*- Written by Chang Man Wai
*- Modified by Adam Chan
*-
*- Usage:  <win_name> = SHOWHEAD(<subtitle>)
*- Note:   <win_name> is unique only within the same day
*-------------- generate a new window
  parameters M_SUBTITLE
  private W_NAME

  W_NAME = "W_"+alltrim(str(seconds()*1000))
  if wexist(W_NAME)
     release window (W_NAME)
  endif
  define window (W_NAME) from 0,0 to 2,79 color n/w,n/w,n/w none
  activate window (W_NAME)
  clear
  @ 00, centre(sysname,80) say SYSNAME
  @ row(),00 say U_NAME
  @ 01, centre(M_SUBTITLE,80) say M_SUBTITLE picture '@!'
  @ 01,70 say SYSDATE
  @ 02,00 say replicate('_', 80)
return W_NAME
*: EOF: SHOWHEAD.PRG

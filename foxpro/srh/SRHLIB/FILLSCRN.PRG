  *- SRH Internal Use Only
  *- written by Chang Man Wai
  * Purpose... Fill a window with characters
  * Usage..... FILLSCRN(<character>)
  parameter P_CHAR
  private M_I

  for M_I=0 to wrows()-1
    @ M_I,00 say replicate(P_CHAR,80)
  endfor
return

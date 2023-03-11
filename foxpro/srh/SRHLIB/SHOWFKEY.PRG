  * display function key labels
  * SRH Internal Use Only
  *- Written by Chang Man Wai
  *- Usage...  SHOWFKEY(<position>, <key label>, <description>, <window>)
  *
  parameters M_POS, M_LABEL, M_KEY, W_NAME
  activate window (W_NAME)

  set color to w+/n
  @ 00, M_POS say M_LABEL
  set color to n/w
  @ 00, M_POS+len(M_LABEL)+1 say M_KEY
  set color to (A_NORMAL)
return

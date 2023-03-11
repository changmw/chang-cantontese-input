function INKEYBOX
*- written by Chang Man Wai
*- prompt user in window and get a key
*- SRH Internal Use Only
parameter P_MSG
  private M_BOX, M_KEY
  define window M_BOX from 07,20 to 11,60 color n/w,w/n,n/w ;
        double shadow
  activate window M_BOX
  @ 01,centre(P_MSG,40) say P_MSG

  M_KEY=abs(inkey(0))      && beware of negative values

  release window M_BOX  
return M_KEY

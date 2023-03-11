  *  function ASKYN
  *
  *- written by Chang Man Wai
  *- prompt user Y/N in window and get a key
  *- return 'Y' or 'N'
  *- SRH Internal Use Only
  *
  parameter M_MSG
  private M_KEY, M_LEFT, M_RIGHT

  M_MSG=upper(left(alltrim(M_MSG), 75))         && maximum message length
  if len(M_MSG) < 25
    M_LEFT  = 27 	&& minimum size of window
    M_RIGHT = 53
  else
    M_LEFT  = 40-int(len(M_MSG)/2)-1
    M_RIGHT = 40+int(len(M_MSG)/2)+1
  endif

  push key clear
  define window W_ASKYN from 07, M_LEFT to 12, M_RIGHT ;
                        color n/w,w/n,n/w double shadow
  activate window W_ASKYN

  M_MSG=M_MSG+'?'
  
  clear typeahead
  M_KEY=1
  @ 01,00 say rtrim(padc(M_MSG,wcol()-1))
  @ 03,(wcol()-23)/2 get M_KEY ;
                     function '*HT NO ;YES' size 1,9,5 ;
                     color ,,,,,,w+/n,,w/n
  read cycle

  release window W_ASKYN
  pop key
return iif(M_KEY=1,'N','Y')

  * display an error message on top of the function key label area
  * the bell will be sounded and the message can be cleared by
  * user pressing a key or after 3 seconds
  * SRH Internal Use Only
  * Written by Chang Man Wai
  *-
  * Usage...  ERRMSG(<error message>)
  *
  parameter M_EMSG
  
  private M_KEY

  =tone(512,2)
  wait upper(M_EMSG) window timeout 5
return

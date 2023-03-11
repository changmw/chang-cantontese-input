  parameter P_ROW, P_COL, P_LENGTH, P_PASS
  *
  *  1. Accept user input echoing '*' at given position (password input)
  *     (P_PROW, P_COL) is the place where the '*' is display
  *     P_LENGTH is the number of characters to receive
  *     P_PASS is the user input string to be returned
  *  2. Return value is the lastkey of input
  *
  *  SRH Internal Use Only
  *  Written by Chang Man Wai
  *
  private M_I, M_CHARIN
  
  P_PASS=''
  M_I=0
  @ P_ROW,P_COL+M_I say ''            && move cursor to starting position
  do while .t.
    M_CHARIN=inkey(0)
    do case
      case M_CHARIN=13 .or. M_CHARIN=27   && ESC or ENTER
        exit
      case M_CHARIN=127                   && BACKSPACE
        if M_I > 0
          M_I = M_I - 1
          P_PASS=left(P_PASS,M_I)
          @ P_ROW, P_COL+M_I+1 say space(1)
        endif
      otherwise                          && build the string
        if M_I < P_LENGTH                && echo a '*' for each char input
          P_PASS=P_PASS+upper(chr(M_CHARIN))
          M_I=M_I + 1
          @ P_ROW, P_COL+M_I say '*'
        endif
    endcase
  enddo
return M_CHARIN

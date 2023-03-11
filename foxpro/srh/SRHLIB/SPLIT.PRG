parameters P_IN, P_CUTAT
  *- this function returns the location of the space in a string P_IN
  *- where the given string P_IN can be cut into two halves of
  *- maximum length P_CUTAT without hypening the last word in the first
  *- half. Return 0 if no ideal point can be found
  *- SRH Internal Use Only
  *- created by Chang Man Wai
  private M_I

  M_I=P_CUTAT+1
  do while substr(P_IN,M_I,1)#space(1) .and. M_I>0
    M_I=M_I-1
  enddo
return M_I

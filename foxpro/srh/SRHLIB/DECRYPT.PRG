function decrypt
  parameter P_STRING
  *- edited by Chang Man Wai
  *-
  private F_TEMP, F_LENGTH, F_X

  F_TEMP   = ''
  F_LENGTH = len(P_STRING)

  for f_x = 1 to F_LENGTH
    F_TEMP = F_TEMP + chr(asc(substr(P_STRING,F_X,1))-101-F_X)
  endfor
return (F_TEMP)

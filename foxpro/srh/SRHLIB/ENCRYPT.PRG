  parameter P_STRING
  *- edited by Chang Man Wai
  private F_TEMP, F_LENGTH, F_X

  F_TEMP   = ''
  F_LENGTH = len(alltrim(P_STRING))

  for F_X = 1 to F_LENGTH
    *-- to encrypt, take character, convert to ascii value, then
    *-- add 101 plus its position in the string to it, then convert
    *-- back to a character
    F_TEMP = F_TEMP + chr( asc(substr(P_STRING,F_X,1) ) + 101 + F_X)
  next
return (F_TEMP)

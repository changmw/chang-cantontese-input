*
* function SRHWALL()
*
* A wall paper for SRH Information Systems
*
* written by Chang Man Wai
*
  private M
  declare M[9]

  * display logo
  M[01]='∞€€€€€€∞∞€€€€€€€∞∞€€∞∞∞∞€€'
  M[02]='€€∞∞∞∞€€∞∞€€∞∞∞€€∞€€∞∞∞∞€€'
  M[03]='€€∞∞∞∞∞∞∞∞€€∞∞∞€€∞€€∞∞∞∞€€'
  M[04]='∞€€€€€€∞∞∞€€€€€€∞∞€€€€€€€€'
  M[05]='∞∞∞∞∞∞€€∞∞€€∞∞∞€€∞€€∞∞∞∞€€'
  M[06]='€€∞∞∞∞€€∞∞€€∞∞∞€€∞€€∞∞∞∞€€'
  M[07]='∞€€€€€€∞∞∞€€∞∞∞€€∞€€∞∞∞∞€€'
  M[08]='∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞'
  M[09]='    INFORMATION SYSTEMS   '

  set color to w/n
  @ 00,00,24,79 box replicate(chr(176),9)
* for M_I=0 to 7
*   @ wrow()-11+M_I, wcol()-30 say M[M_I+1]
* endfor
* @ row()-11+M_I+4, wcol()-30 say M[9] color n/w
  @ 22,30 say 'Chang Man-Wai Copyright 1993. All Rights Reserved.'
return

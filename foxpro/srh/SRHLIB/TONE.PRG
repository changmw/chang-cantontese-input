  *-
  *- procedure TONE
  *- Sound the speaker using given frequency and duration
  *- written by Chang Man Wai
  *
  *- Usage... TONE(<frequency>, <duration>)
  *
  parameters M_FREQ, M_DURATION

  define window W_TONE from 00,00 to 00,00 none noshadow
  activate window W_TONE noshow

  set bell to M_FREQ, M_DURATION
  ? chr(7)
  set bell to

  release window W_TONE
return

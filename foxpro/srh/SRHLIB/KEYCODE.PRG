  *
  * procedure KEYCODE
  *
  * Written: Chang Man Wai
  *
  * inkey() and readkey() return codes
  *
  * variables naming conventions (follow Clipper 5.01's INKEY.CH)
  *
  * K_<key>             the <key> alone
  * K_C_<key>           CTRL + <key>
  * K_A_<key>           ALT + <key>
  * K_S_<key>           SHIFT + <key>
  *
  public K_ESC, K_ENTER, K_SPACE, ;
         K_PGUP, K_PGDN, K_UP, K_DOWN, K_LEFT, K_RIGHT, K_HOME, K_END, ;
         K_C_W, ;
         K_F1, K_F2, K_F3, K_F5, K_F10, ;
         K_BS, K_INS, K_DEL

  K_ESC   = 27
  K_BS    = 127
  K_SPACE = 32

  K_PGUP  = 18
  K_PGDN  = 3
  K_HOME  = 1
  K_END   = 6

  K_LEFT  = 19
  K_RIGHT = 4
  K_DOWN  = 24
  K_UP    = 5

  K_ENTER = 13
  K_INS   = 22
  K_DEL   = 7

  K_F1    = 28
  K_F2    = -1
  K_F3    = -2
  K_F4    = -3
  K_F5    = -4
  K_F10   = -9

  K_C_W   = 23
return

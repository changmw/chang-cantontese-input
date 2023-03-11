*
* procedure SETPASS
* ----------------------------------------------------
* change one's password in SRH information systems
*
* Written: Chang Man Wai
*
* Input Paramters:   M_SYSTEM     X(8)
*                    U_NAME       X(8)
*
* Output Parameters: none
*
  parameters M_SYSTEM, U_NAME
  private M_PASS

  push key clear
  on key label f10 keyboard(chr(23))

  define window W_PASSWD from 17,15 to 22,65 shadow ;
         color n/w,,n/w,G+/W title "CHANGE PASSWORD"
  define window W_FKEY7 from 24,00 to 24,79 color n/w,n/w,n/w none

  do SHOWFKEY with 70,'F10','SAVE','W_FKEY7'

  select 0
  use &PU_PATH.USERS alias USERS
  if used('USERS')
    M_SYSTEM=upper(left(M_SYSTEM,8))
    U_NAME  =upper(left(U_NAME, 8))
    locate for USERID=U_NAME .and. SYSTEM=M_SYSTEM

    if rlock()
      M_PASS=space(8)
      activate window W_PASSWD
      @ 01,05 say 'Enter OLD Password:'

      if K_ESC != GETPASWD(01,25,len(USERS.PASSWORD),M_PASS)

        M_PASS=upper(M_PASS)
        if USERS.PASSWORD=ENCRYPT(M_PASS)
          M_PASS=space(8)

          do while .t.
            @ 02,05 say 'Enter NEW Password: ' get M_PASS picture '@!'
            read

            if lastkey()=K_ESC  && ESC quits applications
             exit
            endif

            if lastkey()=K_C_W        && CTRL-W save changes
              select USERS
              replace USERS.PASSWORD with ENCRYPT(M_PASS)
              =ERRMSG('PASSWORD CHANGED !!')
              exit
            endif
          enddo

        else
          do ERRMSG with 'INCORRECT OLD PASSWORD!'
        endif

      endif

    else
      do ERRMSG with 'RECORD IN USE. ATTEMPT FUNCTION LATER!'
    endif
  else
    do ERRMSG with 'File in use by DBA. Try later!'
  endif

  if used('USERS')
    use in USERS
  endif
  release window W_FKEY7
  release window W_PASSWD
  pop key
return

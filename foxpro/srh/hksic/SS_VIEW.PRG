  private W_HEAD

  define window FK_VIEW from 24,00 to 24,79 none noshadow color n/w
  define window W_VIEW from 05,40 to 22,78 shadow

  W_HEAD=SHOWHEAD("VIEW SAMPLES")
  =SHOWFKEY(01,"F1","FIND SAMPLE","FK_VIEW")

  if file("SAMPLE.DBF")
    select 0
    use SAMPLE
    if used('SAMPLE')
      select 0
      use &SIC_PATH.INFILE alias INFILE noupdate
      if used('INFILE')
        set order to tag SEQNO

        select SAMPLE
        set relation to SEQNO into INFILE
        push key clear
        on key label F1 do FIND_SAMP
        browse fields ;
               SAMPLE.SAMPLE_NO:h="SAMPLE #", ;
               SAMPLE.SEQNO:h="SEQ #", ;
               INFILE.INDUSTRY:h="INDUSTRY", ;
               INFILE.MPS:h="MPS", ;
               INFILE.TPU:h="TPU" ;
               window W_VIEW ;
               nodelete nomodify noappend
        pop key
      else
        =ERRMSG("INFILE.DBF in use. Try later!")
      endif
    else
      =ERRMSG("SAMPLE.DBF in use. Try later!")
    endif
  else
    =ERRMSG("PLEASE CREATE SAMPLES FIRST!")
  endif
  close databases
  release window (W_HEAD)
  release window W_VIEW
  release window FK_VIEW
return

procedure FIND_SAMP
  private M_KEY, M_ORDER, M_CUR

  push key clear
  do HOOKF10
  define window W_FIND from 05,15 to 10,65 shadow title "FIND SAMPLE"
  activate window W_FIND
  M_KEY=space(len(SAMPLE_NO))
  @ 01, 05 say "SEARCH FOR: " get M_KEY picture '@!'
  @ wrows()-1, 05 say "F10 - Begin Search" color w+/n
  read cycle
  if lastkey()#K_ESC
    M_CUR=recno()
    M_ORDER=order()
    set order to SAMPLE_NO
    seek M_KEY
    if .not. found()
      goto M_CUR
    endif
    set order to (M_ORDER)
  endif
  release window W_FIND
  pop key
return

  private W_HEAD, M_TIME, M_SAMPNO, M_IND, M_TPU, M_LEN, M_DBF
  W_HEAD=SHOWHEAD("SAMPLES GENERATION")

  define window W_SAMPLE from 05,30 to 22,79 ;
                color n/w,n/w,n/w shadow title "BEGIN AT "+time()

  set alternate to RSIM.LOG
  set alternate on

  activate window W_SAMPLE
  ? time()+space(1)+"Locking files ..."

  select 0
  use &SIC_PATH.HKSIC alias HKSIC noupdate exclusive
  if used("HKSIC")
    select 0
    use SAMP_IND noupdate exclusive
    if used('SAMP_IND')
      select 0
      use SAMPSPEC noupdate exclusive
      if used('SAMPSPEC')
        set order to tag SAMPLE_NO

        select HKSIC
        set order to 0

        M_TIME=seconds()

        create table UNIVERSE ( ;
            SAMPLE_NO   C(10), ;
            SIZE        N(6) )

        create table SAMPLE ( ;
            SAMPLE_NO   C(10), ;
            SEQNO       C(6), ;
            FLAG        C(1) )
        index on seqno tag seqno

        select SAMPSPEC
        scan
          create cursor F_UNIV ( ;
            SAMPLE_NO   C(10), ;
            SEQNO       C(6), ;
            FLAG        C(1) )

          M_SAMPNO=SAMPSPEC.SAMPLE_NO

          ? time()+space(1)+"Working on "+M_SAMPNO+"..."
          select SAMP_IND
          scan for SAMPLE_NO=M_SAMPNO
            M_IND=alltrim(SAMP_IND.INDUSTRY)
            if .not.empty(M_IND)
              M_MAXMPS=SAMPSPEC.MAX_MPS
              M_MINMPS=SAMPSPEC.MIN_MPS
              M_LEN   =len(M_IND)

              set talk on
              select SEQNO from HKSIC ;
                     where left(str(INDUSTRY,6,0),M_LEN)=M_IND and ;
                           MPS >= M_MINMPS and MPS <= M_MAXMPS and ;
                           empty(FLAG) ;
                     into table F_IND
              set talk off
              use in F_IND
              select F_UNIV
              append from F_IND
            endif
          endscan

          select UNIVERSE
          append blank
          select F_UNIV
          replace UNIVERSE.SAMPLE_NO with M_SAMPNO, ;
                  UNIVERSE.SIZE      with reccount()
          replace all SAMPLE_NO with M_SAMPNO
          select SEQNO from F_UNIV into cursor M_TEMP
          do case
            case SAMPSPEC.SIZE < reccount()
              do DRAW with SAMPSPEC.SIZE, reccount()
            otherwise
              select F_UNIV
              replace all FLAG with "X"
          endcase

          select F_UNIV
          M_DBF=dbf()
          select SAMPLE
          append from (M_DBF) for .not.empty(FLAG)
          use in F_UNIV
        endscan

        select SAMPLE
        index on SAMPLE_NO tag SAMPLE_NO
        index on SEQNO tag SEQNO

        ? time()+space(1)+"SAMPLE.DBF stored in current directory!"
        ? time()+space(1)+"SAMPLE generated in "+str( (second()-M_TIME)/60,3,0 )+" MINUTES!"
        wait window
      else
        =ERRMSG("SAMPSPEC.DBF in use. Try later!")
      endif
    else
      =ERRMSG("SAMP_IND.DBF in use. Try later!")
    endif
  else
    =ERRMSG("HKSIC.DBF in use. Try later!")
  endif

  close databases
  delete file F_IND.DBF
  delete file F_TPU.DBF

  set alternate off
  set alternate to

  release window (W_HEAD)
  release window W_SAMPLE
return

procedure DRAW
  parameter SAM_SIZE, MAX_REC
  private M_I, M_J

  select F_UNIV

  ? time()+space(1)+"Drawing ... "
  ?? transform(SAM_SIZE,"999999") + "/" + transform(MAX_REC,"999999")+chr(7)
  for M_I=1 to SAM_SIZE
    M_J=int(rand()*(MAX_REC-1))+1
    select M_TEMP
    goto M_J
    select F_UNIV
    locate for SEQNO=M_TEMP.SEQNO
    do while .not.empty(F_UNIV.FLAG) .or. .not.found()
*      ? time()+space(1)+"REJECT: "+transform(M_J,"999999")
      M_J=int(rand()*(MAX_REC-1))+1
      select M_TEMP
      goto M_J
      select F_UNIV
      locate for SEQNO=M_TEMP.SEQNO
    enddo
    replace F_UNIV.FLAG with 'X'
  endfor

  select F_UNIV
  set order to 0
return

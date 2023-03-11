  * mark clients that are owner of the attribute records
  * selected by FILT_MAS.PRG
  clear all
  private M_NAME, M_I, M_TEL, ;
          M_SAME_LOC, M_SAME_COM, ;
          M_NEXTCLI, ;
          M_NEXTATTR, ;
          M_START, ;
          M_NEXTADD
  declare M_ADD[4]

  set odometer to 1000
  set talk off
  set deleted on
  set safety off
 
  select 0
  use \srhis\maillist\data\client alias client
  select 0
  use \srhis\maillist\data\company alias company
  select 0
  use \srhis\maillist\data\aux_mas alias aux_mas
  select 0
  use \srhis\maillist\data\categ alias categ

  select CATEG
  set order to CAT_CODE

  select COMPANY
  set order to COM_CODE
  set relation to COU_CODE into CATEG

  select CLIENT                 && clear attributes
  set order to tag MAS_CODE
  set relation to COM_CODE into COMPANY

  select distinct COM_CODE, MAS_CODE ;
         from AUX_MAS ;
         order by COM_CODE ;
         where MAS_CODE > 0 ;
         into cursor FAUX

  select MAS_CODE, AUX_CODE from AUX_MAS ;
      where MAS_CODE > 0 and (AUX_TYPE="G" or AUX_TYPE="D") ;
      into cursor FATTR

  select FAUX
  set relation to MAS_CODE into CLIENT

  create table addrbook ( ;
    col_1 c(30), ;
    col_2 c(30), ;
    col_3 c(4),  ;
    col_4 c(4) ;
  )

  M_NAME=replicate("Z",len(COMPANY.COM_NAME))
  for M_I=1 to 4
    M_ADD[M_I]=space(len(COMPANY.COM_ADD1))
  endfor
  M_NEXTCLI=1
  select FAUX
  scan
    select ADDRBOOK

    * new company?
    M_SAME_COM=.t.
    if COMPANY.COM_NAME#M_NAME or empty(COMPANY.COM_NAME)
      M_SAME_COM = .f.
    endif

    * new address ?
    M_SAME_LOC=.t.
    if COMPANY.COM_ADD1#M_ADD[1] .or. COMPANY.COM_ADD2#M_ADD[2] .or. ;
       COMPANY.COM_ADD3#M_ADD[3] .or. COMPANY.COM_ADD4#M_ADD[4]
        M_SAME_LOC=.f.
    endif

    if .not. M_SAME_LOC
      M_ADD[1] = COMPANY.COM_ADD1
      M_ADD[2] = COMPANY.COM_ADD2
      M_ADD[3] = COMPANY.COM_ADD3
      M_ADD[4] = COMPANY.COM_ADD4

      * init next client name's row number
      M_NEXTCLI=recno()
    endif

    * new company name
    if (not M_SAME_COM) and M_SAME_LOC
       M_NAME=COMPANY.COM_NAME
       append blank
       replace col_1 with iif(empty(COMPANY.COM_NAME),"##",COMPANY.COM_NAME)

       * location of first client information
       M_START=recno()
    endif

    * print address only if different company address
    if not M_SAME_LOC
      append blank
      replace col_1 with proper(COMPANY.COM_ADD1)
    endif
    if not M_SAME_LOC
      append blank
      replace col_1 with proper(COMPANY.COM_ADD2)
    endif
    if not M_SAME_LOC
      append blank
      replace col_1 with proper(COMPANY.COM_ADD3)
    endif
    if not M_SAME_LOC
      append blank
      replace col_1 with proper(COMPANY.COM_ADD4)
    endif
    append blank
    append blank

    * next company address's row number
    M_NEXTADD=recno()

    * list clients of a company
    select ADDRBOOK
    if M_SAME_LOC
      goto M_NEXTCLI
    else
      goto M_START
    endif
    replace COL_2 with proper(alltrim(CLIENT.F_NAME)+space(1)+CLIENT.L_NAME)

    * location of next attribute, should begin on the row of client name
    M_NEXTATTR=recno()

    =AB_SKIP()
    if empty(CLIENT.TIT)
      replace COL_2 with "--"
    else
      replace COL_2 with proper(alltrim(CLIENT.TIT))
    endif

    =AB_SKIP()
    replace COL_2 with "Direct: "+rtrim(iif(empty(CLIENT.TEL_DIR),CLIENT.TEL,CLIENT.TEL_DIR))
    if not empty(CLIENT.FAX)
      =AB_SKIP()
      replace col_2 with "FAX: "+rtrim(CLIENT.FAX)
    endif

    =AB_SKIP()
    =AB_SKIP()
    M_NEXTCLI=recno()

    * display business natures of each client
    M_CLIENT=FAUX.MAS_CODE
    select AUX_CODE ;
      from FATTR ;
      where MAS_CODE=M_CLIENT ;
      into cursor FCAT
    M_CATCOL=.t.

    select ADDRBOOK
    goto M_NEXTATTR
    select FCAT
    scan
      select ADDRBOOK
      if M_CATCOL
        replace COL_3 with FCAT.AUX_CODE
        M_CATCOL=.f.
      else
        replace COL_4 with FCAT.AUX_CODE
        =AB_SKIP()
        M_CATCOL=.t.
      endif
    endscan

    select ADDRBOOK
    go bottom
  endscan

  close all
return

procedure ADRBK_H
  ? chr(12)
  ?
  ? "Date: "+longdate()+;
    space(50)+"Page: "+str(_pageno,3,0)
  ? padc("SRH Mailing List System",80)
  ? padc("Address Book",80)
  ? padc(replicate("=",12),80)
  ?
return

function AB_SKIP
  skip
  if eof()
    append blank
    return 1
  endif
return 0

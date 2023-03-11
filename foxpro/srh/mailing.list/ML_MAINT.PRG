* -------------------------------------------------
* System Maintenance
* -----------------------------------------------
* FPACK() is a SRHIS library function

* PROCEDURE ML_MAINT

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_SYS_MOD FROM 09,15 SHADOW
  DEFINE BAR 1 OF W_SYS_MOD PROMPT 'INDEX FILE GENERATOR'
  DEFINE BAR 2 OF W_SYS_MOD PROMPT 'PURGE DELETED RECORDS'
  DEFINE BAR 3 OF W_SYS_MOD PROMPT 'RECORD COUNT'
  DEFINE BAR 4 OF W_SYS_MOD PROMPT 'CHECK DATABASE INTEGRITY'
  ON SELECTION POPUP W_SYS_MOD DO PU_SYS WITH BAR()
  ACTIVATE POPUP W_SYS_MOD
  RELEASE POPUP W_SYS_MOD
RETURN

PROCEDURE PU_SYS
  PARAMETER M_BAR

  DO CASE
    CASE M_BAR=1
      DO CDX_GEN
    CASE M_BAR=2
      DO PACK_FIL
    CASE M_BAR=3
      DO REC_COUNT
    CASE M_BAR=4
      DO CHK_INT
  ENDCASE
RETURN

procedure CHK_INT
  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_CHKINT FROM 11,20 SHADOW
  DEFINE BAR 1 OF W_CHKINT PROMPT 'CHECK AUX_MAS.DBF'
  DEFINE BAR 2 OF W_CHKINT PROMPT 'PURGE CLIENT.DBF'
  DEFINE BAR 3 OF W_CHKINT PROMPT 'RECORD COMPANY.DBF'
  ON SELECTION POPUP W_CHKINT DO P_CHKINT WITH BAR()
  ACTIVATE POPUP W_CHKINT
  RELEASE POPUP W_CHKINT
return

procedure P_CHKINT
  parameters M_BAR
  do case
    case M_BAR=1
      DO CHKAUX
    case M_BAR=2
      DO CHKCLI
    case M_BAR=3
      DO CHKCOM
  endcase
return

*------------------------*
*  Index File Generator  *
*------------------------*
*  SYSTEM.
PROCEDURE CDX_GEN

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_PU_INDEX FROM 10,35 SHADOW
  DEFINE BAR 1 OF W_PU_INDEX PROMPT 'CLIENT'
  DEFINE BAR 2 OF W_PU_INDEX PROMPT 'COMPANY'
  DEFINE BAR 3 OF W_PU_INDEX PROMPT 'CATEGORY'
  DEFINE BAR 4 OF W_PU_INDEX PROMPT 'AUXILIARY'
  DEFINE BAR 5 OF W_PU_INDEX PROMPT 'ACTIVITY LOG'
  ON SELECTION POPUP W_PU_INDEX DO CDX_GEN2 WITH BAR()

  DO WHILE LASTKEY()#K_ESC
    ACTIVATE POPUP W_PU_INDEX
  ENDDO

  RELEASE POPUP W_PU_INDEX
RETURN

*------------------------------*
*  Index File Generator --> 2  *
*------------------------------*
*  SYSTEM.
PROCEDURE CDX_GEN2
  PARAMETER M_BAR

  DEFINE WINDOW W_INDEX FROM 15,20 TO 21,60 SHADOW
  ACTIVATE WINDOW W_INDEX

  DO CASE
    CASE M_BAR=1
      SELECT 0
      USE &ML_PATH.CLIENT EXCLUSIVE ALIAS CLIENT
      IF USED('CLIENT')
        ? 'INDEXING CLIENT.DBF ...'
        set talk on
        INDEX ON MAS_CODE      tag MAS_CODE
        INDEX ON L_NAME+F_NAME tag NAME
        INDEX ON COM_CODE      tag COM_CODE
        set talk off
      ELSE
        ? 'CLIENT.DBF in use!'
      ENDIF
      USE

    CASE M_BAR=2
      SELECT 0
      USE &ML_PATH.COMPANY EXCLUSIVE ALIAS COMPANY
      IF USED('COMPANY')
        ? 'INDEXING COMPANY.DBF ...'
        set talk on
        INDEX ON COM_CODE tag COM_CODE
        INDEX ON COM_NAME tag COM_NAME
        set talk off
      ELSE
        ? 'COMPANY.DBF in use!'
      ENDIF
      USE

    CASE M_BAR=3
      SELECT 0
      USE &ML_PATH.CATEG EXCLUSIVE ALIAS CATEG
      IF USED('CATEG')
        ? 'INDEXING CATEG.DBF ...'
        set talk on
        INDEX ON CAT_CODE tag CAT_CODE
        INDEX ON CAT_TYPE tag CAT_TYPE
        set talk off
      ELSE
        ? 'CATEG.DBF in use!'
      ENDIF
      USE

    CASE M_BAR=4
      SELECT 0
      USE &ML_PATH.AUX_MAS EXCLUSIVE ALIAS AUX_MAS
      IF USED('AUX_MAS')
        ? 'INDEXING AUX_MAS.DBF ...'
        set talk on
        INDEX ON AUX_CODE tag AUX_CODE
        INDEX ON MAS_CODE tag MAS_CODE
        INDEX ON COM_CODE tag COM_CODE
        INDEX ON COM_CODE+AUX_CODE tag COM_AUX
        INDEX ON AUX_TYPE tag AUX_TYPE
        set talk off
      ELSE
        ? 'AUX_MAS.DBF in use!'
      ENDIF
      USE
    CASE M_BAR=5
      SELECT 0
      USE &ML_PATH.ML_LOG EXCLUSIVE ALIAS ACTLOG
      IF USED('ACTLOG')
        ? 'INDEXING ML_LOG.DBF ...'
        set talk on
        INDEX ON DATE tag DATE
        set talk off
      ELSE
        ? 'ML_LOG.DBF in use!'
      ENDIF
      USE
  ENDCASE

  RELEASE WINDOW W_INDEX
RETURN

*-----------------------*
*  File Packing Routine *
*-----------------------*
* PURGE DELETED RECORDS PHYSICALLY
*  Remember to print a deleted report  *
PROCEDURE PACK_FIL

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_PU_PACK FROM 09,35 SHADOW
  DEFINE BAR 1 OF W_PU_PACK PROMPT 'CLIENT'
  DEFINE BAR 2 OF W_PU_PACK PROMPT 'COMPANY'
  DEFINE BAR 3 OF W_PU_PACK PROMPT 'CATEGORY'
  DEFINE BAR 4 OF W_PU_PACK PROMPT 'AUXILIARY'
  DEFINE BAR 5 OF W_PU_PACK PROMPT 'ACTIVITY LOG'
  ON SELECTION POPUP W_PU_PACK DO PACK_FIL2 WITH BAR()

  DO WHILE LASTKEY()#K_ESC
    ACTIVATE POPUP W_PU_PACK
  ENDDO

  RELEASE POPUP W_PU_PACK
RETURN


*------------------------------*
*  File Packing Routine --> 2  *
*------------------------------*
*  SYSTEM.
* PURGE RECORDS MARKED DELTEED.
PROCEDURE PACK_FIL2
  PARAMETERS M_BAR
  DEFINE WINDOW W_PACK FROM 15,20 TO 20,60
  **  Indexing routine  **
  DO CASE
    CASE M_BAR=1
      SELECT 0
      USE &ML_PATH.CLIENT EXCLUSIVE ALIAS CLIENT
      IF USED('CLIENT')
        IF FPACK('CL')
          ACTIVATE WINDOW W_PACK
          ? 'PACKING CLIENT.DBF ...'
          set talk on
          PACK
          set talk off
        ENDIF
      ELSE
        ? 'CLIENT.DBF in use!'
      ENDIF
      USE
    CASE M_BAR=2
      USE &ML_PATH.COMPANY EXCLUSIVE ALIAS COMPANY
      IF USED('COMPANY')
        IF FPACK('CO')
          ACTIVATE WINDOW W_PACK
          ? 'PACKING COMPANY.DBF ...'
          set talk on
          PACK
          set talk off
        ENDIF
      ELSE
        ? 'COMPANY.DBF in use!'
      ENDIF
      USE
    CASE M_BAR=3
      USE &ML_PATH.CATEG EXCLUSIVE ALIAS CATEG
      IF USED('CATEG')
        IF FPACK('CA')
          ACTIVATE WINDOW W_PACK
          ? 'PACKING CATEG.DBF ...'
          set talk on
          PACK
          set talk off
        ENDIF
      ELSE
        ? 'CATEG.DBF in use!'
      ENDIF
      USE
    CASE M_BAR=4
      USE &ML_PATH.AUX_MAS EXCLUSIVE ALIAS AUX_MAS
      IF USED('AUX_MAS')
        IF FPACK('AU')
          ACTIVATE WINDOW W_PACK
          ? 'PACKING AUX_MAS.DBF ...'
          set talk on
          PACK
          set talk off
        ENDIF
      ELSE
        ? 'AUX_MAS.DBF in use!'
      ENDIF
      USE
    CASE M_BAR=5
      USE &ML_PATH.ML_LOG EXCLUSIVE ALIAS ACTLOG
      IF USED('ACTLOG')
        IF FPACK('LG')
          ACTIVATE WINDOW W_PACK
          ? 'PACKING ML_LOG.DBF ...'
          set talk on
          PACK
          set talk off
        ENDIF
      ELSE
        ? 'ML_LOG.DBF in use!'
      ENDIF
      USE
  ENDCASE

  wait 'PRESS ANY KEY TO CONTINUE' window
  RELEASE WINDOW W_PACK
RETURN

procedure REC_COUNT
  private M_COUNT, M_TEMP, M_ERR
  M_COUNT = 0
  M_TEMP  = ' ... '
  M_ERR   = 'IN USE'

  define window W_COUNT from 10,20 to 17,60 panel title 'COUNTING RECORDS ...'
  activate window W_COUNT

  select 0
  use &ML_PATH.COMPANY alias COMPANY
  ? 'COMPANY MASTER' + M_TEMP
  if used('COMPANY')
    set talk on
    count to M_COUNT
    set talk off
    use in COMPANY
  else
    ?? M_ERR
  endif

  use &ML_PATH.CLIENT alias CLIENT
  ? 'CLIENT MASTER' + M_TEMP
  if used('CLIENT')
    set talk on
    count to M_COUNT
    set talk off
    use in CLIENT
  else
    ?? M_ERR
  endif

  use &ML_PATH.CATEG alias CATEG
  ? 'CATEGORIES' + M_TEMP
  if used('CATEG')
    set talk on
    count to M_COUNT
    set talk off
    use in CATEG
  else
    ?? M_ERR
  endif
  wait 'PRESS A KEY TO CONTINUE' window

  release window W_COUNT
return

procedure CHKCOM
   *
   * Written by Chang Man Wai
   * Used to check if country code in each company record exists
   *
   PRIVATE M_ERROR

   M_ERROR=0

   define window W_CHECK from 08,25 to 15,65 shadow title 'CHECK COUNTRY CODES IN COMPANY RECORDS ...'
   activate window W_CHECK

   set exclusive on

   SELECT 0
   USE &ML_PATH.CATEG ALIAS CATEG
   if used('CATEG')
     set order to tag CAT_CODE

     SELECT 0
     USE &ML_PATH.COMPANY ALIAS COMPANY
     if used('COMPANY')
       set order to

       set talk off
       *- ERRORS
       SET ALTERNATE TO COMERR
       SET ALTERNATE ON
       SET CONSOLE OFF

       select COMPANY
       scan
         select CATEG
         seek COMPANY.COU_CODE
         if .not. found()
           M_ERROR=M_ERROR+1
           select COMPANY
           disp
           replace COU_CODE with space(1)
         endif

         select COMPANY
         if mod(recno(),500)=0
           set alternate off
           set console on
           ? recno()
           ?? '/'
           ?? reccount()
           ?? ' records so far'
           set console off
           set alternate on
         endif
       endscan

       ? 'Total errors = '
       ?? M_ERROR

       SET ALTERNATE OFF
       SET ALTERNATE TO
       SET CONSOLE ON
     endif
   endif

   release window W_CHECK
   set exclusive off
   close databases
RETURN

procedure CHKCLI
   *
   * Written by Chang Man Wai
   * check if the company code stored in client records exists
   *
   private M_ERROR

   define window W_CHECK from 08,25 to 15,65 shadow title 'CHECK CLIENT CODES IN COMPANY RECORDS ...'
   activate window W_CHECK

   set exclusive on

   SELECT 0
   USE &ML_PATH.CLIENT ALIAS CLIENT
   if used('CLIENT')
     set order to
     SELECT 0
     USE &ML_PATH.COMPANY ALIAS COMPANY
     if used('COMPANY')
       set order to tag COM_CODE
       *- ERRORS
       set talk off
       SET ALTERNATE TO CLIERR
       SET ALTERNATE ON
       SET CONSOLE OFF

       M_ERROR=0
       select CLIENT
       scan
         select COMPANY
         seek CLIENT.COM_CODE
         if .not. found()
           replace CLIENT.COM_CODE with space(1)
           M_ERROR=M_ERROR+1
           select CLIENT
           disp
         endif

         * report progress of checking ...
         if mod(recno(),250)=0
           set alternate off
           set console on
           select CLIENT
           ? recno()
           ?? '/'
           ?? reccount()
           ?? ' records so far'
           set console off
           set alternate on
         endif
       endscan

       ? 'Total errors = '
       ?? M_ERROR

       SET ALTERNATE OFF
       SET ALTERNATE TO
       SET CONSOLE ON
     endif
   endif

   release window W_CHECK
   set exclusive off
   close databases
RETURN

procedure CHKAUX
   *
   * Written by Chang Man Wai
   * Used to check AUX_MAS.DBF
   *
   PRIVATE M_ERROR, M_COUNT, M_DEL

   define window W_CHECK from 08,25 to 15,65 shadow title "CHECK AUX_MAS.DBF ..."
   activate window W_CHECK

   M_ERROR=0
   M_DEL=0

   set exclusive on

   SELECT 0
   USE &ML_PATH.CLIENT ALIAS CLIENT
   if used('CLIENT')
     set order to tag MAS_CODE

     SELECT 0
     USE &ML_PATH.COMPANY ALIAS COMPANY
     if used('COMPANY')
       set order to tag COM_CODE

       SELECT 0
       USE &ML_PATH.CATEG ALIAS CATEG
       if used('CATEG')
         set order to tag CAT_CODE

         SELECT 0
         USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
         if used('AUX_MAS') 

           set talk off
           *- ERRORS
           SET ALTERNATE TO AUXERR
           SET ALTERNATE ON
           SET CONSOLE OFF

           *- check to see if the keys in AUX_MAS are existing ones
           select AUX_MAS
           SCAN
             M_COUNT=0
             IF AUX_MAS.MAS_CODE > 0
                * check country code
               SELECT COMPANY
               seek CLIENT.COM_CODE
               if found()
                 select AUX_MAS
                 replace COU_CODE with COMPANY.COU_CODE
               endif

               * check client code
               SELECT CLIENT
               seek AUX_MAS.MAS_CODE
               IF .NOT. FOUND()
                 SELECT AUX_MAS
                 ? 'Unknown client code'
                 DISP
                 M_ERROR=M_ERROR+1
                 M_COUNT=M_COUNT+1
                 delete
               ENDIF
             ENDIF

             IF .NOT. EMPTY(AUX_MAS.COM_CODE) and M_COUNT=0
               SELECT COMPANY
               seek AUX_MAS.COM_CODE
               IF .NOT. FOUND()
                 ? 'Unknown Company Code'
                 SELECT AUX_MAS
                 DISP
                 M_ERROR=M_ERROR+1
                 M_COUNT=M_COUNT+1
                 delete
               ELSE
                 * update company code
                 select AUX_MAS
                 replace COU_CODE with COMPANY.COU_CODE
               ENDIF
             ENDIF

             IF .NOT. EMPTY(AUX_MAS.COU_CODE) and M_COUNT=0
               SELECT CATEG
               seek AUX_MAS.COU_CODE
               IF .NOT. FOUND()
                 ? 'Unknown Country code'
                 SELECT AUX_MAS
                 DISP
                 M_ERROR=M_ERROR+1
                 M_COUNT=M_COUNT+1
                 delete
               ENDIF
             ENDIF

             IF .NOT. EMPTY(AUX_MAS.AUX_CODE) and M_COUNT=0
               SELECT CATEG
               seek AUX_MAS.AUX_CODE
               IF .NOT. FOUND()
                 ? 'unknown category code'
                 SELECT AUX_MAS
                 DISP
                 M_ERROR=M_ERROR+1
                 M_COUNT=M_COUNT+1
                 delete
               ENDIF
             ENDIF

             * show progress
             select AUX_MAS
             if mod(recno(),250)=0
               set alternate off
               set console on
               ? str(recno(),6,0)+'/'+str(reccount(),6,0)+' records.'
               set console off
               set alternate on
             endif
           ENDSCAN

           ? 'Total errors = '
           ?? M_ERROR

           SET ALTERNATE OFF
           SET ALTERNATE TO
           SET CONSOLE ON
         endif
       endif
     endif
   endif

   ? 'Total errors = '
   ?? M_ERROR

   release window W_CHECK
   set exclusive off
   close databases
RETURN

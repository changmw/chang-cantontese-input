* FUNCTION PACK_FIL3
*
* copy records that are marked DELETED to a DBF whose name is of the
* following format:
* __[2-digit month code][2-digit day][2-char code]
*
* Caller must open a window for message printing and USE/SELECT the appropriate
* database in the current workarea
*
* Input parameters: two-character code FIL_NAME
* Return value:     whehter there is any DELETED records in the DBF
*
  PARAMETER FIL_NAM
  PRIVATE M_COUNT, TMP1, M_RC, O_DELETED
  define window W_FPACK from 00,00 to 02,50 shadow ;
         color g/n,,g+/n,g+/n title 'FPACK'
  activate window W_FPACK

  O_DELETED=set('DELETED')
  ? 'COUTING RECORDS ...'
  SET DELETED OFF
  COUNT TO M_COUNT FOR DELETED()
  ? M_COUNT
  ?? ' RECORDS MARKED FOR DELETION'
  =INKEY(1)

  IF M_COUNT > 0
    ? 'RELOCATING RECORDS ...'
    TMP1 = '__'+ ;
           PADL(ALLTRIM(STR(MONTH(SYSDATE),2,0)),2,'0') + ;
           PADL(ALLTRIM(STR(DAY(SYSDATE),2,0)),2,'0') + ;
           FIL_NAM

    * backup deleted records to a database
    COPY TO &ML_PATH.&TMP1. FOR DELETED()
  ENDIF

  SET DELETED &O_DELETED.
  release window W_FPACK
RETURN (M_COUNT > 0)

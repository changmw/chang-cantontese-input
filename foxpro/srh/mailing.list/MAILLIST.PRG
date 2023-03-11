*---------------------------------------------------------------------------*
* Filename   :  M_UTIL.prg
*
* Description:  Library routine for mailing list program
*
* Author     :  Kai wing Fung, Chicken
* REvision   :  Chang Man Wai
*
* Init. Date :  26-Apr-1990
*
* Prog. Lang.:  FoxPro Version 1.0 (Multi-user)
*
* Modification History :-
*
* Date              Modification Detail           Remark
* ----              -------------------           ------
* 26-Apr-1990       Init. coding
*
* 20-Mar-1991       Add SET EXCLUSIVE ON in      Gladys reported
*                   ML_SETUP by Chang Man Wai   file sharing error
*                                                during
*                                                label printing
*
* JUNE, 1991        REVISED BY CHANG MAN WAI     NEW REQUIREMENTS.
*                                                CONVERT TO MULTI-USER.
*                                                FIX BUGS AND REPLACE ODD
*                                                CODING WITH FOXPRO/LAN
*                                                FEATURES. DATABASE STRUCTURES
*                                                NOT MODIFIED.
*
* OCT 29, 1991      Ported to FoxPro 2.0         Use .CDX, BROWSE FOR to
*                                                improve performance
*                   Problem encountered in REPORT FORM command - Fox bug
*
* NOV  5, 1991      Revised login process. LOGIN() and SETPASS() are now
*                   the functions provided by the SRHIS Access Control System
*
* NOV 12, 1991      Spelling mistake in system title
*
* NOV 14, 1991      Remove display of CATEG->CAT_CODE from labels
*                   Add record counting functions
*                   Add sub-headings to filter reports showing filter
*                   For full dump of company information, split
*
*---------------------------------------------------------------------------*
*
* +=========================================================================+
* + Define Menu Routine for the whole mailing list system                   +
* +=========================================================================+
  CLEAR ALL
  SET PATH TO F:\SRHIS\MAILLIST;F:\SRHIS\MAILLIST\REPORTS
  set procedure to SRHLIB

  ON ERROR DO ERRPROC WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO()
  * to search FXPs
  * report and label formats must be opened in R/W mode in Fox 2.0 (sh?t!)
  *
  DO ML_SETUP
  do KEYCODE

  * PATH TO PROGRAM, DATABASE AND TEMPORARY FILES
  *
  *  WARNING: IF YOU ARE TRYING TO MODIFY THE PROGRAM, PLEASE
  *           CHANGE ML_PATH OR YOU WILL DAMAGE LIVE DATA
  *
  do APP_PATH

  * system variables
  PUBLIC U_NAME, U_LEVEL
  PUBLIC SYSNAME, SYSDATE, PROGBY
  PUBLIC A_NORMAL
  private W_HEAD, W_WALL

  SYSNAME    = 'SRHIS-ML: MAILING LIST SYSTEM'
  SYSVERSION = 'VERSION 3.68'
  PROGBY     = 'WAI'
  SYSDATE    = DATE()
  A_NORMAL   = 'W/N,W/N'

  _rmargin = 255

  *****************************************************
  **  MAIN ROUTINE OF THE WHOLE APPLICATION PROGRAM  **
  *****************************************************

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_MAIN FROM 06,05 SHADOW
  DEFINE BAR 1 OF W_MAIN PROMPT 'FILE MAINTENANCE'
  DEFINE BAR 2 OF W_MAIN PROMPT 'FULL REPORTS'
  DEFINE BAR 3 OF W_MAIN PROMPT 'CLIENT REPORT/LABEL/DBF'
  DEFINE BAR 4 OF W_MAIN PROMPT 'CHANGE MY PASSWORD'
  DEFINE BAR 5 OF W_MAIN PROMPT 'SYSTEM MAINTENANCE'
  ON SELECTION POPUP W_MAIN DO PU_MAIN WITH BAR()

  do HOOKF10
  =SRHWALL()
*  do while LOGIN(SYSNAME, SYSVERSION, PROGBY, 'MAILLIST', U_NAME, U_LEVEL)
    W_HEAD=SHOWHEAD('MAIN MENU')
    ACTIVATE POPUP W_MAIN
    release window (W_HEAD)
*  ENDDO
  ON KEY LABEL F10

  ON ERROR
  CLEAR ALL
  set color to W/N
  set procedure to
  CLEAR
  DO OLD_SET
RETURN

PROCEDURE PU_MAIN
  PARAMETERS M_BAR
  DO CASE
    CASE M_BAR = 1
      DO DATA_MAIN
    CASE M_BAR = 2
      IF U_LEVEL=0
        DO ML_RPT
      ELSE
        =ERRMSG("YOU ARE NOT AUTHORIZED TO PRINT FULL REPORTS!")
      ENDIF
    CASE M_BAR = 3
      DO ML_LABEL
    CASE M_BAR = 4
      =SETPASS('MAILLIST',U_NAME)
    CASE M_BAR = 5
      IF U_LEVEL = 0
        DO ML_MAINT
      ENDIF
  ENDCASE
RETURN

*------------------------------------*
*  Database Maintenance Pop-up Menu  *
*------------------------------------*
*  SYSTEM.
PROCEDURE DATA_MAIN

  SET COLOR TO N/W,W+/N
  DEFINE POPUP  W_DATA_POP FROM 07,15 SHADOW
  DEFINE BAR 1  OF W_DATA_POP PROMPT 'CLIENT'
  DEFINE BAR 2  OF W_DATA_POP PROMPT 'COMPANY'
  DEFINE BAR 3  OF W_DATA_POP PROMPT 'ACTIVITY LOG'
  DEFINE BAR 4  OF W_DATA_POP PROMPT replicate('Ä',25)
  DEFINE BAR 5  OF W_DATA_POP PROMPT 'BUSINESS NATURE'
  DEFINE BAR 6  OF W_DATA_POP PROMPT 'DIRECTOR'
  DEFINE BAR 7  OF W_DATA_POP PROMPT 'PUBLICATION'
  DEFINE BAR 8  OF W_DATA_POP PROMPT 'COUNTRY CODE'
  DEFINE BAR 9  OF W_DATA_POP PROMPT 'POSITION'
  DEFINE BAR 10 OF W_DATA_POP PROMPT 'CIRCULATIONS'
  DEFINE BAR 11 OF W_DATA_POP PROMPT 'KEY CLIENTS'
  DEFINE BAR 12 OF W_DATA_POP PROMPT 'SRG NEWS'
  ON SELECTION POPUP W_DATA_POP DO PU_DATA WITH BAR()

  ACTIVATE POPUP W_DATA_POP

  RELEASE POPUP W_DATA_POP
RETURN

PROCEDURE PU_DATA
  PARAMETER M_BAR

  DO CASE
    CASE M_BAR = 1
      DO CLI_MAIN IN ML_CLI
    CASE M_BAR = 2
      DO ML_COM
    CASE M_BAR = 3
      DO ML_LOG
    CASE M_BAR = 5
      =ML_ATTR("B")
    CASE M_BAR = 6
      =ML_ATTR("D")
    CASE M_BAR = 7
      =ML_ATTR("P")
    CASE M_BAR = 8
      =ML_ATTR("C")
    CASE M_BAR = 9
      =ML_ATTR("O")
    CASE M_BAR = 10
      =ML_ATTR("T")
    CASE M_BAR = 11
      =ML_ATTR("1")
    CASE M_BAR = 12
      =ML_ATTR("2")
  ENDCASE
RETURN

* +==========================================================================+
* +  Library Routine for the whole mailing list system                       +
* +==========================================================================+
*----------------------------*
*  System Environment Setup  *
*----------------------------*
*  M_UTIL.1
PROCEDURE ML_SETUP
  **  Setting Control  **
  SET DELIMITER TO '[]'
  SET DELIMITER ON
  SET INTENSITY OFF

  SET ESCAPE OFF
  SET AUTOSAVE ON
  SET BELL OFF
  SET CENTURY ON

  SET SAFETY OFF
  SET EXACT ON
  SET DELETED ON
  SET UNIQUE OFF

  SET EXCLUSIVE OFF
  SET REPROCESS TO 30
  SET MULTILOCKS ON

  SET HEADING OFF
  SET CLOCK OFF
  SET STATUS OFF
  SET TALK OFF
  SET SHADOW ON
  SET RESOURCE OFF
  SET SYSMENU OFF
  SET FULLPATH OFF

  SET UDFPARM TO REFERENCE
  SET OPTIMIZE ON
  SET HELP OFF
  SET ODOMETER TO 1000
RETURN

PROCEDURE OLD_SET
  **  Setting Control  **
  SET DELIMITER OFF
  SET INTENSITY ON
  SET DEVELOPMENT ON
  SET LOGERRORS ON

  SET AUTOSAVE OFF
  SET BELL ON
  SET CENTURY OFF

  SET SAFETY ON
  SET EXACT OFF
  SET DELETED OFF
  SET UNIQUE OFF

  SET EXCLUSIVE ON
  SET REPROCESS TO 0
  SET MULTILOCKS OFF

  SET HEADING ON
  SET STATUS OFF
  SET TALK ON
  SET SHADOW ON
  SET RESOURCE OFF
  SET UDFPARM TO VALUE

  SET SYSMENU ON
  SET ESCAPE ON
  SET HELP ON
RETURN

procedure HOOKF10
  ON KEY LABEL F10 KEYBOARD CHR(K_C_W)
return

FUNCTION V_ATTR
  PARAMETERS M_SELECT
  PRIVATE M_RC

  M_RC=.T.
  DO CASE
    CASE CATEG.FLAG=' '
    CASE CATEG.FLAG='*'
    CASE CATEG.FLAG='-'
    CASE CATEG.FLAG='+'
    OTHERWISE
      DO ERRMSG WITH 'USE +/- TO ADD/DELETE ATTRIBUTES'
      REPLACE FLAG WITH ' '
      M_RC=0
  ENDCASE
RETURN M_RC

function V_FNAME
  * check if the file name has invalid characters
  parameter M_P
  private M_I, M_K, M_P

  for M_I= 1 to len(rtrim(M_P))
    M_K=right(left(M_P, M_I), 1)        && equivalent to SUBSTR
    do case
      case M_K$'_-'
      case isalpha(M_K)
      case M_K=space(1)
        do ERRMSG with 'NO BLANK ALLOWED IN FILE NAME'
        return 0
      otherwise
        do ERRMSG with 'NAME CONTAINS INVALID CHARACTERS'
        return 0
    endcase
  endfor
return .t.

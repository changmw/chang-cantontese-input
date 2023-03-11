*
* function PUSH_SET
*
* Description:    Allows you to set any ON/OFF SET command, and
*                 save the previous setting. When you want to restore
*                 the previous setting. Just use POP_SET.
*                 (adapted from Hands-on FoxPro, Databased Advisor)
* Parameters:     OBJECT: This is anything that can be used inside a
*                         ? SET(object) command, i.e. SET("CLOCK"),
*                         SET("BELL") etc.
*                 STATUS: New setting you want , i.e. ON or OFF
* Returns:        True if called correctly.
*                 False if an error has occurred.
* Example:        PUSH_SET("CLOCK", "OFF")
*
PARAMETERS object, status
PRIVATE object, status
*
status = ALLTRIM(UPPER(status))
IF status # "ON" AND status # "OFF"
  RETURN .F.
ENDIF
IF EMPTY(SET(object))
  RETURN .F.
ENDIF
IF TYPE("SET_LIST") = "U"
  PUBLIC set_list
  set_list = ""
ENDIF
set_list = set_list + object + "=" + 1 + ;
           IIF(SET(object)="ON", "ON ", "OFF") + ","
SET &object. &status.
RETURN .T.

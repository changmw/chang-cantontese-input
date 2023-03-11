*
* function POP_SET
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
PARAMETERS object
PRIVATE object, this_setting
object_loc = RAT(object, set_list)
IF object_loc = 0
  RETURN .F.
ENDIF
object_len = AT("=", SUBSTR(set_list, object_loc))
object_set = SUBSTR(set_list, object_loc + object_len, 3)
SET &object. &object_set.
IF object_len + object_len + 4 = LEN(set_list)
  set_list = SUBSTR(set_list, 1, object_loc-1)
ELSE
  set_list = SUBSTR(set_list, 1, object_loc-1) + ;
             SUBSTR(set_list, object_loc+object_len+4)
ENDIF
RETURN .T.

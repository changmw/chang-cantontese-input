* procedure ERRPROC
*
* general program error trap for SRH information systems
* Parameters: P_ERRNO  FoxPro internal error number
*       P_MSG1  FoxPro Error message line 1
*       P_MSG2  FoxPro Error message line 2
*       P_PROG  Offending program
*       P_LINENO Line number of the offending instruction
*
parameter P_ERRNO, P_MSG1, P_MSG2, P_PROG, P_LINENO
  do case
*   case P_ERRNO=20     && record is not in index (file locked)
    case P_ERRNO=26     && database in not ordered
      set fullpath off
      wait "Please ask supervisor to re-indexe "+dbf() window
      set fullpath on
    case P_ERRNO=42     && CONINUE without LOCATE
    case P_ERRNO=109    && Record exclusively used by another
    case P_ERRNO=114    && index damaged
    case P_ERRNO=130    && Record exclusively used by another
    case P_ERRNO=108    && File exclusively use by another
    case P_ERRNO=1707   && Structural index not found
    case P_ERRNO=125    && Printer Not Ready
      wait 'Check Printer Connection' window
    otherwise
      set device to screen
      define window W_ALERT from 15,00 to 24,79 ;
            shadow title " SYSTEM ERROR " ;
            color w+/r,w+/r,w+/r,w+/r,w+/r

      activate window W_ALERT
      @ 00,     05 say "ERROR NUMBER: "+str(P_ERRNO,4,0)
      @ row()+1,05 say "PROGRAM:      "+P_PROG
      @ row()+1,05 say "LINE NUMBER:  "+str(P_LINENO,5,0)
      @ row()+2,05 say "PLEASE INFORM SYSTEM TEAM."
      @ row()+2,(wcols()-len(P_MSG1))/2 say P_MSG1
      @ row()+1,(wcols()-len(P_MSG2))/2 say P_MSG2
      wait 'CALL SYSTEM TEAM' window
      release window W_ALERT

      on error
      pop menu _MSYSMENU
      clear read all
      release workarea,exact,safety
      on key label enter
      on key label del
      on key label ins
      set proc to
      cancel
  endcase
return

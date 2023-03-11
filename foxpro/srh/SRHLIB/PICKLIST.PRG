**************************************
* Demonstrate use of pick list function
*         requires sictable.dbf
*************************************
CLEAR
SET TALK OFF
SET ECHO OFF
USE sictable 

siclist=''                      && Character variable to put sic list in
stalias="sictable"              && Alias name of sic database file

SET UDFPARM TO reference
forstring=picksic(siclist,stalias) && display sic code picklist
SET UDFPARM TO value

IF ''<> forstring         && If for string not blank show results
  ? siclist               && show siclist variable
  WAIT
  CLEAR
  set step on
  select *  ;
     from sictable ;
     where &forstring ;
     into cursor query
   browse  
 * LIST FOR &forstring     && Show use of FOR string
ENDIF

RETURN

*****************
FUNCTION picksic            && Point & shoot picklist for sic codes
PARAMETER siclist,stalias
PRIVATE brstat,fltstrng,selsic,colsch1,colsch2,selsic
*******************************************************
*
* Purpose: Allow user to pick individual sic codes. Picks are
*          returned in a formatted character variable and
*          FOR expression to use it.
*
* Input
*
*     Parameters
*      stalias - alias name of sic table dbf indexed in sic number
*                order. Must contain fields: SIC character 4
*                which contains sic number and field named
*                descrip character 65 with description of sic
*
*      siclist - character memory variable, passed by reference
*                because it can get quite large depending on
*                how many selections are stored.
*                Picksic will intialize it into formatted cells
*                each cell having the following character string
*                in it |0000 .
*
* Output
*
*      Returns string that can be used in FOR clauses
*      or as a filter string with the siclist variable:
*             sic $ siclist .AND. SIC <> "0000"
*      If the string contains null then no sics were picked.
*
*      Formats character variable siclist and puts
*      sic numbers that were picked into it.
****************************************************************

PRIVATE brstat,fltstrng,selsic,colsch1,colsch2,selsic

SELECT (stalias) && sic code table with sic number index

* Save environment
colsch1  = SCHEME(1)
colsch10 = SCHEME(10)

* Intitalize variables etc.
selsic=0                    && total selected sic codes
siclist=REPL("|0000",100)   && format hold selected sic codes memvar

SET COLOR OF SCHEME 10 TO B/W,+GR/BR,B/BG, ;
    +W/BG,B/BR,+W/BR,+GR/BR
SET COLOR OF SCHEME 1 TO B/W,+GR/BR,B/BG,+W/BG, ;
    B/BR,+W/BR,+GR/BR

* Message telling user how to use pick list
@ 24,07 SAY "Press Space Bar to Select/Unselect, "+;
    "F2 to Exit, ESC to Return "


* Browse setup
ON KEY LABEL f2 KEYBOARD CHR(23)
ON KEY LABEL spacebar DO sicinout WITH siclist,selsic,sic
DEFINE WINDOW pbrowse FROM 5,5 TO 19,75 NONE SHADOW
brstat=SET("BRSTATUS")
SET brstatus OFF

BROWSE FIELDS check=IIF(AT(sic,siclist) <> 0,CHR(251),' ') :1, ;
     sic, descrip :60 ;
     TITLE "SIC Pick List" ;
     WINDOW pbrowse ;
     NOAPPEND NOMODIFY NODELETE

* Reset Browse environment immediately after Browse ends
SET brstatus &brstat
RELEASE WINDOW pbrowse
ON KEY LABEL spacebar
ON KEY LABEL f2
ON KEY LABEL esc

* Create return value
IF  selsic =  0 .OR. LASTKEY() = 27   && If sics selected and no esc key
   fltstrng=''
ELSE
   fltstrng= [sic $ siclist .AND. SIC <> "0000"]
ENDIF

* Return environment to conditions when called
SET COLOR OF SCHEME 10 TO &colsch10
SET COLOR OF SCHEME 1 TO &colsch1
@ 24,0

RETURN fltstrng

***********************
PROCEDURE sicinout      && put/remove a sic from siclist memvar
PARAMETER siclist,selsic,sic

******************************************************
*
*  Purpose: For use with the picksic function as an
*    ON KEY LABEL spacebar procedure. Adds of deletes
*    sic number form siclist formatted variable and keeps
*    count of number of sics selected.
*
*
* Input
*
*    Record pointer is on sic record being picked/unpicked,SIC
*      refers to
*
*    Parmeters
*      siclist - character memory variable, passed by reference
*                because it can get quite large depending on
*                how many selections are stored.
*
*      selsic  - Keeps count of number of sics actually picked.
*                Passed by reference
*
*
*
* Output
*                Adds or deletes SIC numbers from formatted variable
*                siclist.
*
*                Counts number of picks made in selsic which is
*                passed by reference
****************************************************************

IF AT("|"+sic,siclist) <> 0   && If sic is in there take it out
    siclist=STUFF(siclist,AT("|"+sic,siclist)+1,4,"0000")
    selsic=selsic-1           && Decrement sic selected count
ELSE                          && If sic not in there put it in
    siclist=STUFF(siclist,AT("|"+"0000",siclist)+1,4,sic)
    selsic=selsic+1           && Increment sic selected count
ENDIF
KEYBOARD CHR(09)+CHR(19)      && Forces Browse update with checkmark
                              && tab + left arrow
RETURN

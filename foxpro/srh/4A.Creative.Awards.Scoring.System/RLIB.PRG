* Function: BOXASK
* Author..: Richard Low
* Syntax..: BOXASK( <expC> [,<expC>...] )
* Returns.: Character pressed in response to a message displayed on screen
*           after displaying each parameter (up to maximum of 9) on a
*           separate line centered in a single line box.
* Notes...: If the first parameter is a color setting, BOXASK will use
*           that color combination instead of the default White on Red.
*

FUNCTION BOXASK

parameters p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12

local f_pcount, f_color, f_lines, f_indexp, f_brows, f_bcols, f_toprow,;
      f_botrow, f_widest, f_x, f_pname, f_leftcol, f_ritecol, f_window,;
      f_incolor, f_key, f_saverow, f_savecol, f_seconds

f_pcount  = PCOUNT()                                            && get param count, multiple calls to PCOUNT() do not work!
f_pname   = 'p' + LTRIM(STR(f_pcount,2,0))
f_seconds = 0                                                   && default is wait forever for keypress
IF TYPE(f_pname) = 'N'                                          && if last parameter is numeric
   f_seconds = &f_pname                                         && it is number of seconds to pause
   f_pcount  = f_pcount - 1                                     && decrement parameter count
ENDIF
f_color   = SETCOLOR()                                          && default color is current color
f_lines   = f_pcount                                            && 'parameter to display' count; assume each param is a line to display
f_indexp  = 1                                                   && pointer to show which parm line to print
f_saverow = ROW()                                               && save cursor position for restoration
f_savecol = COL()                                               &&  on return
IF STR(AT('/',p1),1,0) $ '234'                                  && if 1st parm is a color setting, a '/' will be at position 2,3, or 4
   f_color  = p1                                                && use 1st parameter as color setting
   f_indexp = 2                                                 && change parm pointer to next one
   f_lines  = f_pcount - 1                                      && adjust 'parameter to display' count
ENDIF
f_brows  = 1                                                    && number of blank rows above and below message
f_bcols  = 5                                                    && blank columns on either side of messages
f_toprow = (10 + f_brows) - ROUND(f_lines / 2, 0)               && put in middle of screen with 2 lines above and below
f_botrow = f_toprow + (2 * f_brows) + f_lines + 1               && calculate bottom row of window
f_widest = 10                                                   && widest window width default is 10 columns
FOR f_x = f_indexp TO f_pcount                                  && get widest width for window
   f_pname  = 'p' + LTRIM(STR(f_x,2,0))
   f_widest = MAX( f_widest, LEN(&f_pname) )
NEXT f_x
f_widest  = MIN( f_widest + (2 * f_bcols), 77 )                 && pad with (bcol) spaces on both sides, max width is 77 columns
f_leftcol = (80 - f_widest) / 2                                 && calculate left column position
f_ritecol = f_leftcol + f_widest + 1                            && calculate right column of window
f_window  = SAVESCREEN(f_toprow,f_leftcol,f_botrow,f_ritecol)   && save what is underneath
f_incolor = SETCOLOR(f_color)                                   && save old color an set to white on red, or color specified
SCROLL(f_toprow,f_leftcol,f_botrow,f_ritecol,0)                 && clear screen and paint in designated color
@ f_toprow,f_leftcol,f_botrow,f_ritecol BOX 'ÚÄ¿³ÙÄÀ³'          && draw box around window
FOR f_x = f_indexp TO f_pcount                                  && get widest width for window
   f_pname = 'p' + LTRIM(STR(f_x,2,0))                          && build name of parameter
   @ f_toprow+f_brows+IF( f_lines=f_pcount, f_x, f_x-1 ),;
     (80-LEN(&f_pname))/2 SAY LEFT(&f_pname,65)             && say it in the center of screen
NEXT f_x
f_key = INKEY(f_seconds)                                        && wait for keypress
SETCOLOR(f_incolor)                                             && restore old color
RESTSCREEN(f_toprow,f_leftcol,f_botrow,f_ritecol,f_window)      && restore what was underneath
@ f_saverow,f_savecol SAY ''                                    && re-position the cursor to where it was on entry
RETURN UPPER(CHR(f_key))                                        && return the character pressed
* Function: BRIGHT
* Author..: Richard Low
* Syntax..: BRIGHT( [<expC>] )
* Returns.: Color setting passed as parameter in bright. (With "+" added)
*           If parameter is omitted, current color is switched to bright.

FUNCTION BRIGHT(p_color)
local ret_val

IF TYPE('p_color') = 'C'
   p_color = UPPER(p_color)
ELSE
   p_color = UPPER(SETCOLOR())
ENDIF

IF "/" $ p_color
   ret_val = SUBSTR(p_color, 1, AT('/',p_color)-1 ) + "+" +;
             SUBSTR(p_color, AT('/',p_color) )
ELSE
   IF "," $ p_color
      ret_val = SUBSTR(p_color, 1, AT(',',p_color)-1 ) + "+" +;
                SUBSTR(p_color, AT(',',p_color) )
   ELSE
      ret_val = p_color + "+"
   ENDIF
ENDIF

IF ISCOLOR() .AND. LEFT(ret_val, 2) = "W+"
   *-- if White on a color monitor, make bright Yellow
   ret_val = "GR+" + SUBSTR( ret_val, 3 )
ENDIF

RETURN (ret_val)
* Function: GETPARM
* Author..: Richard Low
* Syntax..: GETPARM( number, string )
* Returns.: Specified portion of the given string, starting at the number-1
*           comma until the next comma, or end of string.
*           if no parameter is given or is an invalid type.

FUNCTION GETPARM(p_number, p_string)
local f_string, x

*-- make sure a parameters are correct
IF TYPE('p_number') + TYPE('p_string') != 'NC'
   RETURN ('')
ENDIF

*-- make working copy to ensure original parmater is not touched
f_string = p_string

*-- find the text following the (nth - 1) comma if any
FOR x = 1 TO p_number - 1
   *-- strip off text preceding the comma
   f_string = TRIM( SUBSTR(f_string, AT(",",f_string) + 1 ) )
NEXT x

*-- if there is a comma in the string
IF AT(",",f_string) > 0
   *-- if it's the 1st character
   IF SUBSTR(f_string,1,1) = ","
      *-- return nothing
      RETURN ('')
   ELSE
      *-- return everything up to the comma
      RETURN (SUBSTR(f_string, 1, AT(",",f_string)-1 ))
   ENDIF
ELSE
   *-- if no comma, just return the string itself
   RETURN (f_string)
ENDIF

RETURN ('')
* Function..: SAYINBOX
* Author....: Richard Low
* Syntax....: SAYINBOX( [color,] line1 [,line2, line3...] [, seconds ] )
* Returns...: Nothing.
* Parameters: color .... Optional variable or constant indicating the screen
*                        color to use in the form 'W/N'.  This variable is
*                        deemed to be a color setting if the 2nd, 3rd, or 4th
*                        character is the '/' character.  The default color
*                        is WHITE foreground on RED background.
*             line1..... The lines to be displayed.
*             seconds... Optional timeout in seconds
* Notes.....: Displays a multi-line message in a window centered on screen.

FUNCTION SAYINBOX
PARAMETERS p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12

local   f_pcount, f_color, f_lines, f_indexp, f_brows, f_bcols, f_top,;
        f_bottom, f_widest, f_x, f_pname, f_left, f_rite, f_window,;
        f_incolor, f_saverow, f_savecol, f_pausing

f_pcount  = PCOUNT()                                            && get param count, multiple calls to PCOUNT() do not work!
f_pname   = 'p' + LTRIM(STR(f_pcount,2,0))                      && get name of last parameter
f_pausing = .F.                                                 && no pause by default
IF TYPE(f_pname) = 'N'                                          && if last parameter is numeric
   f_pausing = .T.                                              && flag to save the screen
   f_seconds = &f_pname                                         && it is number of seconds to pause
   f_pcount  = f_pcount - 1                                     && decrement parameter count
ENDIF
f_color   = SETCOLOR()                                          && default color is current color
f_lines   = f_pcount                                            && 'parameter to display' count; assume each param is a line to display
f_indexp  = 1                                                   && pointer to show which parm line to print
f_saverow = ROW()                                               && save cursor position for restoration
f_savecol = COL()                                               &&  on return
IF STR(AT('/',p1),1,0) $ '234'                                  && if 1st parm is a color setting, a '/' will be at position 2,3, or 4
   f_color  = p1                                                && use 1st parameter as color setting
   f_indexp = 2                                                 && change parm pointer to next one
   f_lines  = f_pcount - 1                                      && adjust 'parameter to display' count
ENDIF
f_brows  = 1                                                    && number of blank rows above and below message
f_bcols  = 5                                                    && blank columns on either side of messages
f_top    = (10 + f_brows) - ROUND(f_lines / 2, 0)               && put in middle of screen with 2 lines above and below
f_bottom = f_top + (2 * f_brows) + f_lines + 1                  && calculate bottom row of window
f_widest = 10                                                   && widest window width default is 10 columns
FOR f_x = f_indexp TO f_pcount                                  && get widest width for window
   f_pname  = 'p' + LTRIM(STR(f_x,2,0))
   f_widest = MAX( f_widest, LEN(&f_pname) )
NEXT f_x
f_widest = MIN( f_widest + (2 * f_bcols), 77 )                  && pad with (bcol) spaces on both sides, max width is 77 columns
f_left = (80 - f_widest) / 2                                    && calculate left column position
f_rite = f_left + f_widest + 1                                  && calculate right column of window
IF f_pausing                                                    && if we are to pause and restore screen
   f_window = SAVESCREEN(f_top,f_left,f_bottom,f_rite)          && save what is underneath
   f_retval = '    '                                            && no need to save window coordinates
ELSE
   f_retval = CHR(f_top)+CHR(f_left)+CHR(f_bottom)+CHR(f_rite)+;
              SAVESCREEN(f_top,f_left,f_bottom,f_rite)          && save window coordinates as 4 byte string and contents
ENDIF
f_incolor = SETCOLOR(f_color)                                   && save old color an set to white on red, or color specified
SCROLL( f_top, f_left, f_bottom, f_rite, 0 )                    && clear screen and paint in designated color
@ f_top,f_left,f_bottom,f_rite BOX 'ÚÄ¿³ÙÄÀ³'                   && draw box around window
FOR f_x = f_indexp TO f_pcount                                  && get widest width for window
   f_pname = 'p' + LTRIM(STR(f_x,2,0))                          && build name of parameter
   @ f_top+f_brows+IF( f_lines=f_pcount, f_x, f_x-1 ),;
     (80-LEN(&f_pname))/2 SAY LEFT(&f_pname,65)             && say it in the center of screen
NEXT f_x
IF f_pausing                                                    && if we are to pause and restore screen
   INKEY(f_seconds)                                             && wait that many seconds
   RESTSCREEN(f_top,f_left,f_bottom,f_rite,f_window)            && restore what was underneath
ENDIF
@ f_saverow,f_savecol SAY ''                                    && re-position the cursor to where it was on entry
SETCOLOR(f_incolor)                                             && restore old color
RETURN f_retval



* Function..: POPBOX
* Author....: Richard Low
* Syntax....: POPBOX( boxstring )
* Returns...: True if sucessful, false otherwise
* Parameters: Specialized string returned by SAYINBOX().  Used to restore a
*             section of screen overwritten by the SAYINBOX() function.

FUNCTION POPBOX(pstring)
local f_top, f_left, f_bottom, f_rite, f_window

*-- retrieve the 4 screen coordinates from prefix 4 byte string
f_top    = ASC( SUBSTR(pstring,1,1) )
f_left   = ASC( SUBSTR(pstring,2,1) )
f_bottom = ASC( SUBSTR(pstring,3,1) )
f_right  = ASC( SUBSTR(pstring,4,1) )

RESTSCREEN( f_top, f_left, f_bottom, f_right, SUBSTR(pstring,5) )
RETURN .T.

* Function..: BOXMENU
* Author....: Richard Low
* Syntax....: BOXMENU( row, column, options [,choice [,altkeys [,exitkeys
*                      [,prompts [,prompt_row [,colors ]]]]]]] )
* Returns...: Number of array element option picked, or 0 if escape pressed.
* Parameters: row       - Top row to start box menu
*             column    - Top left column of menu box
*             options   - Array of menu option choices
*             choice    - Optional starting array element number
*             altkeys   - Optional list of alternate selection keys
*             exitkeys  - Optional list of keys to cause a 0 return value exit
*                         Pass a null string to skip (default = escape)
*                         Pass .F. to disable 0 return value exit altogether
*             prompts   - Optional array of menu option messages
*             promptrow - Optional row number on which these messages appear
*             colors    - Optional character string of colors to use in menu
* Notes.....: If an optional parameters is skipped, you must pass a dummy in
*             its place.

FUNCTION BOXMENU

PARAMETERS p_row, p_col, p_options, p_choice, p_altkeys, p_exitkeys,;
           p_prompts, p_prmtrow, p_colors

LOCAL   f_prompton, f_incolor, f_maxwide, f_junk, f_canexit, f_x, f_lkey,;
        f_display, f_menubar, f_box_on, f_box_off, f_selected


*-- check that first 3 parameters are passed and correct type
IF TYPE('p_row') + TYPE('p_col') + TYPE('p_options') != 'NNA'
   RETURN 0
ENDIF


*-- see if row,column is in range, if not, default to row,column 1,1
p_row = IF( p_row > 24, 1, p_row )
p_col = IF( p_col > 79, 1, p_col )


*-- if p_choice specified make sure it is in range, else default to option 1
p_choice = IF( TYPE('p_choice') = 'N', MIN(MAX(p_choice,1),LEN(p_options)), 1 )


*-- messages displayed only if parm is of type array
f_prompton = ( TYPE('p_prompts') = 'A' )

*-- messages displayed on line 24 unles otherwise specified
p_prmtrow = IF( TYPE('p_prmtrow') = 'N', p_prmtrow, 24 )


*-- save incoming color
STORE SETCOLOR() TO f_incolor

*-- use <color array> if it is an array AND it has at least 5 elements
IF IF( TYPE('p_colors') = 'A', IF(LEN(p_colors) >= 5, .T., .F.) , .F. )
   f_display  = p_colors[1]                    && display color
   f_menubar  = p_colors[2]                    && menu bar color
   f_box_on   = p_colors[3]                    && active box color
   f_box_off  = p_colors[4]                    && box border after exit
   f_selected = p_colors[5]                    && selected option color
ELSE
   STORE SETCOLOR() TO f_display, f_box_off
   STORE BRIGHT() TO f_box_on, f_selected
   f_menubar  = GETPARM(2,f_incolor)
ENDIF


*-- change column number to one to right of the box to avoid lots of math
p_col = p_col + 1

*-- display options, find max width, and build list of first letter pick keys
f_junk = ''
f_maxwide = 1
SETCOLOR(f_display)
FOR f_x = 1 TO LEN(p_options)
   @ p_row+f_x,p_col SAY p_options[f_x]
   f_maxwide = MAX( f_maxwide, LEN(p_options[f_x]) )
   f_junk = f_junk + SUBSTR( LTRIM(p_options[f_x]),1,1 )
NEXT f_x

*-- now draw the box for the menu using the maximum width of options
*-- making the active box a double line box
SETCOLOR(f_box_on)
@ p_row, p_col-1, p_row+LEN(p_options)+1, p_col+f_maxwide BOX 'ÉÍ»º¼ÍÈº'

*-- now add any alternate pick keys passed as parameters to the list, if any
p_altkeys = IF( TYPE('p_altkeys') = 'C', f_junk + p_altkeys, f_junk )

*-- if a Logical was passed in place of exit keys, disable exit feature
f_canexit = IF( TYPE('p_exitkeys') = 'L', p_exitkeys, .T. )

*-- see if any exit keys were passed (and not empty), else default to Escape
p_exitkeys = IF( TYPE('p_exitkeys') = 'C', p_exitkeys, CHR(27) )
p_exitkeys = IF( !EMPTY(p_exitkeys),  p_exitkeys, CHR(27) )

DO WHILE .T.

   *-- display current selection in desired highlite video
   SETCOLOR(f_menubar)
   @ p_row+p_choice,p_col SAY p_options[p_choice]

   *-- if message prompts are on, clear row and display
   IF f_prompton
      SETCOLOR(f_incolor)
      @ p_prmtrow,0
      @ p_prmtrow,(80-LEN(p_prompts[p_choice]))/2 SAY p_prompts[p_choice]
   ENDIF

   *-- reset display color
   SETCOLOR(f_display)

   *-- wait for a key
   f_lkey = INKEY(0)

   DO CASE

      CASE f_lkey = 24
         *-- Down Arrow
         @ p_row+p_choice,p_col SAY p_options[p_choice]
         p_choice = IF( p_choice = LEN(p_options), 1, p_choice + 1 )

      CASE f_lkey = 5
         *-- Up Arrow or Back Space
         @ p_row+p_choice,p_col SAY p_options[p_choice]
         p_choice = IF( p_choice = 1, LEN(p_options), p_choice - 1 )

      CASE f_lkey = 1
         *-- Home Key
         @ p_row+p_choice,p_col SAY p_options[p_choice]
         p_choice = 1

      CASE f_lkey = 6
         *-- End key
         @ p_row+p_choice,p_col SAY p_options[p_choice]
         p_choice = LEN(p_options)

      CASE f_lkey = 13
         *-- Enter key
         EXIT

      CASE UPPER(CHR(f_lkey)) $ p_altkeys
         @ p_row+p_choice,p_col SAY p_options[p_choice]
         f_x = 1
         p_choice = 0
         DO WHILE p_choice = 0
            p_choice = AT(UPPER(CHR(f_lkey)),SUBSTR(p_altkeys,f_x,LEN(p_options)))
            f_x = f_x + LEN(p_options)
         ENDDO
         EXIT

      CASE f_canexit
         IF UPPER(CHR(f_lkey)) $ p_exitkeys
            *-- Escape request
            p_choice = 0
            EXIT
         ENDIF

   ENDCASE
ENDDO

*-- display selected option in selected color
IF p_choice > 0 .AND. p_choice <= LEN(p_options)
   SETCOLOR(f_selected)
   @ p_row+p_choice,p_col SAY p_options[p_choice]
   *-- redraw box in in-active box color
   SETCOLOR(f_box_off)
   @ p_row, p_col-1, p_row+LEN(p_options)+1, p_col+f_maxwide BOX 'ÚÄ¿³ÙÄÀ³'
ENDIF

*-- restore original color
SETCOLOR(f_incolor)

*-- clear message line
IF f_prompton
   @ p_prmtrow,0
ENDIF

RETURN p_choice

*
* ACTTHERM(<text>) - Activate thermometer.
*
* Activates thermometer.  Update the thermometer with UPDTHERM().
* Thermometer window is named "thermometer."  Be sure to RELEASE
* this window when done with thermometer.  Creates the global
* m.g_thermwidth.
*
*!*****************************************************************************
*!
*!      Procedure: ACTTHERM
*!
*!*****************************************************************************
PROCEDURE acttherm
PARAMETER m.text
PRIVATE m.prompt
m.g_graphic = .t.
m.g_outfile = 'Processing'
c_dlgface  = 'Arial'
c_dlgsize  = 10
c_dlgstyle = 'BI'

IF m.g_graphic
   m.prompt = LOWER(m.g_outfile)
   IF TXTWIDTH(m.prompt, c_dlgface, c_dlgsize, c_dlgstyle) > 43
      DO WHILE TXTWIDTH(m.prompt+"...", c_dlgface, c_dlgsize, c_dlgstyle) > 43
         m.prompt = LEFT(m.prompt, LEN(m.prompt)-1)
      ENDDO
      m.prompt = m.prompt + "..."
   ENDIF

   DEFINE WINDOW thermomete ;
      AT  INT((SROW() - (( 5.615 * ;
      FONTMETRIC(1, c_dlgface, c_dlgsize, c_dlgstyle )) / ;
      FONTMETRIC(1, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2), ;
      INT((SCOL() - (( 63.833 * ;
      FONTMETRIC(6, c_dlgface, c_dlgsize, c_dlgstyle )) / ;
      FONTMETRIC(6, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2) ;
      SIZE 5.615,63.833 ;
      FONT c_dlgface, c_dlgsize ;
      STYLE c_dlgstyle ;
      NOFLOAT ;
      NOCLOSE ;
      NONE ;
      COLOR RGB(0, 0, 0, 192, 192, 192)
   MOVE WINDOW thermomete CENTER
   ACTIVATE WINDOW thermomete NOSHOW

   @ 0.5,3 SAY m.text FONT c_dlgface, c_dlgsize STYLE c_dlgstyle
   @ 1.5,3 SAY m.prompt FONT c_dlgface, c_dlgsize STYLE c_dlgstyle
   @ 0.000,0.000 TO 0.000,63.833 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 0.000,0.000 TO 5.615,0.000 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 0.385,0.667 TO 5.231,0.667 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 0.308,0.667 TO 0.308,63.167 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 0.385,63.000 TO 5.308,63.000 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 5.231,0.667 TO 5.231,63.167 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 5.538,0.000 TO 5.538,63.833 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 0.000,63.667 TO 5.615,63.667 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 3.000,3.333 TO 4.231,3.333 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 3.000,60.333 TO 4.308,60.333 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 3.000,3.333 TO 3.000,60.333 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 4.231,3.333 TO 4.231,60.500 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   m.g_thermwidth = 56.269

   SHOW WINDOW thermomete TOP
ELSE
   m.prompt = SUBSTR(SYS(2014,m.g_outfile),1,48)+;
      IIF(LEN(m.g_outfile)>48,"...","")

   DEFINE WINDOW thermomete;
      FROM INT((SROW()-6)/2), INT((SCOL()-57)/2) ;
      TO INT((SROW()-6)/2) + 6, INT((SCOL()-57)/2) + 57;
      DOUBLE COLOR SCHEME 5
   ACTIVATE WINDOW thermomete NOSHOW

   m.g_thermwidth = 50
   @ 0,3 SAY m.text
   @ 1,3 SAY UPPER(m.prompt)
   @ 2,1 TO 4,m.g_thermwidth+4 &g_boxstrg

   SHOW WINDOW thermomete TOP
ENDIF
RETURN

*
* UPDTHERM(<percent>) - Update thermometer.
*
*!*****************************************************************************
*!
*!      Procedure: UPDTHERM
*!
*!*****************************************************************************
PROCEDURE updtherm
PARAMETER m.percent
PRIVATE m.nblocks, m.percent
m.g_numplatforms = 1
m.g_graphic = .t.

ACTIVATE WINDOW thermomete

* Map to the number of platforms we are generating for
m.percent = MIN(INT(m.percent / m.g_numplatforms) ,100)

m.nblocks = (m.percent/100) * (m.g_thermwidth)
IF m.g_graphic
   @ 3.000,3.333 TO 4.231,m.nblocks + 3.333 ;
      PATTERN 1 COLOR RGB(128, 128, 128, 128, 128, 128)
ELSE
   @ 3,3 SAY REPLICATE("Û",m.nblocks)
ENDIF
RETURN

*
* DEACTTHERMO - Deactivate and Release thermometer window.
*
*!*****************************************************************************
*!
*!      Procedure: DEACTTHERMO
*!
*!*****************************************************************************
PROCEDURE deactthermo
IF WEXIST("thermomete")
   RELEASE WINDOW thermomete
ENDIF
RETURN

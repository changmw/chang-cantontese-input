clear all
private ACT3, bailout

  SET READBORDER ON

  DEFINE WINDOW appctrl ;
          AT 20.000, 16.000 ;
          SIZE 3.846,73.167 ;
          TITLE "Control Panel" ;
          FONT "MS Sans Serif", 8 ;
          STYLE "B" ;
          FLOAT ;
          NOCLOSE ;
          NOMINIMIZE ;
          HALFHEIGHT

 * define window w_1 from 00,00 to 02,30 font 'Courier',12

  define window W_LOAN from 05,05 to 10, 70 panel

  select 0
  use loan

  m.m_1 = space(5)

  browse window W_LOAN nowait save
*  activate window w_1
*  @ 0,0 say 'Read 1: ' get m_1 picture '!!!!!'
  IF NOT WVISIBLE("appctrl")
          ACTIVATE WINDOW appctrl
  ENDIF
  @ 0.769,1.500 GET ACT3 ;
          PICTURE "@*HN \<Top;\<Prior;\<Next;\<Bottom;\<Search;\<Quit" ;
          SIZE 1.769,10.000,2.000 ;
          DEFAULT 1 ;
          FONT "MS Sans Serif", 8 ;
          STYLE "B" ;
          VALID moveptr()
  read cycle ;
       activate startup() ;
       deactivate cleanup()

  release window w_1
  clear all
return

function winname
*  wait woutput() window
  return .t.

function startup
  m_1 = 'XXXXX'
*  wait 'startup' window
  return .t.

function cleanup
*  wait 'cleanup' window
*  show gets
  return .f.

FUNCTION moveptr
  DO CASE
    CASE act3 = 1
       GO TOP
    CASE act3 = 2
       IF !BOF()
          SKIP -1
       ENDIF
       IF BOF()
          WAIT WINDOW "Top of file" NOWAIT
          GOTO TOP
       ENDIF
    CASE act3 = 3
       IF !EOF()
          SKIP 1
       ENDIF
       IF EOF()
          WAIT WINDOW "Bottom of file" NOWAIT
          GOTO BOTTOM
       ENDIF
    CASE act3 = 4
       GO BOTTOM
  ENDCASE
  show gets
return

*
**
** Main program
**
** This program aims to demo some of the powerful functions unique to Clipper
** Clipper's networking commands' implementation is better than dBase as well.
** by allowing a higher degree of concurrency. Read manual for detail.
** Enjoy Clippering!
**                                                      Chang Man-wai
**
*
PUBLIC company
set unique off
set deleted on
set exact off
set confirm off

CLEAR                                         && get company file name
company="CUSTOMER"

if .not. file(company+'.DBF')                 && check if database exists
   do disp_msg with 'Database '+company+'.DBF not found',.t.
   return
endif

if .not. file('COUNTRY.DBF')
   do disp_msg with 'Country Code File missing',.t.
   return
endif

if .not. file('COUNTRY.NTX')
   do disp_msg with 'Rebuilding index for country code file...',.f.
   use country
   index on upper(ccode) to country
endif

select 1                                      && check if corresponding index
if .not. file(company+'.NTX')                 && exists
  clear
  do disp_msg with 'Rebuilding index for customer file...',.f.
  use &company.
  pack
  index on upper(cuname) to &company.
endif

do while .t.
  clear
  do showpf with 'ESC','Exit',70                        && display main menu

  set wrap on
  @ 06,20 prompt [A. Maintain Customer File         ]
  @ 09,20 prompt [D. Maintain Country Code          ]
  menu to mans

  do hidepf
  do case
    case mans=1         && maintain database
      do cu_edit
    case mans=2
      do ccodedit       && edit country code table
    otherwise
      exit
  endcase
enddo

clear all
QUIT
* EOF main program

PROCEDURE cu_edit
*
* Maintain customer information
*
  private maccode, mm1, mm2, mm3, mm4, mphone, mtelex, mfax, mcomment, mnature
  Private mRtnCode, mMsg, mans, mcontact, mcat, mcustcode
  set key -9 to controlw        && set functions key

  use &company. index &company.

  clear
  do showhead with [MAINTAIN DATABASE]
  @ 4,0 clear to 20, 79
  do custprom
  do custclrm
  do custgetm
  clear gets
  do while .t.
    do showhead with [CUSTOMERS FILE MAINTENANCE]
    mRtnCode=[ ]
    mMsg=[(A)dd (Q)uit]
    do GetCom with mMsg, [AaQq], mRtnCode
    if lastkey()=27
      exit
    endif
    do case
      case mRtnCode$[Qq]        && exit from system
        exit
      case mRtnCode$[Aa]        && add a record
        do showhead with 'ADD A CUSTOMER'
        do custclrm
        do custgetm
        clear gets
        do showpf with 'ESC','Exit',70
        do showpf with "F10","Save",10
        do getcustn with mcustcode
        read
        if lastkey() = 27       && ESC aborts addition
          do custgetm
          clear gets
          loop
        endif
        select &company.
        seek alltrim(mcustcode)
        if found()
          do disp_msg with [Customer code already exists],.t.
          do custgetm
          clear gets
          loop
        else
          do custgetm
          read
          do hidepf
          if lastkey()=27
            loop
          endif
          do disp_msg with [Adding record...],.f.
          append blank
          do custmovf
          commit
          do disp_msg with space(70),.f.
          loop
        endif
    endcase
  enddo
  set key -9 to
  close all
  release all like m*
RETURN

PROCEDURE custmovf
* update the fields of a record from memory variables
  select &company.
  replace cuname with mcustcode
  replace cuadrs1 with mm1
  replace cuadrs2 with mm2
  replace cuadrs3 with mm3
  replace cuadrs4 with mm4
  replace cuphone with mphone
  replace cutelex with mtelex
  replace ncufax with mfax
  replace cuattn with mcontact
  replace cucomment with mcomment
  replace cunature with mnature
  replace category with mcat
  pack
RETURN

PROCEDURE custclrm
* clear the content of the memory variables
  select &company.
  mcustcode=space(len(cuname))
  mm1 = space(len(cuadrs1))
  mm2 = space(len(cuadrs2))
  mm3 = space(len(cuadrs3))
  mm4 = space(len(cuadrs4))
  mphone = space(len(cuphone))
  mtelex = space(len(cutelex))
  mfax = space(len(ncufax))
  mcontact=space(len(cuattn))
  mcat=space(len(category))
  mnature=space(len(cunature))
  mcomment=space(len(cucomment))
RETURN

PROCEDURE custgetm

  @ 5,       22 say mcustcode picture [@!]
  @ row()+2, 22 get mfax
  @ row()+1, 22 get mphone picture '@9'
  @ row()+1, 22 get mcat picture '@!' valid v_ccode(mcat)
  @ row()+1, 22 get mnature picture '@!'
  @ row()+1, 22 get mcontact picture '@9'
  @ row()+1, 22 get mcomment picture '@!'
  @ row()+1, 22 get mtelex picture '@!'
  @ row()+2, 22 get mm1
  @ row()+1, 22 get mm2
  @ row()+1, 22 get mm3
  @ row()+1, 22 get mm4

RETURN

PROCEDURE ccodedit
  declare fields[2], fieldhead[2], fieldpic[2]
  private codefound, editccode

  select 1
  use country index country

  editccode=.t.
  clear
  do showhead with 'MAINTAIN COUNTRY CODES'

  * point and shoot country code

  fields[1]="CCODE"
  fields[2]="DESCRIPT"
  fieldpic[1]="@!"
  fieldpic[2]=""
  fieldhead[1]="Code"
  fieldhead[2]="Long Name"

  do showpf with 'DEL','Delete',40
  do showpf with 'INS','Insert',50
  do showpf with 'ESC','Exit',70
  @ 6, 10 to 20,45
  set color to w+

  dbedit(7,11,19, 44,fields,"selccode",fieldpic,fieldhead)

  do hidepf
  go top
  do while empty(ccode)    && remove blank records at top of DBF
    delete
    skip
  enddo

  close all
RETURN

FUNCTION v_ccode
parameter pa_ccode
declare fields[2], fieldhead[2], fieldpic[2]
private codefound, editccode

editccode=.f.

select 10
use country index country
seek pa_ccode
codefound=found()
if .not. codefound .or. empty(pa_ccode)
  do disp_msg with 'Country code not found',.t.
  save screen

  * point and shoot country code

  fields[1]="CCODE"             && set up parameters
  fields[2]="DESCRIPT"
  fieldpic[1]="@!"
  fieldpic[2]=""
  fieldhead[1]="Code"
  fieldhead[2]="Long Name"

  @ 9, 26 to 15,66              && clear screen
  dbedit(10,27,14,65,fields,"selccode",fieldpic,fieldhead)

  restore screen
  return(.f.)
endif
RETURN(.T.)

FUNCTION selccode
* point and shoot country code processing routine
PARAMETER mode, fld_ptr

PRIVATE cur_field
cur_field=fields[fld_ptr]
cur_pic=fieldpic[fld_ptr]

do case
   case mode < 4        && Home,Ctrl-RightArrow,PgDn,RightArrow
        return 1
   case lastkey() = 27  && ESC
        return 0
   case lastkey() = 13  && ENTER pressed
        if .not. editccode      && function not availble when editing
           mcat=ccode           && pick the country code
           keyboard Chr(13)     && buffer a carriage return for READ
           return 0
        endif
   case lastkey() = 22  && INS key pressed
        if editccode
           append blank         && add a record
           commit
           return  2            && force re-read to update screen
        endif
   case lastkey() = 7   && DEL key pressed
        if editccode
           delete       && remove record
           skip
           commit       && force physical disk write
           return 2     && force re-read to update screen
        endif
   case lastkey() > 31 .and. lastkey() < 128
        if editccode
           keyboard chr(lastkey())
           @ row(), col() get &cur_field picture cur_pic
           read
           keyboard chr(4)      && buffer right arrow in keyboard input queue
           return 2             && force re-read
        endif
   otherwise
        return 1
endcase
RETURN 1

FUNCTION v_custcode
parameter pa_custcode
if empty(pa_custcode)
  do Disp_Msg with 'Customer code cannot be blank',.t.
  return(.f.)
endif
return(.t.)

PROCEDURE custprom
  set color to w+
  @ 5,       6 SAY [Company Name]
  @ row()+2, 6 SAY [Fax]
  @ row()+1, 6 SAY [Phone]
  @ row()+1, 6 SAY [Country code]
  @ row()+1, 6 SAY [Business Nature]
  @ row()+1, 6 SAY [Contact]
  @ row()+1, 6 SAY [Comment]
  @ row()+1, 6 SAY [Telex]
  @ row()+2, 6 SAY [Address]
  set color to
RETURN

PROCEDURE getcustn
  @ 5, 22 get mcustcode picture '@!' valid v_custcode(mcustcode)
  read
RETURN

PROCEDURE showhead
parameter subtitle
private mtitle,compname
  compname='UDC Research Ltd'
  set date british
  set color to w+
  @ 00, 00 clear to 02,79
  @ 01, (80-len(alltrim(compname)))/2 SAY alltrim(compname)
  @ 01, 70 say date()
  @ 02, (80-len(subtitle))/2 SAY subtitle
  set color to
  set date ansi
RETURN

** Function : get a command
PROCEDURE GetCom
  parameter pa_Prompt, pa_ValidAns, pa_RtnCode
  @ 21,0 clear to 21,79
  @ 21,5 say pa_Prompt
  do while .t.
    @ 21, len(pa_Prompt)+7 get pa_RtnCode
    read
    if pa_RtnCode$pa_ValidAns
      exit
    else
      tone(80)
    endif
  enddo
  @ 21,0 clear to 21,79
RETURN

** Function : display error message
PROCEDURE Disp_Msg
parameter pa_msg, pa_delay
  @ 23, 0 clear to 23, 79
  set color to r+
  @ 23, 0 say pa_msg
  set color to
  if pa_delay
     tone(57.3)
     inkey(3)
     @ 23, 0 clear to 23, 79
  endif
RETURN
** END GetCom

* Show PF keys label on screen
PROCEDURE ShowPF
  parameter pkey, plabel, ppos
  set color to n/w
  @ 24, ppos say pkey
  set color to gb+
  @ 24, ppos+len(pkey)+1 say plabel
  set color to
RETURN

* clear PF key label area
PROCEDURE HidePF
  @ 24, 0 clear to 24, 79
RETURN

FUNCTION worddate
PARAMETER p_date
RETURN str(day(p_date),2,0)+space(1)+cmonth(p_date)+space(1)+str(year(p_date),4,0)

PROCEDURE help
PARAMETER p1, p2, p3
  do disp_msg with 'On-line help not implemented',.t.
RETURN

PROCEDURE controlw
  keyboard chr(23)
RETURN

*
* Created by: Chang Man Wai, 2004
* useful sites: http://www.lexiconer.com/
*
* 06SEP2008 : close canton.dbf as soon as possible
* 04NOV2008 : prevent clearing the clipboard when hitting reset
* 30JAN2009 : show touched, use fixed width font in listbox
* 01FEB2009 : Double-click to email, add text1.interactivechange()
* 03APR009 : Change button "NewLine" to "History",  add property buffer to class MyForm,
*       pressing it would recall all outputed Chinese Big5 and then the buffer be cleared
*       hitting cmdReset would also remember the history
* 13APR2009: Make cmdClip to remember history as well (like cmdReset)
* 10MAY2009: handle adnormal shutdown via "ON SHUTDOWN" and ReleaseType
* 24AUG2009: smarter buffer handling for cmdClip, cmdHistory and cmdReset
* 24SEP2009: show all possible keys text1 is empty
* 15OCT2009: bugfix for text1.valid() when handling blank key input
* 11NOV2009: smarter handling in thisform.text1.interactivechange()
* 20NOV2009: highlight text1 when mouse clicked it via gotfocus()
* 15APR2010: use form.BorderStyle to ensure minimum width & height
* 27MAY2010:  thisform.text1 now accepts only letters
* 17DEC2010: add DEFAULT_CLIPTEXT to faciliate Thunderbird message forwarding,
*	bugfix for the 3 buttons in response to buffer changes, bugfix to SingleInstance()
* 18DEC2010: bugfix for FirstInstance(), add CloseMutex(), add getGUID()
* 10FEB2011: use sysmetric() to find out Window$ desktop size
* 19APR2011: hide the start-up screen by pushing & popping _screen.top and _screen.windowstate
* 25APR2011: discard _screen.old_top
* 07JUL2011: Add checkbox chkOnTop to control Always On Top
* 03SEP2011: Save clipboard when program starts
* 17OCT2011: Better icons: chang32.ico and chang256.ico using IcoFX-1.6.4
* 22OCT2011: If system clipboard is empty, set it to DEFAULT_CLIPTEXT (to save some clicks)
*	bugfix for "WAIT  WINDOW" after  calling  FirstInstance(); clean  up start-up codes
* 23NOV2011: bugfix for Mutex
* 11MAR2012: Add function pastebig5() after nearly 24 hours of using Google and Usenet!
* 			 Remember to Sleep() a while for SetForegroundWindow() to activate the caret
* 14MAR2012: Add chkDirect to control whether to use pastebig5()
* 22JAN2013: Add PageFrame; Beautify interface
* 27JAN2013: Support List1.DblClick(); Add cmdClear next to Text1; Fix bug in text1.Format;
* 				Re-coded text1.valid() based on text1.interactivechange();
*				Add WasHit to MyCommandButton; Coupled Text1,cmdClear,cmdClip,cmdHistory,cmdReset 
*					using event sequence and MyCommandButton.WasHit
* 01FEB2013: Various bugfixes and simplification of codes
* 02FEB2013: toquit is now char(1); button.washit was set in button.when()
* 11FEB2013: change TabStyle of PageFrame
* 12FEB2013: add cmdWebsite; re-coded mailto() as BrowseTo()
* 20OCT2013: consider position of taskbar when showing this program
* 10FEB2014: fill in form.tooltiptext
* 10APR2014: Add class MyUnicodeTextBox from Textbox of Micro$oft Forms 2.0 ActiveX objects
*            Disable error when canton.dbf cannot be updated (in Win 7 or above)
* 29AUG2014: add btnReturn to frmQuit, add UnicodeToString() and StringToUnicode()
*            testing M$ Forms textbox controls (setting multiline during init)
*            add Page4 to pageframe, change some BackColors,
*            change class of edit1 from EditBox to MyUnicodeTextbox, 
*            MyUnicodeCodeTextbox has no Valid() event but LostFocus()
* 30AUG2014: database change: THEKEY's lengeth increased
*			 Add WideCharToMultiByte() and MultiByteToWideChar()
* 08SEP2014: Add CopyUnicode2Clipboard() to replace _cliptext
*			 Add Page3 to PageFrame1
* 09SEP2014: making progress in handling Unicode and UTF8 via VFP 9
*			 Unicode using functions: sys(3101), strconv()
*			 add uncd c(4) to canton.dbf, to store unicode using base64 encoding strconv(13)
*            increase the length of column big5 from 2 to 4
*			 add recode() which convert big5(dbcs) -> UT8 -> base64 string
* 13SEP2014: make DEFAULT_CLIPTEXT a global variable rather than a #define
* 14SEP2014: Add Unicode characters from CJ-HKSCS-2008.txt, update field Changjie
*            Add functions FromBase64() and ToBase64()
* 15SEP2014: Add tbsave(), tbrest(); ToBase64() output different from strconv(13)
*			 Add variable _screen.cantondbf and detection logic for canton.dbf
* 16SEP2014: Add index on column THEKEY
* 18SEP2014: Add error-checking in cmdUpdate.click() when modifying canton.dbf
*			 Move readcanton(), readoldcanton() & readchangjei ouf of MyForm
*			 Add readhkscs2008()
* 12OCT2014: Add VFP6CopyUnicode() as workaround in VFP 6 to 
* 			 pass Unicode characters to ActiveX controls via clipboard
* 16OCT2014: Add VFP6EncodeUTF8() as workaround in VFP6 to Base64-encode UTF8-8
*            Found paste.exe and clip.exe from 
*                   http://www.c3scripts.com/tutorials/msdos/paste.html
*                   http://www.c3scripts.com/tutorials/msdos/clip.html
*            Add chkBig5Only to Page2
* 17OCT2014: Add LaunchExeAndWait() to replace WinExecute()
*            Bugfix for cmdUpdate and cmdTranscode
* 21OCT2014: re-arrange checkboxes in Page2, alert users about clipboard usage in Page4
* 22NOV2014: bugfix for calling .copy(): always set SelStart & SelLength first, and
*            resetted back to zero after .copy()
* 11MAR2015: remove redundant codes in edit1.lostfocus(), 
*			 bug in page1.text1.lostfocus(), myFrmQuit
* 13MAR2015: add cmdMath instead of using edit1.LostFocus
*			 add cmdFacebook, cmdOffice in Page4 plus various changes
*			 add edit1.KeyUp()
* 14MAR2015: Move less used routines into #ifdef..#endif 
*			 to avoid the 64K file size limit for FXP
* 15MAR2015: Remove all instances of Washit and FormInit
*			 rename page1.text1 to text01'
*			 Reworked list1.KeyPress() to avoid a mysterious SetFocus bug 
*			 on using shortcut key to press a button;
* 16MAR2015: rework Page.activate() and Page.deactivate()
* 18MAR2015: fixed bug in edit1.KeyUp() calling form.KeyPress()
* 24MAR2015: increase the width of edit1; remove text01.LostFocus()
*			 consolidate building of cursor "matched"
* 25MAR2015: rework the Chinese character selection logic
* 26MAR2015: bugfix for pastebig5(); add _screen.default_cliptext
*			 Rename CopyUnicodeText2Clipboard() to ClipUTF16Text()
* 27MAR2015: add MyPage4.lblNotice; add MyPage2.cmbMthd
* 31MAR2015: hide screen by setting _screen.left rather than _screen.top
* 22MAY2015: add tooltips for cmdMath
* 29AUG2015: bugfix for checking for FM20.DLL and add error message
* 10SEP2015: add isDLLAvailable()
* 10JAN2016: Page1.cmdReset now always enabled;
*			 allow ALT+X, ALT+R to exit text0.valid() via reading lastkey()
*			 bugfix for clearing of edit1 on FIRST picking of list1's valie
*			 add _screen.cClipText to remember Window$' clipboard before program start
*			 correct copyright notice (starts with 2004 not 2008)
*			 add _screen.dbf_error; fix error handling involved with opening canton.dbf
*			 cleaned up the display of various error messages in Page1
*			 CANTON.DBF updates since Sep 2015
* 10JAN2016: Move error log to Window$'s temp folders
*			 fix error handling in addone()
* 11JAN2016: cmdClip now always enabled; correct error handler errhand()
* 23MAR2016: Add SetProcessDPIAware(), ResizeControls(), adjust various size parameters
*
* Useful links: 
* http://input.foruto.com/cie/cie_bd.htm
* http://fox.wikis.com/wc.dll?Wiki~SkipValidOnExit
* VFP 9 Runtime installer
* http://www.foxpert.com/runtime.htm
* fm20.dll: http://support.microsoft.com/en-us/kb/224305
*
#undef debug_caret

#define GW_HWNDNEXT 2

#DEFINE GUITHREADINFO_SIZE  48

#DEFINE GUI_CARETBLINKING  1
#DEFINE GUI_INMOVESIZE     2
#DEFINE GUI_INMENUMODE     4
#DEFINE GUI_SYSTEMMENUMODE 8
#DEFINE GUI_POPUPMENUMODE  16

#define KEYEVENTF_KEYUP  0x0002 

#define WM_CHAR				0x0102
#define WM_SETTEXT			0x000C
#define WM_PASTE			0x0302
#define WM_COPYDATA			0x004A
#define EM_REPLACESEL		0x00C2
#define EM_SETSEL			0x00B1

#DEFINE CRYPT_STRING_BASE64 0x0001
#DEFINE CRYPT_STRING_NOCRLF 0x40000000
#DEFINE CRYPT_STRING_NOCR 0x80000000

#define VK_CONTROL		   0x11

*
* WinExecute() from http://www.news2news.com/vfp/?example=2
*
#DEFINE SW_HIDE 0
#DEFINE SW_SHOWNORMAL 1
#DEFINE SW_SHOWMINIMIZED 2
#DEFINE SW_SHOWMAXIMIZED 3
#DEFINE SW_SHOWNOACTIVATE 4
#DEFINE SW_SHOW 5
#DEFINE SW_MINIMIZE 6
#DEFINE SW_SHOWMINNOACTIVE 7
#DEFINE SW_SHOWNA 8
#DEFINE SW_RESTORE 9
#DEFINE SW_SHOWDEFAULT 10

#Define K_F1 28
#Define K_ESC 27
#Define K_ENTER 13
#define K_LF 10
#define K_TAB 9
#define K_DOWN 24

#define MUTEX_NAME "chang_canton"
#define APP_NAME  "Chang's Cantonese Input"
#define ERROR_MUTEX_EXISTS 183

parameters m.p1, m.p2

clear all
close all

set resource off

public g_Form

*
* https://kevinragsdale.net/is-your-app-dpi-aware/
*
DECLARE INTEGER SetProcessDPIAware IN WIN32API
SetProcessDPIAware()
Clear DLLS

with _screen
	.AddProperty("old_left", .left)
	.AddProperty("old_winstate", .WindowState)

	.AddProperty("StartUpFolder", fullpath(curdir()))
	.AddProperty("cantondbf",.StartupFolder+"data\canton.dbf")
	.AddProperty("clipbatname",UniqueFname("bat"))
	.AddProperty("encdbatname",UniqueFname("bat"))
	.AddProperty("txtname", UniqueFname("txt"))
	.AddProperty("outname", UniqueFname("txt"))
	.AddProperty("Quit", .f.)
	.AddProperty("MutexHandle", -1)
	.AddProperty("min_height", 265)
	.AddProperty("min_width", 445)
	.AddProperty("default_cliptext","")
	.AddProperty("cCliptext", _cliptext)
	.AddProperty("dbf_error",.f.)
	* hide screen	
	.left=-2*sysmetric(21)
endwith

_screen.Caption=APP_NAME

* set codepage to Unicode
if left(version(4),2)>"06"
	Sys(3101,65001)
	sys(987,.f.)
else
	sys(3005,65001)
endif

* check existence of canton.dbf, abort if missing
do case
	case file(_screen.cantondbf)
		* data folder under current directory (preferred)
	case file(fullpath(curdir())+"canton.dbf")
		* current directory
		_screen.cantondbf=fullpath(curdir())+"canton.dbf"
	otherwise
		messagebox("missing "+_screen.cantondbf, 16)
		return
endcase

tbsave()

_screen.ShowTips=.t.
_screen.Enabled=.f.
if left(version(4),2)>"06"
	_screen.themes=.f.
endif

Set Exact On
Set Escape Off
set help off
Set Talk Off
Set Notify Off
Set Safety Off

if _vfp.StartMode=4
	set debug off
endif

ON ERROR DO errhand WITH ;
	ERROR( ), MESSAGE( ), MESSAGE(1), PROGRAM( ), LINENO( )

set console off

set alternate to (_screen.clipbatname)
set alternate on
?? "echo off"
?
?? "chcp 65001"
?
?? "clip < "+_screen.txtname
set alternate off
set alternate to

set alternate to (_screen.encdbatname)
set alternate on
?? "echo off"
?
?? "chcp 65001"
?
?? "paste | b64 -e > "+_screen.outname
set alternate off
set alternate to
set console on

if FirstInstance(MUTEX_NAME)
	on shutdown do myquit
	_screen.quit=.f.
	g_form=Createobject("myform")
	DO case
		CASE Type("g_form")="O"
			Set Sysmenu To _Msm_edit
			g_form.Show()
			Read Events
			Set Sysmenu To Default
		CASE _screen.dbf_error=.t.
			MESSAGEBOX("Unable to open CANTON.DBF!")
		otherwise
			MESSAGEBOX("FM20.DLL not found!"+CHR(10) ;
				+"Install Micro$oft Office or ActiveX Control Pad!", ;
				16, APP_NAME ;
			)
	endcase
	CloseMutex()
	on shutdown
else
	messagebox("Program already running!!",16)
endif

_screen.left=_screen.old_left
_screen.WindowState=_screen.old_winstate
_screen.enabled=.t.

delete file (_screen.clipbatname)
delete file (_screen.encdbatname)
delete file (_screen.txtname)
delete file (_screen.outname)

Set Escape On
Set Talk On
Set Notify On
Set Safety On
set debug on
set help on

* must be executed before CLEAR ALL
tbrest()

clear all
release all

If _screen.quit
	Quit
Endif
on error *
set resource on
on error
Return

PROCEDURE errhand
LPARAMETER merror, mess1, mess2, mprog, mlineno
local m.errhand
* disable all errors when writing error log
m.errhand=ON("error")
on error *

set console off
set alternate to (GETENV("TEMP")+"\chang_canton_err.txt") additive
set alternate on
? repl("*",10), date(), time()
? 'Error number: ' + LTRIM(STR(merror))
? 'Error message: ' + mess1
? 'Line of code with error: ' + mess2
? 'Line number of error: ' + LTRIM(STR(mlineno))
? 'Program with error: ' + mprog
? repl("*",10)
set alternate off
set alternate to
set console on

on error &errhand
return

procedure myquit
	local xx
	on error *
	on shutdown
	close all
	xx=sys(2023)+"\*.tmp"
	if _screen.quit
		delete files &xx
	endif
	on error
	quit
return

Define Class MyLabel As Label
	AutoSize=.t.
	FontName="Courier New"
	FontSize=14
	BackStyle=0
	IntegralHeight=.t.
	Caption=""
Enddefine

Define Class MyCommandButton As CommandButton
	Height=30
	Width=120
	FontSize=12
	FontName="Arial Bold"
	Cancel=.f.
Enddefine

Define class MyPage2 as MyPage
	caption="\<Settings"
	
	Add Object chkOnTop As checkbox with ;
		top=30, Left=15, FontSize=12, AutoSize=.t., ;
		Caption="Always On Top", value=.f.
	Add Object chkBig5Only As checkbox with ;
		top=70, Left=15, FontSize=12, AutoSize=.t., ;
		Caption="Big5 Characters Only", value=.f.
	Add Object chkDirect As checkbox with ;
		top=110, Left=15, Fontsize=12, AutoSize=.t., ;
		Caption="Send Key Directly:", Value=.f.
	ADD OBJECT cmbMthd as ComboBox WITH ;
		top=110, Left=165, Width=150, FontSize=12, Style=2, ;
		RowSourceType=1

	PROCEDURE cmbMthd.Init
		this.List(1)='EM_REPLACESEL'
		this.List(2)='WM_PASTE'
		this.List(3)='Sendkey(CTRL+V)'
		this.List(4)='SendKey(Big5)'
		this.value=1
	EndProc

	Function chkOnTop.interactivechange()
		ThisForm.AlwaysOnTop=this.value
	Return .t.

	Procedure chkOnTop.Init
		this.Value=ThisForm.AlwaysOnTop
	EndProc
EndDefine

Define class MyPage3 as MyPage
	caption="\<Update"
	enabled=left(version(4),2)="09"	or .t.

	Add object lblText21 as MyLabel with ;
		top=15, left=5, caption="UTF-8", fontsize=9
	Add object lblText22 as MyLabel with ;
		top=15, left=55, caption="Big5", fontsize=9
	Add object lblText23 as MyLabel with ;
		top=15, left=125, caption="THEKEY", fontsize=9
	Add object lblText24 as MYLabel with ;
		top=15, left=230, caption="Changjei", fontsize=9
	Add object lblText25 as MyLabel with ;
		top=15, left=330, caption="Touched", fontsize=9

	Add Object text21 as MyUnicodeTextbox with ;
		top=35, left=5, ;
		Height=30, width=40, Autosize=.t.
	Add Object text22 as MyTextbox with ;
		top=32, left=55, ;
		Height=30, width=60, value="", format=""
	Add Object text23 as MyTextbox with ;
		top=32, left=125, ;
		Height=30, width=100, value="", format="@"
	Add Object text24 as MyTextbox with ;
		top=32, left=230, ;
		Height=30, width=95, value="", format="@"
	Add Object text25 as MyTextbox with ;
		top=32, left=330, ;
		Height=30, width=80, value="", format=""
	Add Object cmdSearch as MyCommandButton with ;
		top=75, left=5, caption="\<Search"
	Add Object cmdUpdate as MyCommandButton with ;
		top=75, left=140, caption="\<Add", visible=.f.

	Add object lblText11 as MyLabel with ;
		top=120, left=5, caption="UTF-8", fontsize=9
	Add Object text11 as MyUnicodeTextbox with ;
		top=138, left=5, ;
		Height=30, width=40, Autosize=.t.
	Add Object cmdTranscode as MyCommandButton with ;
		top=138, left=50, caption="\<Transcode"
	Add object lblText12 as MyLabel with ;
		top=120, left=180, caption="Base64", fontsize=9
	Add Object text12 as MyTextbox with ;
		top=138, left=180, ;
		Height=30, width=100, value="", format="K"

	Add object lblMessage as MyLabel with ;
		top=215, left=5, AutoSize=.t., ;
		Forecolor=rgb(255,0,0), fontsize=12, fontbold=.t.

	procedure cmdSearch.click()
		local m.uncd
		this.parent.lblMessage.caption=""
		if this.caption="\<Cancel"
			this.caption="\<Search"
			with this.parent
				.text21.text=""
				.text22.value=""
				.text23.value=""
				.text24.value=""
				.text25.value=0
				.cmdUpdate.visible=.f.
				.text11.text=""
				.text12.value=""
			endwith
		else
			with this.parent
				if empty(.text21.text)
					.lblMessage.caption="No UTF-8 character to search!"
					return
				endif
				if left(version(4),2)>"06"
					m.uncd=strconv(alltrim(.text21.text),13)
				else
					* m.uncd=ToBase64(alltrim(.text21.text))
					with .text21
						.selStart=0
						.selLength=len(.text)
						.copy()
						.selLength=0
					endwith
					m.uncd=VFP6EncodeUTF8()
				endif
				.text12.value=m.uncd
				select 0
				m.errhand=on("error")
				on error *
				use (_screen.cantondbf) noupdate
				on error &errhand
				if used()
					locate for uncd=m.uncd
					if found()
						.text22.value=alltrim(canton.big5)
						.text23.value=canton.thekey
						.text24.value=canton.changjei
						.text25.value=canton.touched
						if left(version(4),2)>"06"
							.text11.text=.text21.text
						else
							with .text11
								.text=""
								.Paste()
							endwith
						endif
						.cmdUpdate.caption="\<Update"
					else
						.text22.value=.text21.text
						.lblMessage.caption="Unicode character ("+m.uncd+") not found!"
						.cmdUpdate.caption="\<Add"
					endif
					.cmdUpdate.visible=.t.
					use
				else
					.lblMessage.caption="Unable to open CANTON.DBF!"
				endif
			endwith
			this.caption="\<Cancel"
		endif
	return

	procedure cmdUpdate.click()
		local m.big5, m.uncd, m.thekey, m.changjei, m.touched
		local m.errhand
		this.parent.lblMessage.caption=""
		with this.parent
			if left(version(4),2)>"06"
				m.uncd=strconv(alltrim(.text21.text),13)
			else
				with .text21
					.selStart=0
					.selLength=len(.text)
					.copy()
					.selLength=0
				endwith
				m.uncd=VFP6EncodeUTF8()
			endif
			m.big5=.text22.value
			m.thekey=alltrim(.text23.value)
			m.changjei=alltrim(.text24.value)
			m.touched=.text25.value
			m.errhand=on("error")
			on error *
			select 0
			use (_screen.cantondbf) shared
			on error &errhand
			if used()
				locate for uncd=m.uncd
				if found()
					replace big5 with m.big5
					replace thekey with m.thekey
					replace changjei with m.changjei
					replace touched with m.touched
					.lblMessage.caption="UTF-8 character ("+m.uncd+") updated!"
				else
					insert into canton ( ;
						uncd, thekey, big5, changjei, touched ;
					) values ( ;
						m.uncd, m.thekey, m.big5, m.changjei, m.touched ;
					)
					.lblMessage.caption="UTF-8 character ("+m.uncd+") added!"
				endif
				use
			else
				.lblMessage.caption="Unable to open CANTON.DBF!"
			endif
			.text21.text=""
			.text22.value=""
			.text24.value=""
			.text25.value=0
			.cmdUpdate.visible=.f.
			.cmdUpdate.caption="\<Add"
			.cmdSearch.caption="\<Search"
			.text11.text=""
			.text12.value=""
		endwith
	endproc

	procedure cmdTranscode.click()
		this.parent.lblMessage.caption=""
		with this.parent
			do case
				case empty(.text11.text) and empty(.text12.value)
					.lblMessage.caption="Fill in UTF-8 or Base64 to transcode!"
				case empty(.text11.text)
					if left(version(4),2)>"06"
						.text11.text=strconv(.text12.value,14)						
						.text21.text=.text11.text
					else
						VFP6CopyUnicode(FromBase64(.text12.value))
						.text11.paste()
						.text21.text=""
						.text21.paste()
					endif
				case empty(.text12.value)
					if left(version(4),2)>"06"
						.text12.value=strconv(.text11.text,13)
						.text21.text=.text11.text
					else
						* .text12.value=ToBase64(.text11.text)
						with .text11
							.selStart=0
							.selLength=len(.text)
							.copy()
							.selLength=0
						endwith
						.text12.value=VFP6EncodeUTF8()
						.text21.text=""
						.text21.paste()
					endif
				otherwise
					.text11.text=""
					.text12.value=""
			endcase
		endwith
	return
EndDefine

Define class MyPage4 as MyPage
	caption="\<About"
	* BackColor=RGB(199,157,83)

	Add Object cmdFacebook as Image with ;
		top=10, Left=10, Width=90, Height=90, ;
		picture="hanghing.jpg", Stretch=2, ToolTipText="Facebook"
	Add Object lblNotice As Label With ;
		top=10, Left=120, Height=50, Width=300, FontSize=10, FontItalic=.t., FontBold=.t., WordWrap=.t.,;
		AutoSize=.t., ForeColor=rgb(255,64,64), ;
		Caption="This program needs Microsoft Office (FM20.DLL) to display Unicode, ";
			+ "needs system locale set to Traditional Chinese and " ;
			+ "uses the Window$ clipboard extensively!"

	Add Object lblCantonDBF As EditBox With ;
		top=110, Left=15, Fontsize=10, Width=400, Height=50, ;
		Scrollbars=0, Fontname="Courier New", Enabled=.f., ;
		Value="Data: "+_screen.cantondbf

	Add Object lblFreeware As Label With ;
		top=165, Left=15, FontSize=10, FontBold=.t., AutoSize=.t., ;
		Caption="Freeware (2004-"+ltrim(str(year(date())))+")", ForeColor=rgb(128,64,0)
	Add Object cmdWebsite as MyCommandButton with ;
		top=160, Left=170, Width=240, Height=20, FontSize=8, FontItalic=.t., ForeColor=rgb(128,64,0), ;
		Caption="http://sites.google.com/site/changmw"

	Add Object lblEmailA As Label With ;
		top=190, Left=15, FontSize=8, AutoSize=.t., Caption="Programmed by"
	Add Object lblEmailB As Label With ;
		top=190, Left=100, FontSize=8, FontBold=.t., AutoSize=.t., ForeColor=rgb(128,64,0), ;
		Caption="Man-wai Chang"
	Add Object cmdEmail as MyCommandButton with ;
		top=185, Left=190, Width=190, Height=20, FontSize=8, FontItalic=.t., ForeColor=rgb(128,64,0), ;
		Caption="Email: toylet.toylet@gmail.com"

	Add Object lblCopyRightA As Label With ;
		top=210, Left=15, FontSize=8, AutoSize=.t., Caption="Powered by"
	Add Object lblCopyRightB As Label With ;
		top=210, Left=90, FontSize=8, FontBold=.t., AutoSize=.t., ForeColor=rgb(128,64,0), ;
		Caption="Micro$oft Visual Foxpro ";
				+iif(left(version(4),2)=="06","6","9") ;
				+" (SP" ;
				+iif(left(version(4),2)=="06","5","2") ;
				+")"

	Function cmdEmail.Click()
		local m.lcTarget
		m.lcTarget = "mailto:toylet.toylet@gmail.com"+ ;
		  "?CC=&Subject= About Chang's Cantonese Input"+ ;
		   "&Body= "
		BrowseTo(m.lcTarget)
	return .t.

	Function cmdWebsite.Click()
		local m.lcTarget
		m.lcTarget="https://sites.google.com/site/changmw/foxpro/cantonese-input"
		BrowseTo(m.lcTarget)
	return

	Function cmdFacebook.click()
	local m.lcTarget
	m.lcTarget="https://www.facebook.com/groups/156886187680074/"
	BrowseTo(m.lcTarget)
	return
EndDefine

Define Class MyTextBox As TextBox
	FontSize=16
	Format="!K"
	IntegralHeight=.t.

	lastvalue=""
Enddefine

Define class MyAnimation as OleControl 
	OLEClass="ComCtl2.Animation.1"

	Procedure Init
		this.Open("hanghing.avi")
		this.Play()
	EndProc
EndDefine

Define class MyUnicodeEdit As MyUnicodeTextBox 
	Width=255
	Height=120
	ToolTipText="Enter a maths. equation here"
	
	Procedure Init
		dodefault()
		* run "command /c echo "44CQ6L2J6LK844CR" | b64 -d | clip"
		*
		* http://www.foxite.com/archives/vfp-unicode-0000233480.htm
		* this.text=strconv(STRCONV("rpt3gmlfcoJnUW5/b5g6eU9c",14),10)
		*
		this.top=this.parent.my_top+60
		this.Left=this.parent.my_left+170
		this.multiline=.T.
	EndProc
EndDefine

Define class MyUnicodeTextbox as OleControl 
*!*		http://www.foxite.com/archives/vfp-unicode-0000233480.htm
*!*
*!*		http://support.microsoft.com/kb/171673
*!*
*!*		Microsoft ActiveX Control Pad
*!*		http://msdn.microsoft.com/en-us/library/ms968493.aspx
	OleClass="Forms.TextBox.1"
	default_text=""

	procedure init
		this.multiline=.F.
		this.font.size=13
		this.IntegralHeight=.t.
		this.selectionmargin=.f.
		this.text=""
*!*		this.scrollbars=3
*!*		this.textAlign=3 
*!*		this.IMEmode=0 
		this.font.name="Courier New"
*!*		this.forecolor=rgb(0,0,255)*
*!*		=COMPROP(this,"UTF8",1)
	return .t.

	Function keyup
		lparameters keycode, shift
		*** activex control event ***
		* http://weblogs.foxite.com/ammarhadi/2009/07/12/activex-keypress-chaos/
		do case
			case keycode.value=K_ESC
				nodefault
				thisform.KeyPress(keycode.value, shift)
			case keycode.value=K_TAB
				nodefault
				this.parent.text01.SetFocus()
		endcase
	return
EndDefine

Define class MyUnicodeLabel as OleControl
	OleClass="Forms.TextBox.1"

	procedure init
		this.IntegralHeight=.t.
		with this.font
			.name="Courier"
			.size=13
			.bold=.t.
		endwith
		this.SpecialEffect=0
		this.BackColor=this.parent.BackColor
		this.SelectionMargin=.f.
		this.Enabled=.f.
		this.text=""
	return .t.

	Function When
		this.parent.text01.Setfocus()
	return .f.
EndDefine

Define class MyLblContainer as Container
	height=50
	width=255
	BorderWidth=0
	BackColor=RGB(197,156,60)

	Add Object lblUncd As MyUnicodeLabel With ;
		top=3, Left=5, width=30, Height=25

	Add Object lblChangjei As MyLabel With ;
		top=5, Left=30, width=80, Height=25, ;
		ForeColor=RGB(0,64,255), ToolTipText="­Ü¾e½X"
	Add Object lblMatches As myLabel With ;
		top=3, Left=105, width=this.width-10-100, ;
		AutoSize=.f., Alignment=1
	Add Object lblCalculate As myLabel With ;
		top=25, Left=5, width=this.width-10, height=30, ;
		Autosize=.f., Alignment=1
EndDefine

Define class MyPage1 as MyPage
	caption="\<Main"
	my_top=5
	my_left=5

	Add Object text01 As MyTextbox With ;
		top=this.my_top+8,Left=this.my_left+5,Height=29, Width=125, ;
		FontName="Courier New", Format="@!",Value="", SelectOnEntry=.t.

	Add Object list1 As ListBox With ;
		top=this.my_top+50,Left=this.my_left,Width=165,Height=165, ;
		FontName="Courier New", FontSize=14, ;
		rowsourcetype=6, ;
		columncount=2, ;		
		columnlines=.f., ;
		IntegralHeight=.t., ;
		rowsource="left(matched.big5,7), kissed"

	Add Object cmdClear as MyCommandButton with ;
		top=this.my_top+8,Left=this.my_left+5+130+5, ;
		Width=20,Caption="\<X", enable=.t., TabStop=.f.

	* Add Object edit1 As MyUnicodeEdit

	Add Object cmdClip As MyCommandButton with ;
		top=this.my_top+185,Left=this.my_left+170, Width=70, Caption="\<Copy", enabled=.t.
	Add Object cmdHistory As MyCommandButton with ;
		top=this.my_top+185,Left=this.my_left+170+75, Width=70,Caption="\<History", enabled=.f.
	Add Object cmdReset As MyCommandButton With ;
		top=this.my_top+185,Left=this.my_left+170+75+75, Width=70,Caption="\<Reset", enabled=.t.
	Add Object cmdMath As Image With ;
		top=this.my_top+185,Left=this.my_left+170+75+75+15+60, Width=24, Height=30, ;
		Stretch=2, Picture="cmdMath.jpg", BackStyle=0, ToolTipText="Do Maths in EditBox"

	Add Object CntLabels as MyLblContainer with ;
		top=this.my_top+3, left=this.my_left+170

	Function cmdClear.Click()
		with this.parent.text01
			.Value=""
			.InteractiveChange()
			.SetFocus()
		endwith
	return
	
	Procedure text01.valid()
		local m.loObj
		if lastkey()=K_ESC
			return .t.
		ENDIF
		IF INLIST(LASTKEY(),19,45,46)
			* ALT+R(cmdReset), ALT+X(cmdClear), ALT+C(cmdClip)
			RETURN .t.
		ENDIF
		m.loObj=sys(1270)
		if type("loObj")="O"
			if upper(loObj.name)="CMDCLEAR"
				return .t.
			ENDIF
		endif
		if !used("matched") or reccount("matched")=0
			this.SelStart=0
			this.SelLength=len(alltrim(this.Value))
			return .f.
		endif
		if matched.big5=this.value
			IF !BuildMatched(this.value,.t.)
				with this.parent.CntLabels
					.lblCalculate.caption=""
					.lblMatches.caption=""
				endwith
				RETURN .f.
			endif
		endif
	return .t.

	Function text01.interactivechange()
	LOCAL m.dbferr
	with this.parent.CntLabels
		.lblCalculate.caption=""
		.lblMatches.caption=""
	endwith
	m.dbferr=.f.
	do case
		case !BuildMatched(this.value, .f.)
			m.dbferr=.t.
		case reccount("matched")==0
			* no syllable match, search remap
			Select modified From remap ;
				where original=This.Value ;
				into Cursor t_dummy
			If !empty(t_dummy.modified)
				This.Value=t_dummy.modified
				m.dbferr=!BuildMatched(this.Value, .f.)
			Endif
			Use In t_dummy
		case reccount("matched")=1
			m.dbferr=!BuildMatched(this.value, .t.)
	ENDCASE
	with this.parent
		IF m.dbferr
			.CntLabels.lblCalculate.caption="Can't open CANTON.DBF!"
		ELSE
			.CntLabels.lblMatches.Caption=alltrim(str(reccount("matched")))+" matches"
		endif
		with .list1
			.requery()
			.listindex=1
		endwith
	endwith
	return m.dbferr

	Function cmdMath.Click()
	local m.aa, m.errhand
	with this.parent
		if empty(.edit1.text)
			.cntLabels.lblCalculate.caption="No maths expression!"
			return
		endif
		m.aa=alltrim(.edit1.text)
		m.aa=strtran(m.aa,space(1),"")
		m.aa=strtran(m.aa,chr(K_ENTER),"")
		m.aa=strtran(m.aa,chr(K_LF),"")

		m.errhand=on("error")
		on error *
		m.aa=eval(m.aa)
		on error &errhand

		if type("m.aa")="N"
			if m.aa<>0
				.cntLabels.lblCalculate.caption=floatpnt(m.aa,15,4)
			endif
		else
			.cntLabels.lblCalculate.caption="Not an equation!!"
		endif
	endwith
	return

	Function list1.DblClick()
		keyboard chr(K_ENTER)
		nodefault
	return .t.

	Procedure list1.KeyPress
	lparameter nKeyCode, nsac
	Local m.thekey, m.tempbuffer, m.xx
	with this.parent
		do case
			case between(nKeyCode,asc("A"),asc("Z")) or between(nKeyCode,asc("a"),asc("z"))
				nodefault
				this.parent.text01.SetFocus()
				keyboard chr(nKeyCode)
			case nKeyCode=K_TAB
				nodefault
				.text01.SetFocus()
			case nkeycode=K_ENTER
				nodefault
				if this.parent.edit1.text==this.parent.edit1.default_text
					thisform.buffer=this.parent.edit1.text
					this.parent.edit1.text=""
				endif
				If matched.leaf
					.cntLabels.lblUncd.text=""
					.cntLabels.lblChangjei.caption=""
					* leaf, no need to drill further, user chose the chinese character
					thisform.addone(matched.big5)
					do case
						case thisform.PageFrame1.Page2.chkBig5Only.value
	 						m.xx=alltrim(matched.big5)
							.edit1.text=.edit1.text+m.xx
							.cntLabels.lblUncd.text=m.xx
						case left(version(4),2)>"06"
							m.xx=strconv(alltrim(matched.uncd),14)
							.edit1.text=.edit1.text+m.xx							
							.cntLabels.lblUncd.text=m.xx
						otherwise
	 						m.xx=FromBase64(alltrim(matched.uncd))
							VFP6CopyUnicode(m.xx)
							.edit1.paste()
							with .cntLabels.lblUncd
								.text=""
								.Paste()
							endwith
					ENDCASE
					WITH thisform.PageFrame1.Page2
						if .chkDirect.value
							pastebig5(.cmbMthd.value, m.xx, matched.big5)
						ENDIF
					endwith
					with thisform.PageFrame1.Page3.text21
	 					if left(version(4),2)>"06"
							.text=m.xx
						else
							.text=""
							.paste()
						endif
					endwith
					.cntLabels.lblChangjei.caption=":"+space(1)+matched.changjei
				Else
					* NOT leaf, load the chinese characters of the branch
					m.thekey=alltrim(matched.big5)
					with .text01
						.Value=m.thekey
						.lastValue=m.thekey
					endwith
					IF BuildMatched(m.thekey, .t.)
						.list1.Requery()
						.cntLabels.lblMatches.Caption=Alltrim(Str(Reccount("matched")))+" Matches"
					ELSE
						.cntLabels.lblMatches.Caption=""
					endif
				Endif
		Endcase
	endwith
	Endproc

	Procedure cmdClip.Click
	* copy to windows clipboard
	with this.parent
		if !empty(.edit1.text)
			with .edit1
				.selStart=0
				.selLength=len(.text)
				.copy()
				.selLength=0
			endwith
			thisform.buffer=thisform.buffer ;
				+iif(empty(thisform.buffer),"",CHR(K_LF)) ;
				+.edit1.text
			.cmdHistory.enabled=!empty(thisform.buffer)
		endif
		.text01.SetFocus()
	endwith
	Endproc

	Procedure cmdHistory.Click
	with this.parent
		.edit1.text=Thisform.buffer
		thisform.buffer=""
		this.enabled=.f.
		.text01.SetFocus()
	endwith
	Endproc

	Procedure cmdReset.Click
	local m.lastline, m.xx
	with this.parent
		m.xx=.edit1.text
		if thisform.lastclip()<>m.xx
			thisform.buffer=thisform.buffer ;
				+iif(empty(thisform.buffer),"",chr(K_ENTER)) ;
				+m.xx
		endif
		.edit1.text=""
		.cmdHistory.enabled=!empty(thisform.buffer)
		.text01.SetFocus()
	endwith
	Endproc

	Procedure Activate
		this.text01.setfocus()
		dodefault()
	Endproc
EndDefine

Function BuildMatched
LParameter m.thekey, m.leaf
LOCAL m.errhand
	m.errhand=ON("error")
	ON ERROR *
	select 0
	use (_screen.cantondbf) noupdate alias cantonha
	ON ERROR &errhand
	IF !USED("cantonha")
		return .f.
	endif
	if used("matched")
		use in matched
	endif
	if m.leaf
		Select big5, uncd, changjei, ;
			m.leaf As leaf, kissed_mask(touched) as kissed;
		from cantonha ;
		where thekey=m.thekey ;
		order by touched descending ;
		into Cursor matched
	else
		m.thekey=alltrim(m.thekey)
		Select distinct thekey As big5, "" as uncd, Space(1) As changjei, ;
			m.leaf As leaf, "" as kissed ;
		from cantonha ;
		where !empty(thekey) ;
			and left(thekey,len(m.thekey))=m.thekey ;
		order by thekey ;
		into Cursor matched
	endif
	use in cantonha
return .t.

Define class MyPage as Page
	Fontsize=11
	FontName="Tahoma"

	Function Activate
		this.FontBold=.t.
		this.refresh()
	return

	Function Deactivate
		this.FontBold=.f.
		this.refresh()
	return
Enddefine

Define class MyPageFrame as PageFrame 
	TabStyle=1
    top=5
    Left=5
    width=_screen.min_width-6
    height=_screen.min_height-6

	Add object Page1 as MyPage1
	Add object Page2 as MyPage2
	Add object Page3 as MyPage3
	Add object Page4 as MyPage4
EndDefine

Define Class MyForm As Form
	icon="chang256.ico"
	ToolTipText=APP_NAME

	ShowWindow=2
	ShowTips=.t.
	AlwaysOnTop=.t.
	Desktop=.t.

	Caption=APP_NAME
	KeyPreview=.T.
	AutoCenter=.f.
	MaxButton=.f.
	Visible=.f.
	Width=_screen.min_width
	Height=_screen.min_height
	BorderStyle=1

	oToolbar=.F.
	Buffer=""
	WidthRatio = 0
	HeightRatio = 0

	Add Object PageFrame1 as MyPageFrame

	Procedure Load
	IF !BuildMatched("", .f.)
		_screen.dbf_error=.t.
		NODEFAULT
		RETURN .f.
	endif
	_screen.default_cliptext=FromBase64("44CQ6L2J6LK844CR")
	Create Cursor remap ( vowel c(5), original c(10), modified c(10) )
	Thisform.makeremap()
	Endproc

	Procedure Init
	local m.xx, m.errhand

	this.lockscreen=.t.
	m.errhand=on("error")
	ON ERROR *
	select 0
	use (_screen.cantondbf) noupdate
	ON error &errhand
	IF USED("canton")
		count to m.xx for !empty(thekey)
		use in canton
	else
		m.xx=0
	endif
	with thisform.PageFrame1.Page1
		with .CntLabels
			.lblMatches.Caption=Alltrim(Str(m.xx))+" Words"
			* matched cursor pre-built by Form.Load()
			.lblCalculate.Caption=Alltrim(Str(reccount("matched")))+" Syllables"
		endwith
		.list1.Value=1
 		.addobject("edit1", "MyUnicodeEdit")
		with .edit1
			if left(version(4),2)>"06"
				.text=_screen.default_cliptext
			else
				VFP6CopyUnicode(_screen.default_cliptext)
				.paste()
			ENDIF
			.default_text=.text
			.visible=.t.
		endwith
		.text01.setfocus()
	ENDWITH

	* 
	* http://www.tek-tips.com/viewthread.cfm?qid=1394826
	*
	LOCAL loControl
	WITH Thisform
	  *** Determine the ratio needed to maximize the form
	  *** depending on screen resolution and store it to form properties
	  .WidthRatio = SYSMETRIC( 1 ) / 1920
	  .HeightRatio = SYSMETRIC( 2 ) / 1080
	  *** If resolution is higher than 640 x 480, reposition
	  *** and maximize the form
	  IF .WidthRatio > 1
	    .Width = .Width * .WidthRatio
	    .Height = .Height * .HeightRatio
	    *** And resize each control contained in the form
	    FOR EACH loControl IN .Controls
	      .ResizeControls( loControl )
	    ENDFOR
	  ENDIF
	ENDWITH 

	* consider position of taskbar
	This.Left=sysmetric(21)-this.width
	This.Top=sysmetric(22)-this.height-15

	this.lockscreen=.f.

	Endproc

	* 
	* http://www.tek-tips.com/viewthread.cfm?qid=1394826
	*
	PROCEDURE ResizeControls
	LPARAMETERS toControl
	LOCAL loPage, loControl, loColumn, lnColumnWidths[1], lnCol
	IF PEMSTATUS( toControl, 'Width', 5 )
	  toControl.Width = toControl.Width * Thisform.WidthRatio
	ENDIF 
	IF PEMSTATUS( toControl, 'Height', 5 )
	  toControl.Height = toControl.Height * Thisform.HeightRatio
	ENDIF
	IF PEMSTATUS( toControl, 'Top', 5 )
	  toControl.Top = toControl.Top * Thisform.HeightRatio
	ENDIF
	IF PEMSTATUS( toControl, 'Left', 5 )
	  toControl.Left = toControl.Left * Thisform.WidthRatio
	ENDIF
	*** Now resize the font of the control, grid (naturally <g>) is a special case because
	*** resizing the font resizes the column widths of the grid, so save and restore them
	IF UPPER( ALLTRIM( toControl.Baseclass ) ) = 'GRID'
	  DIMENSION lnColumnWidths[toControl.ColumnCount]
	  FOR lnCol = 1 TO toControl.ColumnCount
	    lnColumnWidths[lnCol] = toControl.Columns[lnCol].Width
	  ENDFOR 
	  toControl.Fontsize = INT( toControl.FontSize * Thisform.WidthRatio )
	  FOR lnCol = 1 TO toControl.ColumnCount
	    toControl.Columns[lnCol].Width = lnColumnWidths[lnCol]
	  ENDFOR 
	ELSE 
	  IF PEMSTATUS( toControl, 'Fontsize', 5 )
	    toControl.Fontsize = INT( toControl.FontSize * Thisform.WidthRatio )
	  ENDIF 
	ENDIF
	DO CASE
	  CASE UPPER( toControl.BaseClass ) = 'PAGEFRAME'
	    FOR EACH loPage IN toControl.Pages
	      Thisform.ResizeControls( loPage )
	    ENDFOR
	  CASE INLIST( UPPER( toControl.BaseClass ), 'PAGE', 'CONTAINER' )
	    FOR EACH loControl IN toControl.Controls
	      Thisform.ResizeControls( loControl )
	    ENDFOR
	  CASE UPPER( toControl.BaseClass ) = 'GRID'
	    WITH toControl
	      .RowHeight = .RowHeight * Thisform.HeightRatio
	      .HeaderHeight = .HeaderHeight * Thisform.HeightRatio
	      FOR EACH loColumn IN .Columns
	        loColumn.Width = loColumn.Width * Thisform.WidthRatio
	      ENDFOR
	    ENDWITH 
	  CASE INLIST( UPPER( toControl.BaseClass ), 'COMBOBOX', 'LISTBOX' ) 
	    LOCAL lnCol, lnStart, lnEnd, lnLen, lcColumnWidths
	    WITH toControl
	    	IF !EMPTY(.ColumnWidths)
		      IF .ColumnCount < 2
		        .ColumnWidths = ALLTRIM( STR( .Width ) )
		      ELSE 
		        lcColumnWidths = ""
		        lnStart = 1
		        FOR lnCol = 1 TO .ColumnCount - 1
		          lnEnd = AT( ',', .ColumnWidths, lnCol ) 
		          lnLen = lnEnd - lnStart 
		          lcColumnWidths = lcColumnWidths + IIF( EMPTY( lcColumnWidths ), ', ','' ) + ALLTRIM( STR( VAL (SUBSTR( .ColumnWidths, lnStart, lnLen ) ) * Thisform.WidthRatio ) )
		          lnStart = lnEnd + 1
		        ENDFOR 
		        lnLen = LEN( .ColumnWidths ) - lnStart + 1
		        lcColumnWidths = lcColumnWidths + ',' + ALLTRIM( STR( VAL (SUBSTR( .ColumnWidths, lnStart, lnLen ) ) * Thisform.WidthRatio ) )
		        .ColumnWidths = lcColumnWidths
		      ENDIF
	      endif
	    ENDWITH 
	  CASE INLIST( UPPER( ALLTRIM( toControl.BaseClass ) ), 'COMMANDGROUP', 'OPTIONGROUP' )
	    LOCAL lnButton
	    FOR lnButton = 1 TO toControl.ButtonCount
	      ThisForm.resizeControls( toControl.Buttons[lnButton] )
	    ENDFOR
	  OTHERWISE
	    *** There is no otherwise...I think we got all cases 
	ENDCASE 
	EndProc

	Procedure Activate
		* the reason to turn off _screen here is to ensure that
		* the form got focus when program started
		_Screen.Visible=.F.
		dodefault()
	Endproc

	Procedure Unload
		if used("matched")
			Use In matched
		endif
		if used("remap")
			Use In remap
		endif
	Endproc

	Procedure KeyPress
	LParameters nkeycode, nsac
		If nKeyCode=K_ESC
			Thisform.QueryUnload()
			Nodefault
		Endif
	return

	Procedure QueryUnload
	Local frmQuit, loParam

	if this.ReleaseType=2
		_screen.quit=.t.
		clear events
		thisform.release()
	else
		loParam=Createobject("MyParam")
		frmQuit=Createobject("MyFrmQuit",loParam)
		frmQuit.Show()
		Do Case
			Case loParam.toquit="N"
				nodefault
			Case loParam.toquit="X"
				_screen.quit=.T.
				Clear Events
				thisform.release()
			Case loParam.toquit="Y"
				Clear Events
				thisform.release()
		Endcase
	endif
	Endproc

	Procedure Destroy
		_Screen.Visible=.T.
	Endproc

	function lastclip
	local m.xx, m.errhand
	m.xx=mline(thisform.buffer,memlines(thisform.buffer))
	return m.xx

	function addone
	lparameter m.lcBig5
	* This whole routine should ignore readwrite errors
	local m.errhand
	m.errhand=on("error")
	on error *
	select 0
	use (_screen.cantondbf) shared ALIAS updcanton
	IF USED("updcanton")
		locate for big5=m.lcBig5
		if found()
			select updcanton
			replace touched with touched+1
		endif
		use in updcanton
	endif
	on error &errhand
	return .t.

	Procedure makeremap
* missing: DEN, AI, TAG, TIM
	Insert Into remap Values ( "IU", "DIU", "DEW" )
	Insert Into remap Values ( "EONG", "CHEONG", "CHERN" )
	Insert Into remap Values ( "EUNG", "CHEUNG", "CHERN" )
	Insert Into remap Values ( "EUNG", "LEUNG", "LERN" )
	Insert Into remap Values ( "EUNG", "HEUNG", "HERN" )
	Insert Into remap Values ( "EUNG", "KEUNG", "KERN" )
	Insert Into remap Values ( "EUNG", "SHEUNG","SHERN" )
	Insert Into remap Values ( "EUNG", "TSEUNG","JUNK" )
	Insert Into remap Values ( "ANG",  "HANG", "HUNT" )
	Insert Into remap Values ( "EAN",  "DEAN", "DIN" )
	Insert Into remap Values ( "O",    "NGO", "ALL" )
	Insert Into remap Values ( "O",    "LO",  "NO" )		&& LOW, LAW
	Insert Into remap Values ( "O",    "SO",  "SOUL" )
	Insert Into remap Values ( "O",    "KO",  "GO" )
	Insert Into remap Values ( "O",    "HO",  "HALL" )
	Insert Into remap Values ( "O",    "WO",  "WALL" )
	Insert Into remap Values ( "O",    "MO",  "MODE" )
	Insert Into remap Values ( "IN",   "LIN", "LEAN" )
	Insert Into remap Values ( "IN",   "NIN", "LEAN" )
	Insert Into remap Values ( "IN",   "LIN", "LEAN" )
	Insert Into remap Values ( "IN",   "HIN", "HINT" )
	Insert Into remap Values ( "AN",   "SAM", "SUM" )
	Insert Into remap Values ( "AM",   "KAM", "GUM" )
	Insert Into remap Values ( "AM",   "NAM", "LARM" )
	Insert Into remap Values ( "AM",   "LAM", "LUMP" )		&& LUMP, LARM
	Insert Into remap Values ( "AU",   "LAU", "NULL" )		&& NULL, LOUD
	Insert Into remap Values ( "AU",   "SAU", "SHOUT" )
	Insert Into remap Values ( "AU",   "GAU", "COW" )
	Insert Into remap Values ( "AU",   "KAU", "CULT" )
	Insert Into remap Values ( "AU",   "NGAU", "OUT" )
	Insert Into remap Values ( "AU",   "CHAU", "CHOW" )
	Insert Into remap Values ( "AU",   "SHAU", "SHOUT" )
	Insert Into remap Values ( "AN",   "KWAN", "GROUND" )
	Insert Into remap Values ( "AN",   "MAN", "MUNK" )
	Insert Into remap Values ( "AN",   "SAN", "SARM" )		&& SARM, SAND
	Insert Into remap Values ( "AN",   "DAN", "DANT" )		&& DEN, DANT, DOWN
	Insert Into remap Values ( "ENG",  "SENG", "SUNK" )
	Insert Into remap Values ( "IN",   "HIN", "HINT" )
	Insert Into remap Values ( "IN",   "MIN", "MEAN" )
	Insert Into remap Values ( "IN",   "NIN", "LEAN" )
	Insert Into remap Values ( "IN",   "MUN", "MOON" )
	Insert Into remap Values ( "EE",   "MEE", "MEAN" )
	Insert Into remap Values ( "EE",   "LEE", "LAY" )
	Insert Into remap Values ( "ING",  "CHING", "CHAIN" )
	Insert Into remap Values ( "ING",  "NING", "LINK" )
	Insert Into remap Values ( "ING",  "LING", "LINK" )
	Insert Into remap Values ( "ING",  "MING", "MAIN" )
	Insert Into remap Values ( "ONG",  "KWONG", "GONE" )
	Insert Into remap Values ( "ONG",  "TONG", "TOM" )
	Insert Into remap Values ( "ONG",  "KONG", "GONE" )
	Insert Into remap Values ( "ON",   "BON", "BOMB" )
	Insert Into remap Values ( "ONG",  "BONG", "BOMB" )
	Insert Into remap Values ( "ONG",  "WONG", "WARM" )
	Insert Into remap Values ( "UN",   "KWUN", "KOON" )
	Insert Into remap Values ( "UN",   "NUN", "LUNG" )
	Insert Into remap Values ( "UK",   "LUK", "LOOK" )
	Insert Into remap Values ( "UK",   "KUK", "COOK" )
	Insert Into remap Values ( "UNG",  "CHUNG", "JONE" )		&& LUNG, LOAN
	Insert Into remap Values ( "UNG",  "SUNG", "ZONE" )
	Insert Into remap Values ( "UNG",  "KUNG", "CONE" )
	Insert Into remap Values ( "UNG",  "TUNG", "TONE" )		&& TONE, DONT
	Insert Into remap Values ( "UNG",  "FUNG", "PHONE" )
	Insert Into remap Values ( "OI",   "OI", "OIL" )
	Insert Into remap Values ( "OI",   "LOI", "LOY" )
	Insert Into remap Values ( "OI",   "SOI", "SOIL" )
	Insert Into remap Values ( "OI",   "KOI", "COIL" )
	Insert Into remap Values ( "OI",   "TSOI", "CHOI" )
	Insert Into remap Values ( "AAI",  "AI", "EYE" )
	Insert Into remap Values ( "AI",   "AI", "EYE" )
	Insert Into remap Values ( "AI",   "KWAI", "QUITE" )
	Insert Into remap Values ( "AI",   "DAI", "DIE" )
	Insert Into remap Values ( "AI",   "TAI", "TIE" )
	Insert Into remap Values ( "AI",   "WAI", "RIGHT" )
	Insert Into remap Values ( "AI",   "LAI", "LIKE" )		&& LIE, LIKE
	Insert Into remap Values ( "AI",   "SAI", "SITE" )
	Insert Into remap Values ( "AI",   "MAI", "MIND" )
	Insert Into remap Values ( "AI",   "KAI", "GUY" )
	Insert Into remap Values ( "AI",   "FAI", "FINE" )
	Insert Into remap Values ( "AI",   "HAI", "HIGH" )
	Insert Into remap Values ( "SI",   "SI", "SEE" )
	Insert Into remap Values ( "LI",   "LI", "LAY" )
	Insert Into remap Values ( "A",    "WA", "WAH" )
	Insert Into remap Values ( "IU",   "YIU", "YIELD" )
	Insert Into remap Values ( "IU",   "LIU", "NEW" )
	Insert Into remap Values ( "IU",   "SIU", "SILL" )
	Insert Into remap Values ( "IU",   "TIU", "TILL" )
	Insert Into remap Values ( "IU",   "KIU", "KILL" )
	Insert Into remap Values ( "IU",   "SHIU", "SILL" )
	Insert Into remap Values ( "IU",   "HIU", "HILL"  )
	Insert Into remap Values ( "IU",   "GIU", "GILL" )
	Insert Into remap Values ( "IU",   "MIU", "MILL" )
	Insert Into remap Values ( "IU",   "CHIU", "CHEW" )
	Insert Into remap Values ( "AO",   "TAO", "THOUGH" )
	Insert Into remap Values ( "AO",   "DAO", "THOUGH" )
	Insert Into remap Values ( "AO",   "MAO", "MODE" )
	Insert Into remap Values ( "A",    "TA", "TAR" )
	Insert Into remap Values ( "A",    "KA", "CAR" )
	Insert Into remap Values ( "A",    "CHA", "CHAR" )
	Insert Into remap Values ( "A",    "SA", "CZAR" )
	Insert Into remap Values ( "A",    "KWA", "GRA" )
	Insert Into remap Values ( "EI",   "LEI", "LAY" )
	Insert Into remap Values ( "EI",   "SEI", "SAY" )
	Insert Into remap Values ( "AK",   "TAK", "DUCK" )
	Insert Into remap Values ( "UE",   "YUE", "YU" )
	Insert Into remap Values ( "EH",   "YEH", "YEAH" )
	Insert Into remap Values ( "AAK",  "AAK", "ARK" )
	Insert Into remap Values ( "EUK",  "LEUK", "LURK" )
	Insert Into remap Values ( "IC",   "LIC", "LEG" )
	Insert Into remap Values ( "IC",   "VIC", "WAKE" )
	Endproc
Enddefine

Define Class MyFrmQuit As Form
	Caption="Quit"
	Height=90
	Width=150
	AutoCenter=.T.
	ControlBox=.F.
	BorderStyle=2
	** modal, in form
	WindowType=1
	ShowWindow=1
	oQuit=.F.

	Add Object btnYes As MyCommandButton With ;
		top=10,Left=20,Caption="\<Yes",ForeColor=RGB(255,0,0), ;
		Cancel=.T.
	Add Object btnNo As MyCommandButton With ;
		top=50,Left=20,Caption="\<No"
	Add Object btnReturn As MyCommandButton With ;
		top=90,Left=20,Caption="\<Back to VFP", ;
		ForeColor=RGB(255,128,0), visible=.f.

	Procedure btnNo.Click()
		Thisform.oQuit.toquit="N"
		This.parent.Release()
	Endproc

	Procedure btnYes.Click()
		* default thisform.oQuit.toquit is "X"
		This.parent.Release()
	Endproc

	Procedure btnReturn.Click()
		Thisform.oQuit.toQuit="Y"
		This.parent.Release()
	Endproc

	Procedure Init
	Lparameter loParam
		This.oQuit=loParam
		This.oQuit.toquit="X"
		if _vfp.StartMode<>4
			This.Height=This.Height+40
			This.btnReturn.visible=.t.
		endif
		this.btnNo.Setfocus()
	Endproc
Enddefine

Define Class myParam As Custom
	toquit="X"
Enddefine

Procedure makecantontxt
Clear All
Close All
Clear
Set Talk Off
Set Safety Off
Set Alternate To canton.txt
Set Alternate On
Select 0
Use (_screen.cantondbf) Noupdate
?? "/s a"
for m.ii=1 to 26
	locate for thekey="BIG"+chr(asc("A")+m.ii-1)
	?? canton.big5
endfor
? "MYNICK", "±i°O"
m.maxlen=0
Select Distinct thekey From canton ;
	where !Empty(thekey) ;
	into Cursor t_thekey
Scan
	If Len(Alltrim(thekey)) > m.maxlen
		m.maxlen=Len(Alltrim(thekey))
	Endif
	? Alltrim(thekey)
	Select canton
	Scan For thekey=t_thekey.thekey
		?? Space(1)+Alltrim(canton.big5)
	Endscan
Endscan
Use In t_thekey
Use In canton

Set Alternate Off
Set Alternate To

? "maximum length:",m.maxlen

Set Talk On
Set Safety On
Endproc

function cleancrlf
	lparameter m.xx
return strtran(strtran(m.xx,chr(K_ENTER),""),chr(K_LF),"")

function floatpnt
parameter m.in_prce, m.in_wid, m.in_dec
*
* copied from WAE's PROCEDR2.PRG
*
* m.in_prce = the floating point value
* m.in_wid  = the output width
* m.in_dec  = the maximum precision of m.in_prce
*
* 25/09/01 - MMC, created. beware of the limits...
*
* you can use the following to re-test this function
* set decimal to 5
* for m.ii=0 to 7
*   for m.jj=1 to 5
*     m.vv=10**m.ii+1/10**m.jj
*     ? m.ii, floatpnt(m.vv,7), floatpnt(-m.vv,7)
*   endfor
* endfor
*
private m.prce, m.wid, m.dec
private M.ss, m.xx, o_dec

if m.in_wid-m.in_dec<2
  * you need at least "0.", and "-" sign
  return "I CANT"
endif

o_dec=set("decimal")
set decimal to m.in_dec

m.dec=m.in_dec
m.prce=abs(m.in_prce)
m.wid=m.in_wid
if m.in_prce<0
  m.wid=m.wid-1
endif
if m.wid-m.dec<2
  * "0." has 2 places at least
  m.dec=m.dec-1
endif

m.ss=str(m.prce,15,m.dec)
if m.prce>10**(m.wid-1)
  * the recursive call here is pretty useless. but...
  m.ss=str(m.prce/1000,15)+"K"
else
  * check the width of the part before decimal point
  * trim the mantissa accordingly
  if m.prce<=1
    m.xx=m.dec
  else
    m.xx=m.wid-(int(log10(m.prce))+1)-1
    if m.xx<=0
      m.xx=0
    endif
  endif
  m.ss=str(m.prce,15,m.xx)
endif
m.ss=alltrim(right(m.ss,m.wid))
if m.in_prce<0
  m.ss="-"+m.ss
endif
* removing trailing decimal zero
if "."$m.ss
  do while right(m.ss,1)="0"
    m.ss=left(m.ss,len(m.ss)-1)
  enddo
  if right(m.ss,1)="."
    m.ss=left(m.ss,len(m.ss)-1)
  endif
  if val(m.ss)=0
    m.ss="0"
  endif
endif
set decimal to &o_dec
return padl(m.ss,m.in_wid)

function kissed_mask
lparameter m.touched
local m.xx, m.lng
m.lng=6
if m.touched>val(replicate("9",m.lng))
	m.touched=val(replicate("9",m.lng))
endif
return transform(m.touched,replicate("9",m.lng))

function BrowseTo
lparameter m.lcTarget
local m.lcMail
DECLARE INTEGER ShellExecute ;
	    IN SHELL32.DLL ;
	    INTEGER nWinHandle,;
	    STRING cOperation,;
	    STRING cFileName,;
	    STRING cParameters,;
	    STRING cDirectory,;
	    INTEGER nShowWindow
ShellExecute(0,"open",m.lcTarget,"","",1)
clear dlls ShellExecute
return .t.

FUNCTION FirstInstance(pMutex)    && pMutex=Program name
local m.ok

   DECLARE INTEGER CreateMutex IN WIN32API INTEGER, INTEGER, STRING @
   DECLARE INTEGER CloseHandle IN WIN32API INTEGER
   DECLARE INTEGER GetLastError IN WIN32API
   _screen.MutexHandle=CreateMutex(0, 1, @pMutex)
   m.ok=(GetLastError() <> ERROR_MUTEX_EXISTS)
   clear dlls "CreateMutex", "CloseHandle", "GetLastError"
   return  m.ok
ENDFUNC

FUNCTION CloseMutex
  DECLARE INTEGER ReleaseMutex IN kernel32 INTEGER hMutex
  DECLARE INTEGER CloseHandle IN WIN32API INTEGER
  ReleaseMutex(_screen.MutexHandle)  
  CloseHandle(_screen.MutexHandle)
  clear dlls ReleaseMutex, CloseHandle
endproc

function pastebig5
lparameter m.mthd, m.u8char, m.b5char
*
* http://vcpptips.wordpress.com/tag/getwindowthreadprocessid/
* http://www.news2news.com/vfp/?function=390
* http://www.news2news.com/vfp/?example=371&function=392
*
*|typedef struct tagGUITHREADINFO {
*|    DWORD cbSize;       0:4
*|    DWORD flags;        4:4
*|    HWND hwndActive;    8:4
*|    HWND hwndFocus;     12:4
*|    HWND hwndCapture;   16:4
*|    HWND hwndMenuOwner; 20:4
*|    HWND hwndMoveSize;  24:4
*|    HWND hwndCaret;     28:4
*|    RECT rcCaret;       32:16
*|} GUITHREADINFO, *PGUITHREADINFO; total 48 bytes
*
*
LOCAL cBuffer, m.haha, m.ii
LOCAL lnThreaddId, ln_my_window, ln_current_window, ln_window_count, lc_window_title

IF EMPTY(m.mthd)
	m.mthd=2
endif

	DECLARE INTEGER GetActiveWindow ;
	   IN win32api
	DECLARE INTEGER GetWindow ;
	   IN win32api ;
	   INTEGER ncurr_window_handle, ;
	   INTEGER ndirection
    DECLARE INTEGER GetWindowText IN user32;
            INTEGER hwnd, STRING @lpString, INTEGER cch    
	DECLARE LONG IsWindowVisible IN "user32" LONG HWND

	DECLARE INTEGER SetForegroundWindow ;
		IN user32 ;
		INTEGER hwnd

	DECLARE INTEGER BlockInput IN user32 INTEGER fBlockIt

	DECLARE SHORT VkKeyScan IN user32;
	    INTEGER ch
	DECLARE keybd_event IN user32;
	    SHORT bVk,;
	    SHORT bScan,;
	    INTEGER dwFlags,;
	    INTEGER dwExtraInfo
	DECLARE Sleep IN kernel32 INTEGER dwMilliseconds

	DECLARE SHORT PostMessage IN user32;
	    INTEGER   hWnd,;
	    INTEGER   Msg,;
	    INTEGER   wParam,;
	    STRING   lParam

	DECLARE INTEGER GetWindowThreadProcessId IN user32;
	    INTEGER   hWnd,;
	    INTEGER @ lpdwProcId

    DECLARE INTEGER GetGUIThreadInfo IN user32;
        INTEGER idThread, STRING @lpgui

    DECLARE INTEGER GetLastError IN kernel32

	DECLARE INTEGER GetClassName IN user32;
	    INTEGER   hWnd,;
	    STRING  @ lpClassName,;
	    INTEGER   nMaxCount

#ifdef debug_caret
set console off
set alternate to z:\debug.txt
set alternate on
#endif

ln_my_window=GetActiveWindow()
ln_current_window=ln_my_window
ln_window_count=0
DO WHILE ln_current_window>0
	lc_window_title=GetWindowCaption(ln_current_window)
	#ifdef debug_caret
	? "window", ln_window_count, ": ", ln_current_window, lc_window_title
	#endif
	IF !EMPTY(lc_window_title)
		do case
			case upper(lc_window_title)="START"
			case IsWindowVisible(ln_current_window) = 0
			otherwise
				ln_window_count=ln_window_count+1
				if ln_window_count=2
					* got the previous window in z-order
					BlockInput(1)
					SetForegroundWindow(ln_current_window)
					Sleep(30)
					lnThreadId=GetWindowThreadProcessId(ln_current_window, 0)
					#ifdef debug_caret
						? "window", ln_current_window, "thread", lnThreadId
					#endif
					cBuffer = Chr(GUITHREADINFO_SIZE) + Repli(Chr(0), GUITHREADINFO_SIZE-1)
	 				IF GetGUIThreadInfo(lnThreadId, @cBuffer) = 0
	 				   messagebox("GetGUIThreadInfo() Error: "+GetLastError(),16)
					ELSE
						m.haha = wnd(cBuffer, 13, "Window in focus")
						#ifdef debug_caret
						? "cBuffer", transform(cBuffer, "@0"), m.haha
						#endif
						do case
							case m.mthd=1
								* SendMessage(m.haha, EM_SETSEL, 0, 0)
								DECLARE INTEGER SendMessageW IN user32 as SendStrW;
								    INTEGER hWnd,;
								    INTEGER Msg,;
								    INTEGER wParam,;
								    STRING lParam
								m.u8char=ALLTRIM(m.u8char)+CHR(0)
								SendStrW(m.haha, EM_REPLACESEL, len(m.u8char), m.u8char)
							case m.mthd=2
								* to clipboard for VFP9; VFP6, already clipped
								if left(version(4),2)>"06"									
									ClipUTF16Text(strconv(m.u8char,12))
								endif
								PostMessage(m.haha, WM_PASTE, 0, 0)
							case m.mthd=3
								#ifdef debug_caret
								? "using keybd_event(control+v)"
								#endif
								* working
								* send CONTROL+V by keybd_event()
								 _cliptext=ALLTRIM(m.b5char)
								sendkey(VK_CONTROL, 0)
								sendkey(asc("V"), 0)
								sendkey(asc("V"), KEYEVENTF_KEYUP)
								sendkey(VK_CONTROL, KEYEVENTF_KEYUP)
							case m.mthd=4
								#ifdef debug_caret
								? "using keybd_event(big5)"
								#endif
								m.b5char=ALLTRIM(m.b5char)
								sendkey(asc(left(m.b5char,1)), 0)
								sendkey(asc(left(m.b5char,1)), KEYEVENTF_KEYUP)
								sendkey(asc(right(m.b5char,1)), 0)
								sendkey(asc(right(m.b5char,1)), KEYEVENTF_KEYUP)
							otherwise
								messagebox("pastebig5() not working!")
	 					endcase
					ENDIF
					SetForegroundWindow(ln_my_window)
					BlockInput(0)
					exit
				endif
		endcase
	ENDIF
	ln_current_window=GetWindow(ln_current_window,GW_HWNDNEXT)
ENDDO

clear dlls

#ifdef debug_caret
set alternate off
set alternate to
set console on
#endif
return

function sendkey
lparameter m.vk, m.flag
	keybd_event(m.vk, 0, m.flag, 0)
	Sleep(15)
return

function wnd
lparameter cBuffer, lnOffs, lcTitle
local hWindow, lcCaption
    hWindow = buf2dword(SUBSTR(cBuffer, lnOffs,4))
    lcCaption = GetWindowCaption(hWindow)
#ifdef debug_caret
=ins(lcTitle, LTRIM(STR(hWindow)) + ", [" + GetClsName(hWindow) + "]")
#endif    
return hWindow
 
PROCEDURE ins(cTitle, cValue)
	? m.cTitle, m.cValue
RETURN

FUNCTION buf2dword(lcBuffer)
RETURN Asc(SUBSTR(lcBuffer, 1,1)) + ;
    BitLShift(Asc(SUBSTR(lcBuffer, 2,1)),  8) +;
    BitLShift(Asc(SUBSTR(lcBuffer, 3,1)), 16) +;
    BitLShift(Asc(SUBSTR(lcBuffer, 4,1)), 24)
 
FUNCTION GetWindowCaption(lnWindow)
LOCAL lnLength, lcText
    lcText = SPACE(250)
    lnLength = GetWindowText(lnWindow, @lcText, Len(lcText))
RETURN iif(lnLength>0, Left(lcText, lnLength), space(1))

Function GetClsName
lParameter ln_current_window
local cBuffer, nBufSize
cBuffer = Repli(Chr(0), 250)
nBufsize = GetClassName(ln_current_window, @cBuffer, Len(cBuffer))
return SUBSTR(cBuffer, 1, nBufsize)

*
* http://www.berezniker.com/content/pages/visual-foxpro/copy-unicode-text-clipboard
*
* Copy Unicode text into Clipboard
FUNCTION ClipUTF16Text(tcUnicodeText)
LOCAL lnDataLen, lcDropFiles, llOk, i, lhMem, lnPtr, lcUnicodeText
#DEFINE CF_UNICODETEXT  13
 
*  Global Memory Variables with Compile Time Constants
#DEFINE GMEM_MOVABLE 	0x0002
#DEFINE GMEM_ZEROINIT	0x0040
#DEFINE GMEM_SHARE		0x2000
 
* Load required Windows API functions
*  Clipboard Functions
DECLARE LONG OpenClipboard IN WIN32API LONG HWND
DECLARE LONG CloseClipboard IN WIN32API
DECLARE LONG EmptyClipboard IN WIN32API
DECLARE LONG SetClipboardData IN WIN32API LONG uFormat, LONG hMem
*  Memory Management Functions
DECLARE LONG GlobalAlloc IN WIN32API LONG wFlags, LONG dwBytes
DECLARE LONG GlobalFree IN WIN32API LONG HMEM
DECLARE LONG GlobalLock IN WIN32API LONG HMEM
DECLARE LONG GlobalUnlock IN WIN32API LONG HMEM
DECLARE LONG RtlMoveMemory IN WIN32API As CopyFromStr LONG lpDest, String @lpSrc, LONG iLen
 
llOk = .F.
lcUnicodeText = tcUnicodeText + CHR(0)+CHR(0)
lnDataLen = LEN(lcUnicodeText)
* Copy Unicode text into the allocated memory
lhMem = GlobalAlloc(GMEM_MOVABLE+GMEM_ZEROINIT+GMEM_SHARE, lnDataLen)
lnPtr = GlobalLock(lhMem)
=CopyFromStr(lnPtr, @lcUnicodeText, lnDataLen)
=GlobalUnlock(lhMem)
* Open clipboard and store Unicode text into it
llOk = (OpenClipboard(0) <> 0)
IF llOk
	=EmptyClipboard()
	llOk = (SetClipboardData(CF_UNICODETEXT, lhMem) <> 0)
	* If call to SetClipboardData() is successful, the system will take ownership of the memory
	* otherwise we have to free it
	IF NOT llOk
		=GlobalFree(lhMem)
	ENDIF
	* Close clipboard
	=CloseClipboard()
ENDIF
clear dlls OpenClipboard, CloseClipboard, EmptyClipboard, SetClipboardData
clear dlls GlobalAlloc, GlobalFree, GlobalLock, GlobalUnlock, RtlMoveMemory
RETURN llOk

*
* http://blogs.lessthandot.com/index.php/datamgmt/datadesign/displaying-and-saving-unicode-data/
*
*!*	In the form¡¦s Load we need the following:
*!*	Sys(987,.F.)
*!*	Sys(3101,65001)
*!*	Then, after getting binary data from SQL Server the same way as I show in this blog, 
*!*   we still need to use createbinary, e.g.
*!*	this.txtLanguage.text = createbinary(prefs_sl.Language00)
*!*	We don¡¦t want to use COMPROP now for the ActiveX.
*!*	and then, saving data, we need to follow Rick¡¦s steps:
*!*	pcSavedText1 = Strconv(This.Text,12)
*!*	*** Must explicitly force to binary ¡V can also use CAST in 9.0
*!*	pcSavedText1 = CREATEBINARY(pcSavedText1)

*
* http://www.news2news.com/vfp/?example=88
*
FUNCTION ToBase64(cSrc)
    LOCAL nFlags, nBufsize, cDst
    nFlags=CRYPT_STRING_BASE64

    DECLARE INTEGER CryptBinaryToString IN Crypt32;
        STRING @pbBinary, LONG cbBinary, LONG dwFlags,;
        STRING @pszString, LONG @pcchString
 
    DECLARE INTEGER CryptStringToBinary IN crypt32;
        STRING @pszString, LONG cchString, LONG dwFlags,;
        STRING @pbBinary, LONG @pcbBinary,;
        LONG pdwSkip, LONG pdwFlags 
    nBufsize=0
    = CryptBinaryToString(@cSrc, LEN(cSrc),;
        m.nFlags, NULL, @nBufsize)
     cDst = REPLICATE(CHR(0), m.nBufsize)
    IF CryptBinaryToString(@cSrc, LEN(cSrc), m.nFlags,;
        @cDst, @nBufsize) = 0
        RETURN ""
    ENDIF

    clear dlls
RETURN cDst

FUNCTION FromBase64(cSrc)
    LOCAL nFlags, nBufsize, cDst
    nFlags=CRYPT_STRING_BASE64

    DECLARE INTEGER CryptBinaryToString IN Crypt32;
        STRING @pbBinary, LONG cbBinary, LONG dwFlags,;
        STRING @pszString, LONG @pcchString
 
    DECLARE INTEGER CryptStringToBinary IN crypt32;
        STRING @pszString, LONG cchString, LONG dwFlags,;
        STRING @pbBinary, LONG @pcbBinary,;
        LONG pdwSkip, LONG pdwFlags
 
    nBufsize=0
    = CryptStringToBinary(@cSrc, LEN(m.cSrc),;
        nFlags, NULL, @nBufsize, 0,0)
 
    cDst = REPLICATE(CHR(0), m.nBufsize)
    IF CryptStringToBinary(@cSrc, LEN(m.cSrc),;
        nFlags, @cDst, @nBufsize, 0,0) = 0
        RETURN ""
    ENDIF
    clear dlls
RETURN m.cDst
 
FUNCTION tbsave
   *
   * save the settings
   *
   PUBLIC ARRAY gaTBSets[12, 2]
   *
   LOCAL lnCntr
   *
   *-- Fill an array with toolbar names.
   *
   gaTBSets[ 1, 1] = "Color Palette"
   gaTBSets[ 2, 1] = "Database Designer"
   gaTBSets[ 3, 1] = "Form Controls"
   gaTBSets[ 4, 1] = "Form designer"
   gaTBSets[ 5, 1] = "Layout"
   gaTBSets[ 6, 1] = "Print Preview"
   gaTBSets[ 7, 1] = "Query Designer"
   gaTBSets[ 8, 1] = "Report Controls"
   gaTBSets[ 9, 1] = "Report Designer"
   gaTBSets[10, 1] = "Standard"
   gaTBSets[11, 1] = "View Designer"
   gaTBSets[12, 1] = "Properties"
   *
   *-- Check toolbars for their visibility
   *-- If so, store that setting in the 2nd column.
   *-- and hide the toolbar
   *
   _SCREEN.LOCKSCREEN = .T.
   FOR lnCntr = 1 TO ALEN(gaTBSets,1)
      IF WEXIST( gaTBSets[lnCntr,1] )
         gaTBSets[ lnCntr,2 ] = .T.
         HIDE WINDOW (gaTBSets[lnCntr,1])
      ELSE
         gaTBSets[ lnCntr,2 ] = .F.
      ENDIF
   ENDFOR
   _SCREEN.LOCKSCREEN = .F.
   *
ENDFUNC

FUNCTION TBRest
   *
   *-- Make the toolbars visible that are stored as previously visible in the gaTBSets array
   *
   LOCAL lnCntr
   *
   _SCREEN.LOCKSCREEN = .T.
   FOR lnCntr = 1 TO ALEN( gaTBSets ,1 )
      IF gaTBSets[ lnCntr, 2 ]
         SHOW WINDOW ( gaTBSets[ lnCntr, 1 ] )
      ENDIF
   ENDFOR
   _SCREEN.LOCKSCREEN = .F.
ENDFUNC

Function UniqueFname
lParameter m.suffix
* Using sys(3) will need some delay between each call
if empty(m.suffix)
	m.suffix="tmp"
endif
return sys(2023)+"\"+SUBSTR(SYS(2015), 3, 10)+"."+m.suffix

function MySleep
lParameter m.msec
local m.xx
	DECLARE Sleep IN kernel32 INTEGER dwMilliseconds
	m.xx=sleep(m.msec)
	clear dlls
return m.xx


Function isDLLAvailable(DllFilename)
	*
	* usage: ?isDLLAvailable('fm20.dll')
	* http://www.tek-tips.com/faqs.cfm?fid=6069
	*
    Local hModule

	Declare Integer LoadLibrary In kernel32;
    	STRING lpLibFileName

	Declare Integer FreeLibrary In kernel32;
    	INTEGER hLibModule

    hModule = LoadLibrary(DllFilename)
    If hModule > 32 
        FreeLibrary(hModule)
        lRetval = .T.
    Else
        lRetVal = .F.
    ENDIF

	CLEAR DLLs

    RETURN lRetVal
Endfunc

Function VFP6CopyUnicode
lParameter m.utf8
local nResult
strtofile(m.utf8, _screen.txtname)
nResult = LaunchExeAndWait(_screen.clipbatname,sys(2023),"HIDE")
return nResult

Function VFP6EncodeUTF8
local nResult
nResult = LaunchExeAndWait(_screen.encdbatname,sys(2023),"HIDE")
return left(filetostr(_screen.outname),4)

FUNCTION LaunchExeAndWait
LPARAMETERS pcCommandLine, puFromDir, pcWindowMode
*
* Source: 
* https://social.msdn.microsoft.com/Forums/en-US/9f663558-56ab-4bda-9d4c-2f966979356c/shellexecute-to-launch-vfp-app-from-another-vfp-app?forum=visualfoxprogeneral
* http://fox.wikis.com/wc.dll?Wiki~ProcessExitCode
*
*	pcCommandLine			(R) - command line to launch
*	puFromDir				(O) - Run from directory (default - CWD)
*	pcWindowMode			(O)	- Start Application Window mode, one of (HIDE, MIN, MAX, NOR)
*								  (default - default setting of application)

*	Returns:
*	0 = CreateProcess didn't start what was asked
*	1 = Process ran to completion
*	-1= Process started but user aborted wait.  Danger - app is still running AFAIK

#DEFINE cnINFINITE 		0xFFFFFFFF
#DEFINE cnPollKeyboard	3			&& milliseconds
#DEFINE cnTimedOut		0x0102

*	We need some API calls, declare here

*	GetCurrentProcess() returns the pseudohandle of the current process
DECLARE INTEGER GetCurrentProcess IN WIN32API AS GetCurrProc

*	WaitForIdleInput() waits until the target process is idle for input
DECLARE INTEGER WaitForInputIdle IN WIN32API AS WaitInpIdle ;
	INTEGER nProcessHandle, ;
	INTEGER nWaitForDuration

*	WaitForSingleObject() waits until the handle in parm 1 is signalled 
*	or the timeout period expires
DECLARE INTEGER WaitForSingleObject IN WIN32API AS WaitOnAppExit ;
	INTEGER hProcessHandle, ;
	INTEGER dwTimeOut

DECLARE INTEGER GetExitCodeProcess in win32api ;
  INTEGER hProcess, INTEGER @ nExitCode

*	This API call does the work.  The parameters are as follows:
*		lpszModuleName - ptr-> file name of module to execute.  Since we aren't launching .CPLs, do not use
*		lpszCommandLine - ptr-> command to execute, as passed to us
*		lpSecurityAttributesProcess - ptr-> SECURITY_ATTRIBUTES structure for Process.  Pass a null pointer
*		lpSecurityAttributesThread - ptr-> SECURITY_ATTRIBUTES structure for first thread.  Pass a null pointer
*		bInheritHandles - whether or not chlid inherits parent handles.  Since no SECURITY_ATTRIBUTES passed, default to FALSE
*		dwCreateFlags - Process Creation Mode flag set.  We use the default mode at normal priority, ie 0
*		lpvEnvironment	- ptr-> a set of environment strings as if a MULTI_SZ.  We don't set, so pass a null pointer
*		lpszStartupDir - ptr-> the starting directory.  If none provided to us, pass a null pointer
*		lpStartInfo - ptr-> a STARTUPINFO structure.  We use one structure member at times.
*		lpProcessInfo - ptr-> a PROCESS_INFORMATION structure, used to return PID/PHANDLE detail.  
*						We use one member on return
DECLARE SHORT CreateProcess IN WIN32API AS CrPr ;
	STRING lpszModuleName, ;
	STRING @lpszCommandLine, ;
	STRING lpSecurityAttributesProcess, ;
	STRING lpSecurityAttributesThread, ;
	SHORT bInheritHandles, ;
	INTEGER dwCreateFlags, ;
	STRING lpvEnvironment, ;
	STRING lpszStartupDir, ;
	STRING @lpStartInfo, ;
	STRING @lpProcessInfo

IF TYPE('pcCommandLine') # 'C'
	*	Command line must be a character string
	RETURN 0
ENDIF

IF TYPE('puFromDir') # 'C'
	*	If not a character string, pass a null pointer, defaulting to Current Working Dir
	puFromDir = 0
ELSE
	*	Otherwise, null pad the string
	puFromDir = puFromDir + CHR(0)
ENDIF

IF TYPE('pcWindowMode') # 'C'
	*	If not passed, set to null string
	pcWindowMode = ''
ELSE
	*	Translate the passed window mode to uppercase
	pcWindowMode = UPPER(pcWindowMode)
ENDIF

LOCAL nStartedProcessHandle, uResult, cProcessInfo, cStartUpInfo

*	Make default Structures for the CreateProcess call
*
*	ProcessInfo - 4 bytes, a Process handle, a Thread Handle, a (DWORD) ProcessId and a (DWORD) ThreadID
*					we save the Process handle and return it to caller in tnReturnProcessHandle

cProcessInfo = REPL(CHR(0),16)

*	StartUpInfo is a 68 byte long complex structure;  we either have 68 bytes with a cb member (byte 1) 68
*	or with cb of 68, dwFlag low order byte (byte 45) of 1, and low order byte wShowWindow (byte 49) set to
*	the SW_ value appropriate for the Window Mode desired.

DO CASE
CASE pcWindowMode = 'HIDE'

	*	Hide - use STARTF_USESHOWFLAG and value of 0
	cStartUpInfo = CHR(68) + ;
					REPL(CHR(0),43) + ;
					CHR(1) + ;
					REPL(CHR(0),23)

CASE pcWindowMode = 'NOR'

	*	Normal - use STARTF_USESHOWFLAG and value of 1
	cStartUpInfo = CHR(68) + ;
					REPL(CHR(0),43) + ;
					CHR(1) + ;
					REPL(CHR(0),3) + ;
					CHR(1) + ;
					REPL(CHR(0),19)

CASE pcWindowMode = 'MIN'

	*	Minimize - use STARTF_USESHOWFLAG and value of 2
	cStartUpInfo = CHR(68) + ;
					REPL(CHR(0),43) + ;
					CHR(1) +  ;
					REPL(CHR(0),3) + ;
					CHR(2) + ;
					REPL(CHR(0),19)

CASE pcWindowMode = 'MAX'

	*	Maximize - use STARTF_USESHOWFLAG and value of 3
	cStartUpInfo = CHR(68) + ;
					REPL(CHR(0),43) + ;
					CHR(1) +  ;
					REPL(CHR(0),3) + ;
					CHR(3) + ;
					REPL(CHR(0),19)
					
*	Other options exist - see WINBASE.H for values
OTHERWISE

	*	Use default of application
	cStartUpInfo = CHR(68) + REPL(CHR(0),67)

ENDCASE

*	Do it now!
uResult = CrPr(	0, ;
				pcCommandLine, ;
				0, 0, 0, 0, 0, ;
				puFromDir, ;
				@cStartUpInfo, ;
				@cProcessInfo)
IF uResult > 0
	*	CreateProcess() started our app, but we have to wait until it finishes loading
	*	Strip the process handle from the PROCESS_INFORMATION structure
	nStartedProcessHandle = (((ASC(SUBST(cProcessInfo,4,1))*256) + ;
								ASC(SUBST(cProcessInfo,3,1)))*256 + ;
								ASC(SUBST(cProcessInfo,2,1)))*256 + ;
								ASC(LEFT(cProcessInfo,1))
	*	It's been launched;  wait until we're idling along
	=WaitInpIdle(GetCurrProc(),cnINFINITE)
	*	As long as the other process exists, wait for it
	DO WHILE WaitOnAppExit(nStartedProcessHandle, cnPollKeyboard) = cnTimedOut
		*	Give us an out in case the other app hangs - lets the user quit via <Esc>
		IF INKEY() = K_ESC
			*	Still running but we aren't waiting - return a -1 as a warning
			uResult = -1
			EXIT
		ENDIF
	ENDDO
ENDIF
clear dlls
RETURN uResult

#ifdef haha
procedure readhkscs2008
set talk off
set exact on

clear all
close all
local m.raw, m.ii, m.jj, m.yy, m.xx, m.kk, m.raw1, m.raw2

clear

set console on
set alternate to cj.txt
set alternate on

select 0
use data\canton shared

m.xx=fopen("Z:\aroot\Visual FoxPro Projects\canton\tables\CJ-HKSCS-2008.txt")
do while !feof(m.xx)
	m.yy=fgets(m.xx)
	m.ii=at("=",m.yy)
	if m.ii > 0
		m.changjei=left(m.yy,m.ii-1)
		m.raw=right(m.yy, len(m.yy)-m.ii)
		do while len(m.raw)>=3
			m.raw1=left(m.raw,3)
			checkdb(m.raw1, m.changjei)
			* remove ","
			m.raw=substr(m.raw,5,len(m.raw)-4)
		enddo
	endif
enddo
fclose(m.xx)
use

set alternate off
set alternate to
set console on

close all
clear all

set exact off
set talk on
return

function checkdb
lparameter m.raw, m.changjei
local m.uncd, m.big5
	m.uncd=strconv(m.raw,13)
	m.big5=strconv(m.raw,11)
	select canton
	locate for uncd=m.uncd
	if found()
		select canton
		if empty(canton.thekey)
			replace thekey with "UNICODE"
		endif
		if empty(canton.changjei) or canton.changjei<>m.changjei
			replace changjei with m.changjei
		endif
	else
		m.thekey=""
		if "?"$m.big5
			m.thekey="UNICODE"
		endif
		insert into canton ( ;
			uncd, big5, thekey, changjei ;
		) values ( ;
			m.uncd, m.big5, m.thekey, m.changjei ;
		)
	endif
return .t.

Procedure readchangjei
Select 0
Use (_screen.cantondbf) Shared
Create Cursor t_changjei ( ;
	filler c(4),;
	big5 c(2),;
	radical c(3),;
	stroke c(3),;
	changjei c(10),;
	found c(1);
	)
Append From changjei.txt Delimited With Tab
Scan
	Select canton
	Locate For big5=t_changjei.big5
	If Found()
		Select canton
		Replace changjei With t_changjei.changjei
	Else
		Insert Into canton ( ;
			big5, changjei ;
			) Values ( ;
			t_changjei.big5,t_changjei.changjei ;
			)
	Endif
Endscan
Select t_changjei
Brow For Empty(t_changjei.Found)
Use In t_changjei
Use In canton
Endproc

Function readcanton
If File(_screen.cantondbf)
	messagebox("CANTON.DBF already existed! Rename it.",16)
	Return .F.
Endif
Create Table canton ( thekey c(10), big5 c(2) )
Create Cursor temp ( Aline c(80) )
Append From canton.txt Type Sdf
Select temp
m.maxlen=0
Scan
	If Recno() > 2
		xx=At(" ",temp.Aline)
		kk=Left(temp.Aline,xx)
		If !Empty(m.kk)
			If Len(m.kk) > m.maxlen
				m.maxlen=Len(m.kk)
			Endif
			big5=Alltrim(Substr(temp.Aline,xx,xx+20))
			Insert Into canton Values (kk, m.big5)
		Endif
	Endif
Endscan
? "max key length=",m.maxlen
? "word count=",Reccount("canton")
Close All
Return .T.

Procedure readoldcanton
Select 0
Use (_screen.cantondbf) Shared
Select 0
Use ophrase Shared
Scan
	Replace ophrase.Found With Space(1)
	Select canton
	Locate For big5=ophrase.Code
	If Found()
		Replace canton.canton With ophrase.Sound
	Else
		Insert Into canton ( ;
			big5, canton ;
			) Values ( ;
			ophrase.Code, ophrase.Sound ;
			)
	Endif
Endscan
Use In canton
Use In ophrase
Endproc

Procedure recode
*!* 5	Converts double-byte characters to UNICODE (wide characters)
*!* 6	Converts UNICODE (wide characters) to double-byte characters.
*!*
*!*	9	Converts double-byte characters in cExpression to UTF-8
*!*	11	Converts UTF-8 characters in cExpression to double-byte characters.
*!*
*!*	10	Converts Unicode characters in cExpression to UTF-8
*!*	12	Converts UTF-8 characters in cExpression to UNICODE characters.
*!*
*!* 13	Converts single-byte characters in cExpression to encoded base64 binary.
*!* 14	Converts base64 encoded data in cExpression to original unencoded data.
*
close all
clear all
sys(3101,65001)
select 0?
use (_screen.cantondbf) shared
scan
	replace uncd with strconv(strconv(big5,9),13)
	* the opposite strconv(strconv(,14),11)
endscan
close all
clear all
return

#endif haha

parameter m.mnx
*
* DO NOT use lparameter
*
* This Visual Foxpro program convert a Foxpro menu definition file 
* (MNX) into a tile-based menu in a touch screen without extra work
* 
local loForm
loForm=createobject("PosMenu")
loForm.show()
return

define class PosMenu as form
top=0
left=0
width=710
height=500
fontsize=14
keypreview=.t.
autocenter=.t.
controlbox=.f.
backcolor=rgb(200,200,255)
borderstyle=1		&& fixed single
windowtype=1

buttonleftmargin=10
buttontopmargin=10
buttonwidth=160
buttonheight=50
buttonsep=10
levelstack=""
curlevel=""

add object cmdExit as Commandbutton with ;
top=this.height-this.buttonheight-this.buttonsep, ;
left=this.width-this.buttonwidth-this.buttonsep, ;
height=this.buttonheight, ;
width=this.buttonwidth, ;
caption="Exit", ;
fontsize=14, ;
fontbold=.t., ;
forecolor=rgb(255,255,255), ;
backcolor=rgb(255,0,0)


procedure init
	thisform.curlevel="_MSYSMENU"
	thisform.paintmenu()
endproc

procedure cmdExit.click
	this.enabled=.f.
	if thisform.curlevel="_MSYSMENU"
		thisform.clearmenu()
		if posyn("", "Â÷¶}¨t²Î?")
			* do onshutdown
			thisform.release()
		else
			thisform.clearmenu()
			thisform.paintmenu()
		endif
	else
		thisform.clearmenu()
		thisform.curlevel=thisform.poplevel()
		thisform.paintmenu()
	endif
	this.enabled=.t.
endproc

procedure paintmenu
	local m.lnButtonCnt, m.lnLeft, m.lnTop, m.prvlevel, m.ii
	m.lnButtonCnt=1
	m.lnLeft=thisform.buttonleftmargin
	m.lnTop=thisform.buttontopmargin
	m.prvlevel=thisform.stacktop()
	select 0
	use (m.mnx) noupdate alias mymenu
	if empty(m.prvlevel)
		thisform.caption="Main Menu"
	else
		* find the caption of the parnet of the current level menu
		select mymenu		
		locate for name=thisform.curlevel and objtype=2
		skip -1
		thisform.caption=alltrim(mymenu.prompt)
		m.ii=at("\<",thisform.caption)
		thisform.caption=alltrim(strtran(thisform.caption,substr(thisform.caption,m.ii,4)))
	endif
	select * from mymenu ;
		where levelname=thisform.curlevel and objtype=3 ;
		into cursor themenu
	scan
		m.lcName="cmd"+transform(m.lnButtonCnt,"@L 999")
		if themenu.prompt="\-"
			if m.lnTop<=thisform.buttontopmargin
				m.lnTop=m.lnTop-thisform.buttonheight-thisform.buttonsep
			else
				m.lnTop=thisform.height
			endif
		else
			this.addObject(m.lcName,"PosButton")
			with eval("thisform."+m.lcName)
				.disabledbackcolor=.parent.backcolor
				.objcode=themenu.objcode
				.left=m.lnLeft
				.top=m.lnTop
				.width=thisform.buttonwidth
				.height=thisform.buttonheight				
				.caption=padr(themenu.prompt,26)
				.fontbold=.t.
				if themenu.objcode=80
					.backcolor=rgb(110,210,110)
				endif
				* get the current levelname
				select mymenu
				locate for prompt=themenu.prompt
				skip
				.levelname=mymenu.levelname
				if empty(themenu.skipfor)
					.enabled=.t.
				else
					.enabled=!eval(alltrim(themenu.skipfor))
				endif
				if !empty(themenu.procedure)
					.buttonprocedure=alltrim(themenu.procedure)
				endif
				.visible=.t.
			endwith
		endif
		m.lnButtonCnt=m.lnButtonCnt+1
		m.lnTop=m.lnTop+thisform.buttonheight+thisform.buttonsep
		if m.lnTop+thisform.buttonHeight>thisform.height
			m.lnLeft=m.lnLeft+thisform.buttonwidth+thisform.buttonsep
			m.lnTop=thisform.buttontopmargin
		endif
	endscan
	if thisform.curlevel="_MSYSMENU"
		* quit
		thisform.cmdExit.caption="ESC: Â÷¶}"
	else
		* previous/back
		thisform.cmdExit.caption="ESC: ¤W¤@­¶"
	endif
	use in themenu
	use in mymenu
endproc

procedure clearmenu
local m.lcName
	create cursor t_temp ( objname c(254) ) 
	for m.ii=1 to thisform.controlcount
		with thisform.controls[m.ii]
			if upper(.class)="POSBUTTON"
				m.lcName=thisform.controls[m.ii].name
				insert into t_temp values ( m.lcName )
			endif
		endwith
	endfor
	select t_temp
	scan
		thisform.removeobject(alltrim(t_temp.objname))
	endscan
	use in t_temp
endproc

procedure pushlevel
lparameter m.lcLevel
	this.levelstack=this.levelstack+space(1)+m.lcLevel
endproc

function stacktop
local m.lnRat, m.lcLevel
	m.lnRat=rat(space(1),this.levelstack)
	if m.lnRat=0
		m.lcLevel=this.levelstack
		this.levelstack=""
	else
		m.lcLevel=substr(this.levelstack,m.lnRat+1,len(this.levelstack)-m.lnRat)
	endif
return m.lcLevel

function poplevel
local m.lnRat, m.lcLevel
	m.lnRat=rat(space(1),this.levelstack)
	if m.lnRat=0
		m.lcLevel=this.levelstack
		this.levelstack=""
	else
		m.lcLevel=substr(this.levelstack,m.lnRat+1,len(this.levelstack)-m.lnRat)
		this.levelstack=left(this.levelstack, m.lnRat-1)
	endif
return m.lcLevel

function hassubmenu
lparameter m.lcLevelName
local m.ok
	select 0
	use (m.mnx) noupdate again alias t_hassub
	locate for levelname=m.lcLevelName and objtype=3
	m.ok=found()
	use in t_hassub
return m.ok

procedure keypress
lparameter nKeyCode, nShiftAltCtrl
m.llKey=.f.
do case
	case nKeyCode<0
	case inlist(nKeyCode,27,134)
		* ESC or F12
		with thisform.cmdExit
			nodefault
			.setfocus()
			.click()
		endwith		
	case between(chr(nKeyCode),"a","z") and .f.
		nodefault
		m.llKey=.t.
	case between(chr(nKeyCode),"A","Z") and .f.
		nodefault
		m.llKey=.t.
	case between(chr(nKEyCode),"0","9") and .f.
		nodefault
		m.llKey=.t.
endcase
if m.llKey
	for m.ii=1 to thisform.controlcount
		with thisform.controls[m.ii]
			if upper(.class)="POSBUTTON"
				m.xx=at("\<",.caption)
				if m.xx > 0
					if upper(substr(.caption,m.xx+2,1))=upper(chr(nKeyCode))
						if .enabled
							.setfocus()
							.click()
							exit
						endif
					endif
				endif
			endif
		endwith
	endfor
endif
endproc

enddefine

define class PosButton as commandbutton
fontsize=10
backcolor=rgb(128,255,128)
buttonprocedure=""
objcode=0
levelname=""

procedure click
local m.ok, m.lcLine
do case
	case this.objcode=77
		* submenu
		with this.parent
			if .hassubmenu(this.levelname)
				.pushlevel(.curlevel)
				.clearmenu()
				.curlevel=this.levelname
				.paintmenu()
			endif
		endwith
	case this.objcode=80
		* procedure	
		if !empty(this.buttonprocedure)
			this.parent.visible=.f.
			for m.ii=1 to memlines(this.buttonprocedure)
				m.lcLine=mline(this.buttonprocedure,m.ii)
				&lcLine
				if "SHUTDOWN"$upper(m.lcLine)
					thisform.release()
				endif
			endfor
			this.parent.visible=.t.
		endif
endcase
endproc
enddefine

function posyn
lparameter m.lcTitle, m.lcMsg
private m.llYes
local loForm
m.llYes=.f.
loForm=createobject("frmYesNo")
loForm.show()
return m.llYes

define class frmYesNo as Form
	height=150
	width=300
	autocenter=.t.	
	WindowType=1
	keypreview=.t.
	controlbox=.f.
	caption=m.lcTitle
	borderstyle=1		&& fixed single
	add object lblMessage as Label with ;
		left=10, top=25, width=300-20, caption=m.lcMsg, ;
		alignment=2, fontsize=14, wordwrap=.t., autosize=.t.
	add object cmdYes as CommandButton with ;
		left=10, top=100, height=50, width=100, ;
		caption="\<Yes",visible=.t.
	add object cmdNo as CommandButton with ;
		left=300-110, top=100, height=50, width=100, ;
		caption="\<No",visible=.t.
procedure cmdYes.click()
	m.llYes=.t.
	thisform.release()
endproc
procedure cmdNo.click()
	thisform.release()
endproc
procedure keypress
lparameter nKeyCode, nShiftAltCtrl
do case
	case nKeyCode<0
	case upper(chr(nKeyCode))="Y"
		nodefault
		with thisform.cmdYes
			.setfocus()
			.click()
		endwith
	case upper(chr(nKeyCode))="N"
		with thisform.cmdNo
			.setfocus()
			.click()
		endwith
endcase
endproc
enddefine

function checkpass
lparameter m.xx
return .f.

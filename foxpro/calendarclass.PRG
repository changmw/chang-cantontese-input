define class cmdDow as commandbutton
	visible=.t.
	fontsize=12
	fontbold=.t.
	height=40
	tabstop=.f.

	procedure init
            if left(version(4),2)>"06"
                * CommandButton in VFP 6 does not have .backcolor!
	        this.backcolor=thisform.backcolor-10
            endif
	return .t.

	procedure when
	return .f.
enddefine

define class cntCell as container
	add object lbl as label with fontbold=.t., visible=.t., ;
		top=10, left=10, autosize=.t., backstyle=0, fontsize=16
	* customized event
	add object lblEvent as label with fontbold=.f., visible=.t., ;
		top=40, left=10, autosize=.f., backstyle=0, fontsize=10, caption="", ;
		width=70, wordwrap=.t., forecolor=rgb(255,0,0)
	specialeffect=0
	borderwidth=2
	visible=.t.
	oldBackColor=0

	procedure init
		this.oldBackColor=this.backcolor
		with this.lblEvent
			.height=.height*3
		endwith
	return .t.

	procedure click
		thisform.focusoff()
		if this.specialeffect=0
			this.specialeffect=1
			thisform.nFocus=val(right(this.name,2))
			thisform.dChoice=thisform.firstDay+thisform.nFocus
		else
			this.specialeffect=0
		endif
		* trick to refresh the border
		this.backcolor=this.backcolor
		thisform.release()
	return
	procedure lblEvent.click
		this.parent.click()
	return .t.
	procedure lbl.click
		this.parent.click()
	return .t.
enddefine

define class myCalendar as form
	add object cboMonth as combobox with ;
		left=250, top=10, style=2, rowsourcetype=1, fontsize=14, height=35
	add object cboYear as combobox with ;
		left=350, top=10, style=2, rowsourcetype=2, fontsize=14, height=35
	add object cmdPrev as commandbutton with ;
		top=100, left=720, width=75, height=90, picture="arwup.ico", wordwrap=.t.
	add object cmdNext as commandbutton with ;
		top=210, left=720, width=75, height=90, picture="arwdn.ico", wordwrap=.t.
	add object cmdToday as commandbutton with ;
		top=320, left=720, width=75, height=90, picture="today.ico", wordwrap=.t., visible=.f.
	add object cmdExit as commandbutton with ;
		top=480, left=720, width=75, height=75, picture="exit.ico", cancel=.t.

	* modal
	windowtype=1
	* in top-level form
	showwindow=0
	width=800
	height=600
	visible=.t.
	keypreview=.t.
	autocenter=.t.
	icon="calendar.ico"
	name="FRMCALENDAR"
	CellWidth=0
	CellHeight=0

	startDate={}
	minyear=0
	maxyear=0
	firstDay={}
	curDate={}
	nFocus=0
	nCursor=0
	t_year=sys(2015)
	dChoice={}

	procedure load
		create cursor (thisform.t_year) ( yr c(4) )
	return .t.

	procedure init
		lparameter m.ldDate, m.lnMinYear, m.lnMaxYear
		local m.llLockScreen
		thisform.CellWidth=thisform.height/6
		thisform.CellHeight=thisform.height/7
		if empty(m.ldDate)
			m.ldDate=date()
		endif
		thisform.startDate=m.ldDate
		if empty(m.lnMinYear)
			m.lnMinYear=year(thisform.startDate)-100
		endif
		if empty(m.lnMaxYear)
			m.lnMaxYear=year(thisform.startDate)+100
		endif
		thisform.minyear=m.lnMinYear
		thisform.maxyear=m.lnMaxYear
		thisform.curDate=thisform.startDate
		m.llLockScreen=thisform.lockscreen
		thisform.lockscreen=.t.
		thisform.relabel(.t.)
		* 2 is monday
		m.ldDate=date(1900,1,1)
		with thisform.cboMonth
			.rowsource=""
			for m.jj=0 to 11
				.rowsource=.rowsource ;
					+iif(empty(.rowsource),"",",") ;
					+cmonth(gomonth(m.ldDate,m.jj))
			endfor
			.value=month(thisform.startDate)
		endwith

		for m.jj=thisform.minYear to thisform.maxYear
			insert into (thisform.t_year) values ( transform(m.jj,"@L 9999") )
		endfor
		with thisform.cboYear
			.rowsource=thisform.t_year+".yr"
			.requery()
			.value=transform(year(thisform.startDate),"@L 9999")
		endwith

		thisform.cmdPrev.caption="PgUp:"+chr(13)+"Prev Month"
		thisform.cmdToday.caption="Home:"+chr(13)+"Today"
		thisform.cmdNext.caption="PgDn:"+chr(13)+"Next Month"
		thisform.cmdExit.caption="Esc: "+"Exit"
		thisform.caption=space(1)+"Choose Date"
		thisform.lockscreen=m.llLockScreen
	return

	procedure unload
		m.ldOutDate=thisform.dChoice
		use in (thisform.t_year)
	return thisform.dChoice

	procedure cmdExit.click
		thisform.release()
	return .t.

	procedure cmdPrev.click
		with thisform.cboMonth
			if .value=1
				if val(thisform.cboYear.value)=thisform.minyear
					return .f.
				endif
				.value=12
				thisform.cboYear.value=transform(val(thisform.cboYear.value)-1,"@L 9999")
			else
				.value=.value-1
			endif
			.interactivechange()
		endwith
	return .t.

	procedure cmdToday.click
		thisform.cboMonth.value=month(date())
		thisform.cboYear.value=transform(year(date()),"@L 9999")
		thisform.cboYear.interactivechange()
		thisform.cursoroff()
		thisform.nCursor=date()-thisform.firstday
		thisform.cursoron()
	return .t.

	procedure cmdNext.click
		with thisform.cboMonth
			if .value=12
				if val(thisform.cboYear.value)=thisform.maxyear
					return .f.
				endif
				.value=1
				thisform.cboYear.value=transform(val(thisform.cboYear.value)+1,"@L 9999")
			else
				.value=.value+1
			endif
			.interactivechange()
		endwith
	return .t.

	procedure cboMonth.interactivechange
		thisform.cursoroff()
		thisform.curDate=date(val(thisform.cboYear.value),this.value,1)
		thisform.relabel()
		thisform.cursoron()
	return .t.

	procedure cboYear.interactivechange
		thisform.cursoroff()
		thisform.curDate=date(val(this.value),thisform.cboMonth.value,1)
		thisform.relabel()
		thisform.cursoron()
	return .t.

	procedure keypress
	lparameter nKeyCode, nCtrlAltShift
	clear typeahead
	do case
		case nKeyCode=19		
			* left arrow
			nodefault
			thisform.lockscreen=.t.
			thisform.cursoroff()
			thisform.nCursor=thisform.nCursor-1
			if thisform.nCursor<0
				thisform.nCursor=0
			endif
			thisform.cursoron()
			thisform.lockscreen=.f.
		case nKeyCode=4
			* right arrow
			nodefault
			thisform.lockscreen=.t.
			thisform.cursoroff()
			thisform.nCursor=thisform.nCursor+1
			if thisform.nCursor>34
				thisform.nCursor=34
			endif
			thisform.cursoron()
			thisform.lockscreen=.f.
		case nKeyCode=5
			* up arrow
			nodefault
			thisform.lockscreen=.t.
			thisform.cursoroff()
			m.dd=thisform.firstDay+thisform.nCursor
			thisform.nCursor=thisform.nCursor-7
			if thisform.nCursor<0
				if thisform.cboMonth.value=1 and val(thisform.cboYear.value)=thisform.minYear
					thisform.nCursor=thisform.nCursor+7
				else
					m.dd=m.dd-7
					thisform.nCursor=34-abs(thisform.nCursor)
					thisform.cmdPrev.click()
					with thisform.cboMonth
						thisform.cursoroff()
						thisform.nCursor=m.dd-thisform.firstDay
					endwith
				endif
			endif
			thisform.cursoron()
			thisform.lockscreen=.f.
		case nKeyCode=24
			* down arrow
			nodefault
			thisform.lockscreen=.t.
			thisform.cursoroff()
			m.dd=thisform.firstDay+thisform.nCursor
			thisform.nCursor=thisform.nCursor+7
			if thisform.nCursor>34
				if thisform.cboMonth.value=12 and val(thisform.cboYear.value)=thisform.maxYear
					thisform.nCursor=thisform.nCursor-7
				else
					m.dd=m.dd+7
					thisform.nCursor=thisform.nCursor-34
					thisform.cmdNext.click()
					with thisform.cboMonth
						thisform.cursoroff()
						thisform.nCursor=m.dd-thisform.firstDay
					endwith
				endif
			endif
			thisform.cursoron()
			thisform.lockscreen=.f.
		case nKeyCode=13
			nodefault
			with eval("thisform.cnt"+transform(thisform.nCursor,"@L 99"))
				.click()
			endwith
		case nKeyCode=18
			* PgUp
			nodefault
			thisform.cmdPrev.click()
		case nKeyCode=1
			* Home
			nodefault
			thisform.cmdToday.click()
		case nKeyCode=3
			* PgDn
			nodefault
			thisform.cmdNext.click()
	endcase
	return

	procedure queryunload
		thisform.release()
	return

	procedure relabel
	lparameter m.llMakeObject
		local m.llLockScreen, m.ldDate, m.lnTop, m.lnLeft, m.xx, m.jj, m.dOldFocus, m.lnBase
		m.llLockScreen=thisform.lockscreen
		thisform.lockscreen=.t.
		m.dOldFocus=thisform.firstday+thisform.nFocus
		if !m.llMakeObject
			thisform.focusoff()
		endif
		thisform.nFocus=-1
		* go back to first day
		m.ldDate=thisform.CurDate-day(thisform.CurDate)+1
		do while dow(m.ldDate)<>2
			m.ldDate=m.ldDate-1
		enddo
		thisform.firstDay=m.ldDate
		m.lnTop=90
		m.lnLeft=10
		m.jj=0
		do while m.jj < 35+7
			if mod(m.jj,7)=0 and m.jj<>0
				m.lnTop=m.lnTop+thisform.CellHeight
				m.lnLeft=10
			endif
			m.xx="cnt"+transform(m.jj,"@L 99")
			if m.llMakeObject
				thisform.addobject(m.xx,"cntCell")
			endif
			with eval("thisform."+m.xx)
				.lblEvent.caption=""
				.visible=.t.
				.left=m.lnLeft
				.top=m.lnTop
				.height=thisform.cellHeight
				.width=thisform.cellWidth
				with .lbl
					.caption=alltrim(str(day(m.ldDate)))
					if month(m.ldDate)=month(thisform.CurDate)
						.forecolor=rgb(0,0,0)
						if day(m.ldDate)=1
							m.lnBase=m.jj
						endif
					else
						.forecolor=rgb(150,150,150)
					endif
					if m.ldDate=thisform.startDate
						thisform.nFocus=m.jj
						thisform.focuson()
					endif
				endwith
			endwith
			if m.llMakeObject
				if m.jj<7
					m.xx="cmd"+transform(m.jj,"@L 99")
					thisform.addobject(m.xx,"cmdDow")
					with eval("thisform."+m.xx)	
						.caption=cdow(m.ldDate)
						.top=50
						.left=m.lnLeft
						if inlist(dow(m.ldDate),1,7)
							.forecolor=rgb(255,0,0)
						endif
					endwith
				endif
			endif
			m.lnLeft=m.lnLeft+thisform.cellWidth
			m.ldDate=m.ldDate+1
			m.jj=m.jj+1
		enddo
		if thisform.nFocus<0
			* not yet set
			thisform.nCursor=0
		else
			thisform.nCursor=thisform.nFocus
		endif
		thisform.cursoron()
		thisform.addevents()
		thisform.lockscreen=m.llLockScreen
	return .t.

	function cursoroff
		with eval("thisform.cnt"+transform(thisform.nCursor,"@L 99"))
			.backcolor=.oldBackColor
		endwith
	return .t.

	function cursoron
		with eval("thisform.cnt"+transform(thisform.nCursor,"@L 99"))
			.backcolor=rgb(255,200,200)
		endwith
	return .t.

	function focusoff
		if between(thisform.nFocus,0,34)
			* focus is on
			with eval("thisform.cnt"+transform(thisform.nFocus,"@L 99"))
				.specialeffect=0
				.backcolor=.backcolor
			endwith
		endif
	return .t.

	function focuson
		with eval("thisform.cnt"+transform(thisform.nFocus,"@L 99"))
			.specialeffect=1
			.backcolor=.backcolor
		endwith
	return .t.

	function addevents
	* use thisform.firstday to fetch the 35 days' events
	local m.ii, m.ldDay
	* you can paint each cell here. t_holiday is just an example cursor!
	create cursor t_holiday ( hdate d, hname c(20) )
	insert into t_holiday values ( date(), "today" )
	for m.ii=0 to 34
		m.ldDay=thisform.firstDay+m.ii
		select t_holiday
		locate for hdate=m.ldDay
		if found()
			with eval("thisform.cnt"+transform(m.ii,"@L 99"))
				.lblEvent.caption=t_holiday.hname
			endwith
		endif
	endfor
	use in t_holiday
enddefine
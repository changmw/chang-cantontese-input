parameter m.mnx
*
* do NOT use lparameter
* 
* dump menu definition file (MNX) into a tree-like list
*
* usage: do thisprogram with "/path/to/menuname.mnx"
*
	close all
	clear
	* start from topmost level
	select 0
	use (m.mnx) noupdate alias mymenu
	paintmenu("_MSYSMENU",0)
	use in mymenu
	close all
return

function paintmenu
lparameter m.curlevel, m.lnLevel
local themenu
local m.levelname, m.skipfor, m.buttonprocedure, m.objcode
	* I should use private data session here. :)
	themenu=sys(2015)
	select * from mymenu ;
		where levelname=m.curlevel and objtype=3 ;
		into cursor (themenu)
	scan
		? space(m.lnLevel*5),eval(themenu+".prompt")
		m.objcode=eval(themenu+".objcode")
		select mymenu
		locate for prompt=eval(themenu+".prompt")
		skip
		* all the information about the menu option
		m.levelname=mymenu.levelname
		m.buttonprocedure=alltrim(eval(themenu+".procedure"))
		m.skipfor=alltrim(eval(themenu+".skipfor"))
		*
		if !empty(m.skipfor)
			?? ",","skip for", m.skipfor
			* 
			* uncomment if you could dump the procedure code of the button
			* ?? "",":procedure =", m.buttonprocedure
		endif
		if m.levelname<>m.curlevel
			if hasSubmenu(m.levelname)
				* depth-first recursive call 
				paintmenu(m.levelname,m.lnlevel+1)
			endif
		endif
	endscan
	use in (themenu)
endproc

function hasSubmenu
lparameter m.lcLevelName
local m.ok
	select 0
	use (m.mnx) noupdate again alias t_hassub
	locate for levelname=m.lcLevelName and objtype=3
	m.ok=found()
	use in t_hassub
return m.ok


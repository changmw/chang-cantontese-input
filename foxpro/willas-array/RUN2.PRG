clear all

private G_BSAB, G_BSNM, G_DPATH, G_DATA, XD, Y2K_ROLOV
private m.approot, a_cmpy, m.ii, m.xx, m.startime
declare a_bsab[3]

a_bsab[1]="ARP"
a_bsab[2]="ARC"
a_bsab[3]="ARY"

m.approot = "H:\APP\MIS\V3E"

set procedure to (m.approot+"\obj\glb\procedr2")

m.startime=seconds()

set alternate to
set alternate on

clear
  for m.ii = 1 to 1
    G_BSAB  = a_bsab[m.ii]
    g_dpath = m.approot+"\DATA\"+G_BSAB+"\DDISK"
    g_data  = m.approot+"\DATA\GLB\DDISK"
    G_BSNM  = getbsnm(G_BSAB)
    Y2K_ROLOV = {01/01/1960}
    ? time(), g_dpath, g_bsnm
    XD=date()
    =ulpg0000(g_bsab+substr(dtos(m.XD),3,4)+".TXT")
  endfor
  ? time(), "done"

? "TIME SPENT", (seconds()-m.startime)/60, " minutes"

set alternate off
set alternate to

set procedure to

return

function getbsnm
parameter m.bsab
private m.select, m.bsnm
  m.select = select()
  select 0
  use (g_dpath+"\DTDPGLVB") noupdate
  if used()
    locate
    m.bsnm=upper(trim(DTDPGLVB.BSNM))
  else
    m.bsnm="ERROR READING DTDPGLVB.BSNM"
  endif
  select (m.select)
return m.bsnm

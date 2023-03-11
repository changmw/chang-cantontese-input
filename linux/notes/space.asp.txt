<%
'Drive information script by Garet Jax
Response.Write "<html><head><title></title></head><body>"
Response.Write "<font face=arial>Server Software: "& Request.ServerVariables("SERVER_SOFTWARE") &"<br>Drive Information for: "& Request.ServerVariables("SERVER_NAME") &"<br>"
Response.Write "<table border=1 cellpadding=3 cellspacing=0 bordercolor=Black>"
Response.Write "<tr><td nowrap><font face=arial><b>Driveletter</td><td nowrap><font face=arial><b>Drive Type</td><td nowrap><font face=arial><b>Volume Name</td><td nowrap><font face=arial><b>Total Space</td><td nowrap><font face=arial><b>Available Space</td><td nowrap><font face=arial><b>File System</td><td nowrap><font face=arial><b>Serial #</td></tr>"
Set fs = CreateObject("Scripting.FileSystemObject")
Set drv = fs.Drives
For each d in drv 
If d.Driveletter <> "A" Then
If d.IsReady = True Then
freespace = (d.AvailableSpace / 1024)
free = (freespace / 1024)
totalspace = (d.TotalSize / 1024)
total = (totalspace / 1024)
	Response.Write "<tr><td nowrap><font face=arial size=2><A href='dirwalkR.asp?id="& d.DriveLetter &"'>"& d.DriveLetter &"</a></td>"
	If d.DriveType = 3 Then
		dtype = "Network"
		If d.ShareName = "" Then 
			dname = "&nbsp;"
		Else
			dname = d.ShareName
		End If
	ElseIf d.DriveType = 0 Then
		dtype = "Unknown"
		If d.VolumeName = "" Then 
			dname = "&nbsp;"
		Else
			dname = d.VolumeName
		End If
	ElseIf d.DriveType = 1 Then
		dtype = "Removeable"
		If d.VolumeName = "" Then 
			dname = "&nbsp;"
		Else
			dname = d.VolumeName
		End If
	ElseIf d.DriveType = 2 Then
		dtype = "Fixed"
		If d.VolumeName = "" Then 
			dname = "&nbsp;"
		Else
			dname = d.VolumeName
		End If
	ElseIf d.DriveType = 4 Then
		dtype = "CD-Rom"
		If d.VolumeName = "" Then 
			dname = "&nbsp;"
		Else
			dname = d.VolumeName
		End If
	ElseIf d.DriveType = 5 Then
		dtype = "RAM Disk"
		If d.VolumeName = "" Then 
			dname = "&nbsp;"
		Else
			dname = d.VolumeName
		End If
	End If
	Response.Write "<td nowrap><font face=arial size=2>"& dtype &"</td><td nowrap><font face=arial size=2>"& dname &"</td><td nowrap><font face=arial size=2>"& Round(total,1) &" <font size=1>Megabytes</td><td nowrap><font face=arial size=2>"& Round(free,1) &" <font size=1>Megabytes</td><td nowrap><font face=arial size=2>"& d.FileSystem &"</td><td nowrap><font face=arial size=2>"& d.SerialNumber &"</td></tr>"
Else
	Response.Write "<td nowrap><font face=arial size=2>"& d.DriveLetter &"</td><td colspan=6><font face=arial size=2>Drive not ready</td></tr>"
End If
End If
Next
Response.Write "</table>"
Response.Write "</body></html>"
%>

rem
rem http://www.davescomputertips.com/2013/05/how-to-create-a-speaking-clock-part-1/
rem https://www.reliance-scada.com/en/support/articles/technical/vbscript-tip-converting-alarm-event-text-to-speech
rem http://www.tek-tips.com/viewthread.cfm?qid=1368210
rem https://www.codeproject.com/Articles/19334/Text-to-Speech-using-Windows-SAPI
rem
rem Set fso = CreateObject("Scripting.FileSystemObject")
rem Set StdOut = fso.GetStandardStream(1)
rem
Dim speaks, speech, xx, args

set args=wscript.arguments

Set speech = CreateObject("sapi.spvoice.1")
With speech
   For Each voice in .GetVoices
     rem Wscript.Echo Voice.GetDescription
     If InStr(voice.GetDescription, "English")<>0 and InStr(voice.GetDescription, "Zira")<>0 Then
       Set .Voice = voice
       Exit For
     End If
   Next 

   rem values: 0,1,2 for different voices
   rem Set .voice = .getvoices.item(2)
   .Volume = 100
  if args.count=0 then
    rem 
    rem tell the time
    rem
    strText = Minute(Now)
    intLength = Len(strText)
    intZeroes = 2 - intLength
    For i = 1 to intZeroes
        strText = "0" & strText
    Next
    .rate=1
    .Speak "Current time "
    if Hour(Now)="0" then
        .Speak "12" & " " & StrText
    else
	.Speak Hour(Now) & " " & StrText
    end if
  else
    rem
    rem concat all command-line arguments as a string
    rem and speak it
    rem
    speaks = ""
    for each xx in args
      speaks = speaks & " " & xx
    next
    .Speak speaks
  end if
  speech.Speak xx
end with

'Record speech to a WAV file
rem Set objFile = CreateObject("SAPI.SpFileStream.1")
rem objFile.Open "C:\Record.wav", SSFMCreateForWrite
rem Set objVoice.AudioOutputStream = objFile
rem objVoice.Speak "This text will be recorded to be played back later"

wscript.quit(0)
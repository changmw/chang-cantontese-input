'************************
 '* X BiLe
 '* Local Talk Box
 '* Solo VBS
 '* http://www.visualbasicscript.com/Making-PC39s-Speak-with-SAPISpVoice-m63061.aspx
 '************************
 do
 
   'create the voice object
   Set VObj = CreateObject("SAPI.SpVoice")

   with VObj
       Set .voice = .getvoices.item(0)
       .Volume = 100
       .Rate = 3
   end with

   'get what the user wants to say, exit if cancel or return no msg
   MSG = InputBox("Type what you want the PC to say" & VBCRLF & VBCRLF & VBCRLF & "To End enter Nothing or push the Cancel button", "Voice Box By X BiLe", "")
     
     If MSG = "" Then WScript.quit: Else
 
       'use the VObj to speak msg
       with VObj
         .Speak MSG
       end with
  loop
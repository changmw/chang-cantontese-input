#
# .SYNOPSIS
#  Clears the command history, including the saved-to-file history, if applicable.
#
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
Clear-Host
[console]::beep(500,300)
Write-Host "Clearing history..." -ForegroundColor Green -NoNewline
Clear-History
# (Get-PSReadlineOption).HistorySavePath
Remove-Item (Get-PSReadlineOption).HistorySavePath
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
[System.Windows.Forms.SendKeys]::SendWait("%{F7 2}")
Write-Host "Done!" -ForegroundColor Green 

# Add-Type -AssemblyName PresentationFramework
# [System.Windows.MessageBox]::Show('Clearing history')

Function playmp3 {
Param ($Name, $Runs, $Outs)
#
# From URL
#
$MediaPlayer = [Windows.Media.Playback.MediaPlayer, Windows.Media, ContentType = WindowsRuntime]::New()
$MediaPlayer.Source = [Windows.Media.Core.MediaSource]::CreateFromUri('https://nyanpass.com/nyanpass.mp3')
$MediaPlayer.Play()
#
# From File
#
$MediaPlayer = [Windows.Media.Playback.MediaPlayer, Windows.Media, ContentType = WindowsRuntime]::New()
$MediaPlayer.Source = [Windows.Media.Core.MediaSource]::CreateFromUri('C:\Users\Admin\Downloads\nyanpass.mp3')
$MediaPlayer.Play()
}
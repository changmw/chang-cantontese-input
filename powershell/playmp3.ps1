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

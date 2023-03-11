#
# Commands to remove the pre-installed Phone Link app in Windows 10
#
Get-AppxPackage Microsoft.YourPhone -AllUsers | Remove-AppxPackage

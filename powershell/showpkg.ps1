#
# Command to list packages in Windows 10 matching string "package_name"
#
Get-ProvisionedAppxPackage -Online | `
Where-Object { $_.PackageName -match "package_name" }

*
*
dism /Online /Get-ProvisionedAppxPackages | Select-String PackageName | Select-String xbox

Get-ProvisionedAppxPackage -Online | `
Where-Object { $_.PackageName -match "xbox" } | `
ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }


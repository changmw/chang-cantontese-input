Get-ProvisionedAppxPackage -Online | `
Where-Object { $_.PackageName -match "xbox" }

New-Item -ItemType Directory `
         -Path ~/.config/powershell `
         -Force `
         -ErrorAction SilentlyContinue

New-Item -ItemType SymbolicLink `
         -Path ~/.config/powershell/profile.ps1 `
         -Value (Join-Path $PWD '.devcontainer' -AdditionalChildPath 'profile.ps1')

Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
Install-Module PSReadline -Scope CurrentUser -AllowPrerelease -Force
Install-Module oh-my-posh
Install-Module posh-git
Install-Module Terminal-Icons

Set-Content ~/.config/.postCreateComplete -Value ""

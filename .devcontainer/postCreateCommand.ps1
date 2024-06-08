
New-Item -ItemType Directory `
         -Path ~/.config/powershell `
         -Force `
         -ErrorAction SilentlyContinue

New-Item -ItemType SymbolicLink `
         -Path ~/.config/powershell/profile.ps1 `
         -Value (Join-Path $PWD '.devcontainer' -AdditionalChildPath 'profile.ps1')

curl -s https://ohmyposh.dev/install.sh | bash -s

Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
Install-Module Configuration
Install-Module Pansies
Install-Module posh-git
Install-Module Terminal-Icons

Set-Content ~/.config/.postCreateComplete -Value ""

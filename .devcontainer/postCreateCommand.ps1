
# Create powershell config folder (linux well-known location)
New-Item -ItemType Directory `
         -Path ~/.config/powershell `
         -Force `
         -ErrorAction SilentlyContinue

# Link the devcontainer profile into the config to ensure it's loaded with pwsh
New-Item -ItemType SymbolicLink `
         -Path ~/.config/powershell/profile.ps1 `
         -Value (Join-Path $PWD '.devcontainer' -AdditionalChildPath 'profile.ps1')

# Install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s

# Install modules
Set-PSResourceRepository -Trusted -Name PSGallery
# Dev
Install-PSResource InvokeBuild
Install-PSResource Configuration
Install-PSResource Pansies
Set-Alias ib Invoke-Build

# Module Prerequistes
Install-PSResource posh-git
Install-PSResource Terminal-Icons


# Add flag-file to indicate that the config has completed
Set-Content ~/.config/.postCreateComplete -Value ""



function WriteInfo() {
    param($Text)
    $style = "$($PSStyle.Background.Orange)$($PSStyle.Foreground.White)"
    Write-Output "$style----> $Text <----"
}

WriteInfo "Creating '~/.config/powershell/'"
# Create powershell config folder (linux well-known location)
$params = @{
    ItemType    = 'Directory'
    Path        = '~/.config/powershell'
    Force       = $true
    ErrorAction = 'SilentlyContinue'
}
New-Item @params

WriteInfo "Linking profile.ps1'"
# Link the devcontainer profile into the config to ensure it's loaded with pwsh
$params = @{
    ItemType    = 'SymbolicLink'
    Path        = '~/.config/powershell/profile.ps1'
    Value       = (Join-Path $PWD '.devcontainer' -AdditionalChildPath 'profile.ps1')
    Force       = $true
    ErrorAction = 'SilentlyContinue'
}
New-Item @params

WriteInfo "Install oh-my-posh"
curl -s https://ohmyposh.dev/install.sh | bash -s

Set-PSResourceRepository -Trusted -Name PSGallery

WriteInfo "Install DEV modules"
Install-PSResource InvokeBuild
Install-PSResource Configuration
Install-PSResource Pester
Set-Alias ib Invoke-Build

# Module Prerequisites
WriteInfo "Install Prerequiste Modules"
Install-PSResource posh-git
Install-PSResource Terminal-Icons

# Add flag-file to indicate that the config has completed
Set-Content ~/.config/.postCreateComplete -Value ''

WriteInfo "Done"

param(
    [Switch]$Force,

    [ValidateSet("CurrentUser","AllUser")]
    $Scope = "CurrentUser"
)

$ProfileDir = Split-Path -Path $Profile.CurrentUserAllHosts
New-Item -ItemType Directory -Path "$ProfileDir\Modules" -Force | Convert-Path | Push-location

try {
    $ErrorActionPreference = 'Stop'

    if(Test-Path Profile-master){
        Write-Error "The Profile-master folder already exists, install cannot continue."
    }
    if (Test-Path Profile){
        Write-Warning "The Profile module already exists, install will overwrite it and put the old one in Profile/old."
        Remove-Item Profile/old -Recurse -Force -ErrorAction SilentlyContinue
    }

    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest https://github.com/MartinSGill/Profile/archive/master.zip -OutFile Profile-master.zip
    $ProgressPreference = "Continue"
    Expand-Archive Profile-master.zip .
    $null = mkdir Profile-master\old

    if (Test-Path Profile) {
        Move-Item Profile\* Profile-master\old
        Remove-Item Profile
    }

    Rename-Item Profile-master Profile
    Remove-Item Profile-master.zip

    # Install the profile
    if (!$Force -and (Test-Path $Profile.CurrentUserAllHosts)) {
        Write-Warning "Profile.ps1 already exists. Leaving new profile in $($Profile.CurrentUserAllHosts)"
    } else {
        Set-Content $Profile.CurrentUserAllHosts @'
        $actual = @(
            "$PSScriptRoot\Modules\Profile\profile.ps1"
            "A:\.pscloudshell\PowerShell\Modules\Profile\profile.ps1"
            "$Home\source\repos\Profile\profile.ps1"
        ).Where({Test-Path $_}, 1)

        Write-Host "Profile: $actual"
        . $actual
'@ -Encoding ascii
    }

    # Ensure PSGallery is trusted
    $gallery = Get-PSRepository PSGallery
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    # Ensure PowershellGet is up-to-date
    Install-Module PowershellGet -Force -Scope $Scope -AllowClobber -MinimumVersion 2.2.1

    $requiredModules = (Get-Module Profile -ListAvailable).RequiredModules.Name
    Write-Host "Installing Required Modules in Scope:$Scope $($requiredModules -join ', ')"
    Find-Module $requiredModules |
        Find-Module -AllowPrerelease |
        Install-Module -Scope:$Scope -RequiredVersion { $_.Version } -AllowPrerelease -AllowClobber

    # Reset Policy
    Set-PSRepository -Name PSGallery -InstallationPolicy $gallery.InstallationPolicy

} catch {

}
finally {
    Pop-Location
}

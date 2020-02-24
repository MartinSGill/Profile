[CmdletBinding()]
param(
    [Switch]$Force,

    [ValidateSet("CurrentUser","AllUser")]
    $Scope = "CurrentUser"
)

Write-Verbose "Finding Profile Dir."
$eap = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$targetProfileDir = Split-Path -Path $Profile.CurrentUserAllHosts
$ErrorActionPreference = $eap

Write-Verbose "Creating Modules Folder & CD to folder."
New-Item -ItemType Directory -Path "$targetProfileDir\Modules" -Force | Convert-Path | Push-location

try {
    $ErrorActionPreference = 'stop'
    Write-Verbose "Checking for existing download."
    if(Test-Path Profile-master){
        Write-Error "The Profile-master folder already exists, install cannot continue."
    }

    Write-Verbose "Checking for existing module."
    if (Test-Path Profile){
        Write-Warning "The Profile module already exists, install will overwrite it and put the old one in Profile/old."
        Remove-Item Profile/old -Recurse -Force -ErrorAction SilentlyContinue
    }

    $ProgressPreference = "SilentlyContinue"
    Write-Verbose "Downloading from github."
    Invoke-WebRequest https://github.com/MartinSGill/Profile/archive/master.zip -OutFile Profile-master.zip
    $ProgressPreference = "Continue"
    Write-Verbose "Expanding archive."
    Expand-Archive Profile-master.zip .
    $null = mkdir Profile-master\old

    Write-Verbose "Creating backup if needed."
    if (Test-Path Profile) {
        Move-Item Profile\* Profile-master\old
        Remove-Item Profile
    }

    Write-Verbose "Rename download to live."
    Rename-Item Profile-master Profile

    Write-Verbose "Tidying up."
    Remove-Item Profile-master.zip

    # Install the profile
    Write-Verbose "Installing profile script."
    if (!$Force -and (Test-Path $Profile.CurrentUserAllHosts)) {
        Write-Warning "Profile.ps1 already exists. Leaving new profile in $($Profile.CurrentUserAllHosts)"
    } else {
        Set-Content $Profile.CurrentUserAllHosts @'
        $actual = @(
            "$Home\source\repos\Profile\profile.ps1"
            "$PSScriptRoot\Modules\Profile\profile.ps1"
            "A:\.pscloudshell\PowerShell\Modules\Profile\profile.ps1"
        ) | Where-Object {Test-Path $_} | Select-Object -First 1

        Write-Host "Profile: $actual"
        . $actual
'@ -Encoding ascii
    }

    # Ensure PSGallery is trusted
    Write-Verbose "Configuring PSGallery Policy."
    $gallery = Get-PSRepository PSGallery
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    Write-Host "! Beginning Module Updates"

    # Ensure PowershellGet is up-to-date
    Write-Verbose "Updating PowershellGet."
    Install-Module PowershellGet -Force -Scope $Scope -AllowClobber -MinimumVersion 2.2.1

    $requiredModules = (Get-Module Profile -ListAvailable).RequiredModules.Name
    Write-Host "Installing Required Modules in Scope:$Scope $($requiredModules -join ', ')"
    Find-Module $requiredModules |
        Find-Module -AllowPrerelease |
        Install-Module -Scope:$Scope -RequiredVersion { $_.Version } -AllowPrerelease -AllowClobber

    # Reset Policy
    Write-Verbose "Resetting PSGallery Policy."
    Set-PSRepository -Name PSGallery -InstallationPolicy $gallery.InstallationPolicy
    Write-Host "! Done With Module Updates"
} catch {
    Write-Host -ForegroundColor Red -Object $_.Exception
}
finally {
    Pop-Location
    Get-Module Profile -ListAvailable | Select-Object -Property Name,Version
    Write-Verbose "Done."
}

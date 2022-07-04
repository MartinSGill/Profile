function script:Install-EverythingCli {
    [CmdletBinding()]
    param ()

    if (-not $IsWindows) {
        return
    }

    if (-not (Test-MyProCommand -Name winget)) {
        Write-Warning "Winget not available, reduced functionality likely"
    }

    $response = winget list voidtools.everything
    if ($response -match "No installed package found matching input criteria") {
        Write-Warning "Everything is not installed, installing"
        winget install voidtools.everything -r
    }

    if (-not (Test-Path "$env:LOCALAPPDATA\Everything")) {
        New-Item -Path $env:LOCALAPPDATA\Everything -ItemType Directory
    }

    if (-not (Test-Path "$env:LOCALAPPDATA\Everything\es.exe")) {
        Write-Warning "Everything CLI is not installed, installing"
        $esZipPath = "$env:LOCALAPPDATA\Everything\ES-1.1.0.23.zip"
        Invoke-WebRequest -Uri https://www.voidtools.com/ES-1.1.0.23.zip -OutFile $esZipPath
        Unblock-File $esZipPath
        Expand-Archive -Path $esZipPath -DestinationPath "$env:LOCALAPPDATA\Everything"
    }

    $p = @{
        SearchPath = @("$env:LOCALAPPDATA\Everything")
        ToolName = 'es.exe'
        AliasName = 'es'
    }
    New-MyProToolAlias @p
}

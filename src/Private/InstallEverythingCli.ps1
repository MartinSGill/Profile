function InstallEverythingCli {
    [CmdletBinding()]
    param ()

    WriteDebug "Checking on Windows"
    if (-not $IsWindows) {
        return
    }

    # Test for cli
    WriteDebug "Checking for existing es.exe"
    if (Test-Path "$env:LOCALAPPDATA\Everything\es.exe") {
        $p = @{
            SearchPath = @("$env:LOCALAPPDATA\Everything")
            ToolName = 'es.exe'
            AliasName = 'es'
        }
        WriteDebug "Creating Alias 'es'"
        NewToolAlias @p
        return
    }

    WriteDebug "Checking for winget"
    if (-not (Test-Command -Name winget)) {
        Write-Warning "Winget not available, reduced functionality likely"
    }

    WriteDebug "Checking for voidtools.everything"
    $response = winget list voidtools.everything
    if ($response -match "No installed package found matching input criteria") {
        WriteDebug "Installing voidtools.everything"
        Write-Warning "Everything is not installed, installing"
        winget install voidtools.everything -r
    }

    WriteDebug "Checking for AppData\Everything"
    if (-not (Test-Path "$env:LOCALAPPDATA\Everything")) {
        New-Item -Path $env:LOCALAPPDATA\Everything -ItemType Directory
    }

    WriteDebug "Checking for es.exe"
    if (-not (Test-Path "$env:LOCALAPPDATA\Everything\es.exe")) {
        Write-Warning "Everything CLI is not installed, installing"
        $esZipPath = "$env:LOCALAPPDATA\Everything\ES-1.1.0.23.zip"
        Invoke-WebRequest -Uri https://www.voidtools.com/ES-1.1.0.23.zip -OutFile $esZipPath
        Unblock-File $esZipPath
        Expand-Archive -Path $esZipPath -DestinationPath "$env:LOCALAPPDATA\Everything"
    }

    WriteDebug "Creating Alias 'es'"
    $p = @{
        SearchPath = @("$env:LOCALAPPDATA\Everything")
        ToolName = 'es.exe'
        AliasName = 'es'
    }
    NewToolAlias @p
}

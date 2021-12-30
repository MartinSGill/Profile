
function script:Get-MyProDropboxFolder {
    <#
        .SYNOPSIS
            Find the location where Dropbox stores files
            for the current user.
    #>
    [CmdletBinding()]
    param ()

    $info = $null;
    if (Test-Path (Join-Path $env:APPDATA "dropbox\info.json")) {
        Write-Verbose "Found dropbox info in APPDATA"
        $info = Get-Content (Join-Path $env:APPDATA "dropbox\info.json") | ConvertFrom-Json
    } elseif (Test-Path (Join-Path $env:LOCALAPPDATA "dropbox\info.json")) {
        Write-Verbose "Found dropbox info in LOCALAPPDATA"
        $info = Get-Content (Join-Path $env:LOCALAPPDATA "dropbox\info.json") | ConvertFrom-Json
    }

    if ($null -eq $info) {
        Write-Warning "Dropbox Content Folder not found."
        return $null
    }

    $path = $info.personal.path
    Write-Verbose "Found Path: $path"
    $path
}

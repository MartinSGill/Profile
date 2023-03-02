
function script:Get-MyProDropboxFolder {
    <#
        .SYNOPSIS
            Find the location where Dropbox stores files
            for the current user.
    #>
    [CmdletBinding()]
    param ()

    if ($IsWindows) {

    }

    $info = $null

    $testPaths = @()
    if ($IsWindows) {
        $testPaths = @(
            (Join-Path "$env:APPDATA" 'dropbox\info.json')
            (Join-Path "$env:LOCALAPPDATA" 'dropbox\info.json')
        )
    }

    if ($testPaths.Count -le 0) {
        Write-Warning 'Dropbox does not appear to be installed.'
        return $null
    }

    $path = $testPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($null -eq $path) {
        Write-MyProDebug 'Dropbox is not found'
        return $null
    }
    $info = Get-Content $path | ConvertFrom-Json

    if ($null -eq $info) {
        Write-Warning 'Dropbox info.json invalid.'
        return $null
    }

    $path = $info.personal.path
    Write-Verbose "Found Path: $path"
    $path
}

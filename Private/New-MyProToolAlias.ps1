
function script:New-MyProToolAlias {
    <#
    .SYNOPSIS
        Add an alias for a CLI tool
    #>
    param(
        # Paths to search for the tool (if not in env:PATH)
        # Do not include tool/exe name
        # e.g. c:\windows\system32
        [String[]]$SearchPath,
        # Tool/Exe name e.g. notepad.exe
        [String]$ToolName,
        # Alias for tool/exe
        [String]$AliasName
    )

    $s = $PSStyle.Foreground.Yellow
    $f = $PSStyle.Reset

    # First portable/dropbox
    $dropboxPath = Get-MyProDropboxFolder;
    if (-not [String]::IsNullOrWhiteSpace($dropboxPath)) {
        $dropboxPortable = Join-Path -Path ($dropboxPath) 'Software' -AdditionalChildPath 'portable'
        $portable = Get-ChildItem -Path $dropboxPortable -Recurse -Filter $ToolName | Select-Object -First 1
        if (-not [String]::IsNullOrWhiteSpace($portable)) {
            Write-MyProDebug "Set Tool Alias ${s}${AliasName}${f} -> ${s}${portable}${f}"
            New-Alias -Name $AliasName -Value $portable -Scope Global
            return
        }
    }

    # Then Check in path
    if (Test-MyProCommand -Name $ToolName) {
        Write-MyProDebug "Set Tool Alias From env:PATH: ${s}${AliasName}${f} -> ${s}${ToolName}${f}"
        return
    }

    # Then check search paths
    $found = $SearchPath | Where-Object { Test-Path (Join-Path $_ $ToolName) } | Select-Object -First 1
    if ([String]::IsNullOrWhiteSpace($found)) {
        Write-MyProDebug "Tool ${s}$ToolName${f} not found"
        return
    }

    $path = (Join-Path $found $ToolName)
    Write-MyProDebug "Set Tool Alias ${s}${AliasName}${f} -> ${s}${path}${f}"
    New-Alias -Name $AliasName -Value $path -Scope Global
}


function NewToolAlias {
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

    if (-not [String]::IsNullOrWhiteSpace((Get-DropboxFolder -ErrorAction SilentlyContinue))) {
        # First portable/dropbox
        $dropboxPortable = Join-Path -Path (Get-DropboxFolder) 'Software' -AdditionalChildPath 'portable'
        $portable = Get-ChildItem -Path $dropboxPortable -Recurse -Filter $ToolName | Select-Object -First 1
        if (-not [String]::IsNullOrWhiteSpace($portable)) {
            WriteDebug "Set Tool Alias ${s}${AliasName}${f} -> ${s}${portable}${f}"
            New-Alias -Name $AliasName -Value $portable -Scope Global
            return
        }
    }
    else {
        WriteDebug "Dropbox not found/installed"
    }

    # Then Check in path
    if (Test-Command -Name $ToolName) {
        WriteDebug "Set Tool Alias From env:PATH: ${s}${AliasName}${f} -> ${s}${ToolName}${f}"
        return
    }

    # Then check search paths
    $found = $SearchPath | Where-Object { Test-Path (Join-Path $_ $ToolName) } | Select-Object -First 1
    if ([String]::IsNullOrWhiteSpace($found)) {
        WriteDebug "Tool ${s}$ToolName${f} not found"
        return
    }

    $path = (Join-Path $found $ToolName)
    WriteDebug "Set Tool Alias ${s}${AliasName}${f} -> ${s}${path}${f}"
    New-Alias -Name $AliasName -Value $path -Scope Global
}

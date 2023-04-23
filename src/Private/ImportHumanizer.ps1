function ImportHumanizer {
    <#
    .SYNOPSIS
        Import Humanizer formats and type updates.
    .EXAMPLE
        PS C:\> Import-Humanizer
        Import Humanizer formats and type updates.
    .NOTES
        Does not include localization libraries, so only Invariant Culture.
    #>
    [CmdletBinding()]
    param ()

    $path = "$PSScriptRoot/Dlls/Humanizer.dll"
    WriteDebug "Importing Humanizer: $path"

    Add-Type -Path $path -Verbose:([boolean]$env:MartinsProfileDebugMode) -Debug:([boolean]$env:MartinsProfileDebugMode)
}

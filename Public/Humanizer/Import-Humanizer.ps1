function script:Import-Humanizer {
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

    begin {

    }

    process {
        Add-Type -Path "$PSScriptRoot/Humanizer.dll"
        Update-TypeData -PrependPath @(Get-ChildItem -Path "$PSScriptRoot/Types" -Filter "*.ps1xml")
    }

    end {

    }
}

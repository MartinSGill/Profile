function Import-Humanizer {
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

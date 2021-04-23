function Import-Types {
    [CmdletBinding()]
    param ()

    begin {

    }

    process {
        Update-TypeData -PrependPath @(Get-ChildItem -Path "$PSScriptRoot/Types" -Filter "*.ps1xml")
    }

    end {

    }
}

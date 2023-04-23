function GetPhysicalPsDrive {
    [CmdletBinding()]
    param ()

    process {
        Get-PSDrive |
            Where-Object Name -in @(
                Get-Partition |
                    Where-Object Type -eq Basic |
                    Where-Object { -not [string]::IsNullOrWhitespace($_) } |
                    Select-Object -ExpandProperty DriveLetter)
    }
}

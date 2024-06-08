<#
.SYNOPSIS
    Get the location of various profile related files.

.DESCRIPTION
    Get the location of various profile related files.

.EXAMPLE
    Get-ProfileLocation

    Get the location of various profile related files.

.OUTPUTS
    [PSCustomObject]

    A custom object with the properties:
        - Name: The name of the profile related file.
        - Location: The location of the profile related file.
        - Exists: A string indicating whether the file exists or not, colored green for "YES" and red for "NO".

.PARAMETER
    None

.NOTES
    This function is only available in PowerShell v3 and later, due to the use of the $PSStyle automatic variable.

.LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/about/about_automatic_variables?view=powershell-7#psstyle

#>

function Get-ProfileLocation {
    [CmdletBinding()]
    param()

    $stYes = $PSStyle.Background.Green + $PSStyle.Foreground.BrightWhite
    $stNo = $PSStyle.Background.Red + $PSStyle.Foreground.BrightWhite
    $r = $PSStyle.Reset
    $Profile | Get-Member -MemberType NoteProperty | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name
            Exists = (Test-Path $Profile.$($_.Name)) ? "$stYes  YES  $r" : "$stNo  NO   $r"
            Location = $Profile.$($_.Name)
        }
    }
}

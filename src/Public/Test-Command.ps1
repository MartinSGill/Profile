
function Test-Command {
    <#
    .SYNOPSIS
        Test if a command/exe exists in memory or on path.
    .EXAMPLE
        PS C:\> Test-Command pwsh.exe
        Test if pwsh.exe exists in available in path.
        .EXAMPLE
        PS C:\> Test-Command Get-ChildItem
        Test if Get-ChildItem cmdlet is available.
    .OUTPUTS
        $true / $false
    #>
    [CmdletBinding()]
    param (
        [OutputType([boolean])]
        [Parameter(Mandatory = $true)]
        [string] $Name
    )
    process {
        $null -ne (Resolve-Command $Name -ErrorAction SilentlyContinue)
    }
}

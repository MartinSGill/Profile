function script:Resolve-MyProCommand {
    <#
    .SYNOPSIS
        Equivalent to unix "which" command.
    .DESCRIPTION
        Equivalent to unix "which" command.

        Gets the first available command, ie. the command that will
        will be used if you invoke it from the CLI.

        NOTE: for Functions et.al. it will return the DLL name, or
        module name.
    .EXAMPLE
        PS C:\> Resolve-Command pwsh.exe
        Test if pwsh.exe exists in available in path.
    .EXAMPLE
        PS C:\> Resolve-Command Get-ChildItem
    #>
    [CmdletBinding()]
    param (
        [OutputType([string])]
        [Parameter(Mandatory = $true)]
        [string] $Name
    )
    process {
        Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source
    }
}

function Resolve-Command {
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
        if ($IsWindows) {
            $path = where.exe $Name 2>&1
            if ($?) {
                return $path | Select-Object -First 1
            }
        } else {
            $path = which $Name 2>&1
            if ($?) {
                return $path
            }
        }

        $alias = Get-Alias -Name $Name -ErrorAction SilentlyContinue
        if ($?) {
            return $alias;
        }

        Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source
    }
}

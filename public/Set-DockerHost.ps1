<#
.SYNOPSIS
    Sets the current docker host.
.EXAMPLE
    PS> Set-DockerHost -Name SomeHost
.NOTES
    Uses  ~/.docker-hosts.psd1 as its default source.

    Example .docker-hosts.psd1:

    @{
        VmLinux = 'tcp://192.168.254.118:2375'
        Jenkins = 'tcp://192.168.254.119:2375'
        VmWin = 'tcp://192.168.254.120:2375'
    }

#>
function Set-DockerHost {
    [CmdletBinding()]
    Param (
        # Name of the host.
        [Parameter(Mandatory=$true)]
        [string]$Name,

        # Path to an alternate config file.
        [Parameter(Mandatory=$false)]
        [string]$Path = '~/.docker-hosts.psd1'
    )

    if ((Test-Path $Path)) {
        $hosts = Import-PowerShellDataFile $Path
        $env:DOCKER_HOST = $hosts[$Name]
    } else {
        throw "$Path not found."
    }
}

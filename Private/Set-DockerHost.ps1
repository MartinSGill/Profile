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
function script:Set-DockerHost {
    [CmdletBinding(PositionalBinding=$false)]
    Param (
        # Path to an alternate config file.
        [Parameter(Mandatory=$false)]
        [string]$Path
    )

    DynamicParam {
        $dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        if ([string]::IsNullOrWhiteSpace($Path)) { $testPath = '~/.docker-hosts.psd1' }
        if ((Test-Path $testPath)) {
            Write-Verbose "3"
            try {
                $hosts = Import-PowerShellDataFile $testPath
                $options = $hosts.Keys
            } catch {}
        }
        New-DynamicParam -Name Name -ValidateSet $options -Mandatory -DpDictionary $dictionary
        return $dictionary
    }

    begin {
        $Name = $PSBoundParameters.Name
        if ([string]::IsNullOrWhiteSpace($Path)) { $Path = '~/.docker-hosts.psd1' }
    }

    process {
        if ((Test-Path $Path)) {
            $hosts = Import-PowerShellDataFile $Path
            $env:DOCKER_HOST = $hosts[$Name]
        } else {
            throw "$Path not found."
        }
    }
}

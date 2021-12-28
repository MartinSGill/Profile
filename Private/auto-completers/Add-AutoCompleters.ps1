
function script:Add-AutoCompleters {

    #########
    ## DOCKER
    #########
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Import-Module DockerCompletion
        if (-not $?) {
            Write-Warning "DockerCompletion module not found, installing."
            Install-Module DockerCompletion -Scope CurrentUser
            Import-Module DockerCompletion
        }
    }

    #########
    ## NUKE
    #########
    Register-ArgumentCompleter -Native -CommandName nuke -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
            nuke :complete "$wordToComplete" | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }


    #########
    ## DOTNET
    #########
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
            dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }
}

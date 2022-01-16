function script:Update-ToolPath {
    <#
        .Synopsis
            Add useful tool aliases

    #>
    param()

    $p = @{
        SearchPath = @()
        ToolName = 'docker.exe'
        AliasName = 'd'
    }
    New-MyProToolAlias @p

    $p = @{
        SearchPath = @()
        ToolName = 'docker-compose.exe'
        AliasName = 'dc'
    }
    New-MyProToolAlias @p

    $p = @{
        SearchPath = @("$env:ProgramFiles\Sublime Merge")
        ToolName = 'smerge.exe'
        AliasName = 'sm'
    }
    New-MyProToolAlias @p

    $p = @{
        SearchPath = @("$env:ProgramFiles\Notepad++")
        ToolName = 'notepad++.exe'
        AliasName = 'npp'
    }
    New-MyProToolAlias @p

    $p = @{
        SearchPath = @()
        ToolName = 'Far.exe'
        AliasName = 'far'
    }
    New-MyProToolAlias @p

    $p = @{
        SearchPath = @()
        ToolName = 'RegexBuddy4.exe'
        AliasName = 'regbuddy'
    }
    New-MyProToolAlias @p
}

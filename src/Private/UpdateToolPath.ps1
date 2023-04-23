function UpdateToolPath {
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
    NewToolAlias @p

    $p = @{
        SearchPath = @()
        ToolName = 'docker-compose.exe'
        AliasName = 'dc'
    }
    NewToolAlias @p

    $p = @{
        SearchPath = @("$env:ProgramFiles\Sublime Merge")
        ToolName = 'smerge.exe'
        AliasName = 'sm'
    }
    NewToolAlias @p

    $p = @{
        SearchPath = @("$env:ProgramFiles\Notepad++")
        ToolName = 'notepad++.exe'
        AliasName = 'npp'
    }
    NewToolAlias @p

    $p = @{
        SearchPath = @()
        ToolName = 'Far.exe'
        AliasName = 'far'
    }
    NewToolAlias @p

    $p = @{
        SearchPath = @()
        ToolName = 'RegexBuddy4.exe'
        AliasName = 'regbuddy'
    }
    NewToolAlias @p
}

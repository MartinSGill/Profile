function UpdateToolPath {
    <#
        .Synopsis
            Add useful tool aliases

    #>
    param()

    VerboseBlock "docker" {
    $p = @{
        SearchPath = @()
        ToolName = 'docker.exe'
        AliasName = 'd'
    }
    NewToolAlias @p
}

    VerboseBlock "docker-compose" {
        $p = @{
            SearchPath = @()
            ToolName = 'docker-compose.exe'
            AliasName = 'dc'
        }
        NewToolAlias @p
    }

    VerboseBlock "Sublime Merge" {
        $p = @{
            SearchPath = @("$env:ProgramFiles\Sublime Merge")
            ToolName = 'smerge.exe'
            AliasName = 'sm'
        }
        NewToolAlias @p
    }

    VerboseBlock "Notepad++" {
        $p = @{
            SearchPath = @("$env:ProgramFiles\Notepad++")
            ToolName = 'notepad++.exe'
            AliasName = 'npp'
        }
        NewToolAlias @p
    }

    VerboseBlock "FAR filemanager" {
        $p = @{
            SearchPath = @()
            ToolName = 'Far.exe'
            AliasName = 'far'
        }
        NewToolAlias @p
    }

    VerboseBlock "RegexBuddy" {
        $p = @{
            SearchPath = @()
            ToolName = 'RegexBuddy4.exe'
            AliasName = 'regbuddy'
        }
        NewToolAlias @p
    }
}

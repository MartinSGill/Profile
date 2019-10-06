function Set-HostColor {
    <#
        .Description
            Set more reasonable colors, because yellow is for warning, not verbose
    #>
    [CmdletBinding()]
    param(
        # Change the background color only if ConEmu didn't already do that.
        [Switch]$Light,

        # Don't use the special PowerLine characters
        [Switch]$SafeCharacters,

        # If set, run the script even when it's not the ConsoleHost
        [switch]$Force
    )

    if ($Light) {
        Import-Theme Light
    } else {
        Import-Theme Dark
    }

    $PSReadLineOption = @{
        AnsiEscapeTimeout             = 100
        BellStyle                     = "Visual"
        CompletionQueryItems          = 100
        ContinuationPrompt            = ">> "
        DingDuration                  = 50 #ms
        DingTone                      = 1221
        EditMode                      = "Windows"
        HistoryNoDuplicates           = $true
        HistorySaveStyle              = "SaveIncrementally"
        HistorySearchCaseSensitive    = $false
        HistorySearchCursorMovesToEnd = $false
        MaximumHistoryCount           = 1024
        MaximumKillRingCount          = 10
        ShowToolTips                  = $true
        WordDelimiters                = ";:,.[]{}()/\|^&*-=+"
    }
    Set-PSReadlineOption @PSReadLineOption
}

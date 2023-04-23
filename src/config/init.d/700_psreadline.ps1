
VerboseBlock 'PSReadine Settings' {

    WriteDebug "Setting Options"
    $PSReadLineOption = @{
        AnsiEscapeTimeout             = 100
        BellStyle                     = 'Visual'
        CompletionQueryItems          = 100
        ContinuationPrompt            = '>> '
        DingDuration                  = 50 #ms
        DingTone                      = 1221
        EditMode                      = 'Windows'
        HistoryNoDuplicates           = $true
        HistorySaveStyle              = 'SaveIncrementally'
        HistorySearchCaseSensitive    = $false
        HistorySearchCursorMovesToEnd = $true
        MaximumHistoryCount           = 4096
        MaximumKillRingCount          = 10
        ShowToolTips                  = $true
        WordDelimiters                = ';:,.[]{}()/\|^&*-=+'
        PredictionViewStyle           = 'ListView'
        PredictionSource              = 'HistoryAndPlugin'

        # Colors
        Colors = @{
            Emphasis                = $PSStyle.Foreground.BrightCyan
            Error                   = $PSStyle.Foreground.BrightRed
            InlinePrediction        = "`e[97;2;3m"
            Keyword                 = $PSStyle.Foreground.BrightGreen
            ListPrediction          = $PSStyle.Foreground.Yellow
            ListPredictionSelected  = "`e[48;5;238m"
            Member                  = $PSStyle.Foreground.White
            Number                  = $PSStyle.Foreground.BrightWhite
            Operator                = $PSStyle.Foreground.BrightBlack
            Parameter               = $PSStyle.Foreground.BrightBlack
            Selection               = $PSStyle.Foreground.Black + $PSStyle.Background.White
            String                  = $PSStyle.Foreground.White
            Type                    = $PSStyle.Foreground.Cyan
            Variable                = $PSStyle.Foreground.BrightGreen
        }
    }

    Set-PSReadlineOption @PSReadLineOption

    WriteDebug "Updating KeyHandlers"
    Set-PSReadlineKeyHandler Ctrl+Shift+C CaptureScreen
    Set-PSReadlineKeyHandler Ctrl+Shift+R ForwardSearchHistory
    Set-PSReadlineKeyHandler Ctrl+R ReverseSearchHistory

    Set-PSReadLineKeyHandler Ctrl+Home BeginningOfHistory

    Set-PSReadlineKeyHandler Ctrl+M SetMark
    Set-PSReadlineKeyHandler Ctrl+Shift+M ExchangePointAndMark

    Set-PSReadlineKeyHandler Ctrl+K KillLine
    Set-PSReadlineKeyHandler Ctrl+I Yank

    Set-PSReadLineKeyHandler Ctrl+h BackwardDeleteWord
    Set-PSReadLineKeyHandler Ctrl+Enter AddLine
    Set-PSReadLineKeyHandler Ctrl+Shift+Enter AcceptAndGetNext
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

    # Sometimes you enter a command but realize you forgot to do something else first.
    # This binding will let you save that command in the history so you can recall it,
    # but it doesn't actually execute.  It also clears the line with RevertLine so the
    # undo stack is reset - though redo will still reconstruct the command line.
    Set-PSReadLineKeyHandler -Key Alt+w `
        -BriefDescription SaveInHistory `
        -LongDescription 'Save current line in history but do not execute' `
        -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    }

    # Insert text from the clipboard as a here string
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+v `
        -BriefDescription PasteAsHereString `
        -LongDescription 'Paste the clipboard text as a here string' `
        -ScriptBlock {
        param($key, $arg)

        Add-Type -Assembly PresentationCore
        if ([System.Windows.Clipboard]::ContainsText()) {
            # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
            $text = ([System.Windows.Clipboard]::GetText() -replace "\p{Zs}*`r?`n", "`n").TrimEnd()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("@'`n$text`n'@")
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
        }
    }
}

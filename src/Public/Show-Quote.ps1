function Show-Quote {
    <#
        .Synopsis
            Pretty print a quote.
        .Notes
            The quote must be a single-line string with the quote attribution
            after the last '--'.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        # The text to format.
        $Text,
        [Int]
        # Width of the displayed qoute.
        $Width = 50,
        [string]$BackgroundColor = $PSStyle.Background.Black,
        [string]$FrameColor = $PSStyle.Foreground.BrightWhite,
        [string]$QuoteColor = $PSStyle.Foreground.BrightYellow,
        [string]$AttribColor = $PSStyle.Foreground.BrightCyan
    )

    $quoteMatch = ([Regex]'^(?<text>.+)\s*--(?!.*--)\s*(?<attrib>.+)$').Match($Text.Trim())

    if ($quoteMatch.Success) {
        $quote = $quoteMatch.Groups['text'].Value
        $attrib = $quoteMatch.Groups['attrib'].Value
    } else {
        $quote = $Text.Trim()
        $attrib = $null
    }

    $myStack = New-Object System.Collections.Queue
    $quote -split ' ' | ForEach-Object { $myStack.Enqueue($_) }

    $leftIndent = '  '
    $rightOutdent = "  $($PSStyle.Reset)"
    $tl = "${FrameColor}┌"
    $tr = "${FrameColor}┐"
    $bl = "${FrameColor}└"
    $br = "${FrameColor}┘"
    $vr = "${FrameColor}│"
    $hr = "${FrameColor}─"
    $hd = "${FrameColor}┬"

    $blankLine = "$BackgroundColor" + (' ' * ($Width + 6))

    Write-Host $blankLine
    Write-Host -Object ($BackgroundColor + $leftIndent + $tl + ($hr * $Width) + $tr + $rightOutdent)

    $count = 0
    $curLine = ''
    while ($myStack.Count -gt 0) {
        if (($curLine + ' ' + $myStack.Peek()).Length -gt ($Width - 2)) {
            Write-Host -Object ("$BackgroundColor$leftIndent{0}$QuoteColor{1,-$($Width)}{0}$rightOutdent" -f $vr, $curLine)
            $curLine = ' ' + $myStack.Dequeue()
        } else {
            $count++
            $curLine += ' ' + $myStack.Dequeue()
        }
    }
    Write-Host -Object ("$BackgroundColor$leftIndent{0}$QuoteColor{1,-$Width}{0}$RightOutdent" -f $vr, $curLine)

    if ($null -ne $attrib) {
        Write-Host -Object ("$BackgroundColor$leftIndent{0}{1}{1}{2}{3}{4}$RightOutdent" -f $bl, $hr, $hd, ($hr * ($Width - 3)), $br)
        Write-Host -Object ("$BackgroundColor$leftIndent   {0} $AttribColor{1,-$($Width - 3)}$RightOutdent" -f $bl, $attrib)
    } else {
        Write-Host -Object ("$BackgroundColor$leftIndent{0}{1}{1}{2}{3}{4}$RightOutdent" -f $bl, $hr, $hr, ($hr * ($Width - 3)), $br)
    }

    Write-Host $blankLine
}

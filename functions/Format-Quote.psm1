function Format-Quote {
    <#
        .Synopsis
            Pretty print a quote.
        .Notes
            The quote must be a single-line string with the quote attribution
            after the last '--'.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        # The text to format.
        $Text,
        [Int]
        # Width of the displayed qoute.
        $Width = 50
    )

    $splitQuote = ($Text -split "--") | ForEach-Object { $_.Trim() }
    $quote = $splitQuote[0]
    $attrib = $splitQuote[1]
    $myStack = New-Object System.Collections.Queue
    $quote -split " " | ForEach-Object { $myStack.Enqueue($_) }

    $leftIndent = "  "
    $tl = "┌"
    $tr = "┐"
    $bl = "└"
    $br = "┘"
    $vr = "│"
    $hr = "─"
    $hd = "┬"


    $color = 'yellow'
    Write-Host -ForegroundColor $color -Object ($leftIndent + $tl + ($hr * $Width) + $tr)

    $count = 0
    $curLine = ""
    while ($myStack.Count -gt 0) {
        if (($curLine + " " + $myStack.Peek()).Length -gt ($Width - 2)) {
            Write-Host -ForegroundColor $color -Object ("$leftIndent{0}{1,-$($Width)}{0}" -f $vr, $curLine)
            $curLine = " " + $myStack.Dequeue()
        } else {
            $count++
            $curLine += " " + $myStack.Dequeue()
        }
    }
    Write-Host -ForegroundColor $color -Object ("$leftIndent{0}{1,-$Width}{0}" -f $vr, $curLine)
    Write-Host -ForegroundColor $color -Object ("$leftIndent{0}{1}{1}{2}{3}{4}" -f $bl, $hr, $hd, ($hr * ($Width - 3)), $br)
    Write-Host -ForegroundColor $color -Object ("$leftIndent   {0} {1}" -f $bl, $attrib)
    Write-Host -ForegroundColor $color -Object ("")
}

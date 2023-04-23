$VerboseDepth = 0
$VerboseBlockName = [System.Collections.Stack]::new()
Function VerboseBlock {
    param(
        [Parameter(Mandatory = $true)]
        $Name,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Scriptblock
    )

    try {
        if ($ProfileDebugMode) {
            WriteDebug "🔽 '$($PSStyle.Foreground.BrightYellow)$Name$($PSStyle.Reset)'"
        }

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $script:VerboseDepth++
        $script:VerboseBlockName.Push($Name)

        $Scriptblock.Invoke()

        $sw.Stop
        $nameArray = $script:VerboseBlockName.ToArray()
        [array]::Reverse($nameArray)
        $fullName = [string]::Join( '  ', $nameArray)
        $script:timers += [PSCustomObject]@{ Name = $fullName; Timer = $sw.ElapsedMilliseconds }
        $null = $script:VerboseBlockName.Pop()
        $script:VerboseDepth--

        if ($ProfileDebugMode) {
            WriteDebug "🔼 '$($PSStyle.Foreground.BrightYellow)$Name$($PSStyle.Reset)' $($sw.ElapsedMilliseconds)ms"
        }
    } catch {
        WriteError "Unhandled Error in VerboseBlock '$Name': $_"
        throw
    }
}

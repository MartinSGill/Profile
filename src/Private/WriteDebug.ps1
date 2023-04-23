function WriteDebug() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Message
    )

    if ($ProfileDebugMode) {
        $space = "  " * $VerboseDepth
        Write-Information "${messagePrefix}$($PSStyle.Foreground.Cyan)DEBUG$($PSStyle.Reset): ${space}${Message}" -Tags @('MartinsProfile', 'Debug') -InformationAction "Continue"
    }
}

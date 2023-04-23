function WriteError() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Message
    )
    $space = "  " * $script:VerboseDepth
    Write-Information "${messagePrefix}$($PSStyle.Foreground.Red)ERROR$($PSStyle.Reset): ${space}${Message}" -Tags @('MyPro', 'Error') -InformationAction "Continue"
}

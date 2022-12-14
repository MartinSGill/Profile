
if (@(Get-Module Az -ListAvailable).Length -gt 0) {
    Write-MyProDebug "Found 'Az Module', registering completer."

    #Import-Module Az.Tools.Predictor
    if (-not $?) {
        Write-MyProWarning "Found 'Az Module' but not 'Az.Tools.Predictor' module; installing."
        Install-Module -Name Az.Tools.Predictor
        Import-Module Az.Tools.Predictor
    }
    #Enable-AzPredictor
}

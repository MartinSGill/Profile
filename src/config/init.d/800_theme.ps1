## Colors / Formatting
VerboseBlock "Theme" {
    $PSStyle.Formatting.Debug = $PSStyle.Foreground.BrightBlue
    $PSStyle.Formatting.Verbose = $PSStyle.Foreground.BrightBlack
    $PSStyle.Formatting.Warning = $PSStyle.Foreground.BrightYellow
    $PSStyle.Formatting.Error = $PSStyle.Foreground.BrightRed

    # UI Progress Indicator for WindowsTerminal & ConEmu
    $PSStyle.Progress.UseOSCIndicator = $true

    if ($ProfileDebugMode) {
        Write-Debug "Example Debug Message" -Debug
        Write-Verbose "Example Verbose Message" -Verbose
        Write-Warning "Example Warning Message" -WarningAction 'Continue'
        Write-Information "Example Information Message" -InformationAction 'Continue'
        Write-Host "Example Host Message"
    }

    VerboseBlock "Posh-Git" {
        $env:POSH_GIT_ENABLED = $true
    }

    VerboseBlock "Oh-My-Posh" {
        oh-my-posh init pwsh --config "$PSScriptRoot/../themes/mytheme.omp.json" | Invoke-Expression
    }
}

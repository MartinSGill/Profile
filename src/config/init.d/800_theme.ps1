## Colors / Formatting
VerboseBlock "Theme" {
    $PSStyle.Formatting.Debug = $PSStyle.Blue
    $PSStyle.Formatting.Verbose = $PSStyle.Foreground.Cyan
    $PSStyle.Formatting.Warning = $PSStyle.Foreground.Yellow
    $PSStyle.Formatting.Error = $PSStyle.Foreground.BrightRed

    # UI Progress Indicator for WindowsTerminal & ConEmu
    $PSStyle.Progress.UseOSCIndicator = $true

    if ($ProfileDebugMode) {
        Write-Host "$($PSStyle.Formatting.Debug)Debug $($PSStyle.Formatting.Verbose)Verbose $($PSStyle.Formatting.Warning)Warning $($PSStyle.Formatting.Error)Error $($PSStyle.Reset)"
    }

    VerboseBlock "Posh-Git" {
        $env:POSH_GIT_ENABLED = $true
    }

    VerboseBlock "Oh-My-Posh" {
        oh-my-posh init pwsh --config "$PSScriptRoot/../themes/my-tokyo.omp.json" | Invoke-Expression
    }
}

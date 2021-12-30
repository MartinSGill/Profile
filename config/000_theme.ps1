## Colors / Formatting
VerboseBlock "Colors / Formatting" {
    if ($isPwsh72) {
        $PSStyle.Formatting.Debug = $PSStyle.Foreground.BrightBlue
        $PSStyle.Formatting.Verbose = $PSStyle.Foreground.BrightBlack
        $PSStyle.Formatting.Warning = $PSStyle.Foreground.BrightYellow
        $PSStyle.Formatting.Error = $PSStyle.Foreground.BrightRed

        # UI Progress Indicator for WindowsTerminal & ConEmu
        $PSStyle.Progress.UseOSCIndicator = $true
    } else {
        $Host.PrivateData.VerboseForegroundColor = [System.ConsoleColor]::Gray
        $Host.PrivateData.DebugForegroundColor = [System.ConsoleColor]::DarkBlue
        $Host.PrivateData.WarningForegroundColor = [System.ConsoleColor]::Yellow
        $Host.PrivateData.ErrorForegroundColor = [System.ConsoleColor]::Red
    }

    if ($ProfileDebugMode) {
        Write-Debug "Example Debug Message" -Debug
        Write-Verbose "Example Verbose Message" -Verbose
        Write-Warning "Example Warning Message" -WarningAction 'Continue'
        Write-Information "Example Information Message" -InformationAction 'Continue'
        Write-Host "Example Host Message"
    }

    VerboseBlock "PS Readline" {
        Import-Module Terminal-Icons
        Update-PSReadLine
    }

    VerboseBlock "Posh-Git" {
        Import-Module posh-git
        $env:POSH_GIT_ENABLED = $true
    }

    VerboseBlock "Oh-My-Posh" {
        Import-Module oh-my-posh
        Set-PoshPrompt -Theme night-owl
    }
}

function Set-MyPrompt {
    [CmdletBinding()]
    param()

    # Clear out any existing settings
    Remove-Item -Path (Get-ConfigurationPath -Module (Get-Module Powerline)) -Force -Recurse

    if (Get-Module posh-git) {
        if ($PromptUseSafeCharacters) {
            $GitPromptSettings.BeforeStatus.Text = "["
            $GitPromptSettings.DelimStatus.Text = " |"
            $GitPromptSettings.AfterStatus.Text = "]"
        } else {
            $GitPromptSettings.BeforeStatus.Text = "{0} " -f [PoshCode.Pansies.Entities]::ExtendedCharacters.Branch
            $GitPromptSettings.DelimStatus.Text = " | " -f [PoshCode.Pansies.Entities]::ExtendedCharacters.Separator
            $GitPromptSettings.AfterStatus.Text = " "
        }
    }

    $plArgs = @{
        RestoreVirtualTerminal = $true
        FullColor = $true
        SetCurrentDirectory = $true
        PowerLineFont = (-not $PromptUseSafeCharacters)
        Prompt = @()
        Save = $false
    }

    $plArgs.Prompt += {
        if($pushed = (Get-Location -Stack).count) {
            $pArgs = @{
                InputObject = "&raquo;$pushed"
                ForegroundColor = "White"
                BackgroundColor = "SlateBlue"
            }
            New-PromptText @pArgs
        }
    }

    $plArgs.Prompt += { New-PromptText (Get-PromptPathString) -ForegroundColor "Black" -BackgroundColor "White" }

    # $plArgs.Prompt += { "`t" }

    $plArgs.Prompt += {
        if (-not [string]::IsNullOrWhiteSpace($(Get-Elapsed)) ) {
            $pArgs = @{
                InputObject = " 祥 $(Get-Elapsed -Format "{0:ss\.ffff}") "
                ForegroundColor = "Black"
                BackgroundColor = "#E7FFAC"
                ErrorForegroundColor = "Black"
                ErrorBackgroundColor = "#FFABAB"
            }

            if ($PromptUseSafeCharacters) {
                $pArgs.InputObject = " $(Get-Elapsed -Format "{0:ss\.ffff}") "
            }

            New-PromptText @pArgs
        }
    }

    if (Get-Module posh-git) {
        $plArgs.Prompt += { New-PromptText -InputObject "$(Write-VcsStatus)" -ForegroundColor "white" -BackgroundColor "black" }
    }

    $plArgs.Prompt += { "`n" }

    $plArgs.Prompt += {
        $pArgs = @{
            InputObject = "  $(Get-Date -Format "T") "
            ForegroundColor = "Black"
            BackgroundColor = "#BFFCC6"
        }
        if ($PromptUseSafeCharacters) {
            $pArgs.InputObject = " $(Get-Date -Format "T") "
        }
        New-PromptText @pArgs
    }

    $plArgs.Prompt += {
        $pArgs = @{
            InputObject = " $("{0}" -f $PSVersionTable.PSVersion.Major) ﲵ"
            ForegroundColor = "Black"
            BackgroundColor = "#6EB5FF"
            ElevatedForegroundColor = "Black"
            ElevatedBackgroundColor = "#FFABAB"
        }
        if ($PromptUseSafeCharacters) {
            InputObject = " $("{0}" -f $PSVersionTable.PSVersion.Major) >_"
        }
        New-PromptText @pArgs
    }

    Set-PowerLinePrompt @plArgs
    Trace-Message "Prompt Set."
}

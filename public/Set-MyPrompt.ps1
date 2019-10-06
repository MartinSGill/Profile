function Set-MyPrompt {
    [CmdletBinding()]
    param(
        # Don't use the special PowerLine characters
        [Switch]$SafeCharacters
    )

    # Clear out any existing settings
    Remove-Item -Path (Get-ConfigurationPath -Module (Get-Module Powerline)) -Force -Recurse

    if (Get-Module posh-git) {
        if ($SafeCharacters) {
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
        PowerLineFont = (-not $SafeCharacters)
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

    $plArgs.Prompt += { Get-SegmentedPath -SegmentLimit 6 -ForegroundColor "Black" -BackgroundColor "White" }

    # $plArgs.Prompt += { "`t" }

    if ($SafeCharacters) {
        $plArgs.Prompt += {
            if (-not [string]::IsNullOrWhiteSpace($(Get-Elapsed)) ) {
                $pArgs = @{
                    InputObject = " $(Get-Elapsed -Format "{0:ss\.ffff}") "
                    ForegroundColor = "Black"
                    BackgroundColor = "#E7FFAC"
                    ErrorForegroundColor = "Black"
                    ErrorBackgroundColor = "#FFABAB"
                }
                New-PromptText @pArgs
            }
        }
    } else {
        $plArgs.Prompt += {
            if (-not [string]::IsNullOrWhiteSpace($(Get-Elapsed)) ) {
                $pArgs = @{
                    InputObject = " 祥 $(Get-Elapsed -Format "{0:ss\.ffff}") "
                    ForegroundColor = "Black"
                    BackgroundColor = "#E7FFAC"
                    ErrorForegroundColor = "Black"
                    ErrorBackgroundColor = "#FFABAB"
                }
                New-PromptText @pArgs
            }
        }
    }

    if (Get-Module posh-git) {
        $plArgs.Prompt += { New-PromptText -InputObject "$(Write-VcsStatus)" -ForegroundColor "white" -BackgroundColor "black" }
    }

    $plArgs.Prompt += { "`n" }

    if ($SafeCharacters) {
        $plArgs.Prompt += {
            $pArgs = @{
                InputObject = " $(Get-Date -Format "T") "
                ForegroundColor = "Black"
                BackgroundColor = "#BFFCC6"
            }
            New-PromptText @pArgs
        }
    } else {
        $plArgs.Prompt += {
            $pArgs = @{
                InputObject = "  $(Get-Date -Format "T") "
                ForegroundColor = "Black"
                BackgroundColor = "#BFFCC6"
            }
            New-PromptText @pArgs
        }
    }

    $plArgs.Prompt += {
        $pArgs = @{
            InputObject = " $("{0}" -f $PSVersionTable.PSVersion.Major) >_ "
            ForegroundColor = "Black"
            BackgroundColor = "#6EB5FF"
            ElevatedForegroundColor = "Black"
            ElevatedBackgroundColor = "#FFABAB"
        }
        New-PromptText @pArgs
    }

    Set-PowerLinePrompt @plArgs
    Trace-Message "Prompt Set."
}

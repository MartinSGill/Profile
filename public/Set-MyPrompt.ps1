

$promptElements = @{
    DirStack = {
        if($pushed = (Get-Location -Stack).count) {
            $pArgs = @{
                InputObject = "&raquo;$pushed"
                ForegroundColor = "White"
                BackgroundColor = "SlateBlue"
            }
            New-PromptText @pArgs
        }
    }

    Path = { New-PromptText (Get-PromptPathString) -ForegroundColor "Black" -BackgroundColor "White" }

    LastCommandTime = {
        if (-not [string]::IsNullOrWhiteSpace($(Get-Elapsed)) ) {
            $useSafeChars = [bool]$env:PROFILE_SAFE_CHARS
            $pArgs = @{
                InputObject = " 祥 $(Get-Elapsed -Format "{0:ss\.ffff}") "
                ForegroundColor = "Black"
                BackgroundColor = "#E7FFAC"
                ErrorForegroundColor = "Black"
                ErrorBackgroundColor = "#FFABAB"
            }

            if ($useSafeChars) {
                $pArgs.InputObject = " $(Get-Elapsed -Format "{0:ss\.ffff}") "
            }

            New-PromptText @pArgs
        }
    }

    AlignRight = { "`t" }

    NewLine =  { "`n" }

    VcsStatus = { New-PromptText -InputObject "$(Write-VcsStatus)" -ForegroundColor "white" -BackgroundColor "black" }

    Time = {
        $useSafeChars = [bool]$env:PROFILE_SAFE_CHARS
        $pArgs = @{
            InputObject = "  $(Get-Date -Format "T") "
            # InputObject = " T $(Get-Date -Format "T") "
            ForegroundColor = "Black"
            BackgroundColor = "#BFFCC6"
        }
        if ($useSafeChars) {
            $pArgs.InputObject = " $(Get-Date -Format "T") "
        }
        New-PromptText @pArgs
    }

    Prompt = {
        $useSafeChars = [bool]$env:PROFILE_SAFE_CHARS
        $pArgs = @{
            InputObject = " $($PSVersionTable.PSVersion.Major)  "
            #InputObject = " $($PSVersionTable.PSVersion.Major) ﲵ"
            ForegroundColor = "Black"
            BackgroundColor = "#6EB5FF"
            ElevatedForegroundColor = "Black"
            ElevatedBackgroundColor = "#FFABAB"
        }
        if ($useSafeChars) {
            $pArgs.InputObject = " $($PSVersionTable.PSVersion.Major) >_"
        }
        New-PromptText @pArgs
    }
}



function Set-MyPrompt {
    <#
    .SYNOPSIS
        Configures preferred prompt format.
    .Notes
        Set $env:PROFILE_SAFE_CHARS to force non-Powerline font characters.
    #>
    [CmdletBinding()]
    param()

    # Clear out any existing settings
    Remove-Item -Path (Get-ConfigurationPath -Module (Get-Module Powerline)) -Force -Recurse

    if (Get-Module posh-git) {
        $useSafeChars = [bool]$env:PROFILE_SAFE_CHARS
        if ($useSafeChars) {
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
        PowerLineFont = (-not $useSafeChars)
        Prompt = @()
        Save = $false
    }

    $plArgs.Prompt += $promptElements.DirStack
    $plArgs.Prompt += $promptElements.Path
    # $plArgs.Prompt += $promptElements.AlignRight
    $plArgs.Prompt += $promptElements.LastCommandTime
    if (Get-Module posh-git) { $plArgs.Prompt += $promptElements.VcsStatus }
    $plArgs.Prompt += $promptElements.NewLine
    $plArgs.Prompt += $promptElements.Time
    $plArgs.Prompt += $promptElements.Prompt

    Set-PowerLinePrompt @plArgs
    Trace-Message "Prompt Set."
}

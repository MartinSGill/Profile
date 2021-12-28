
## Detect DEBUG Mode

# Detect Shift Key
if (("Desktop" -eq $PSVersionTable.PSEdition) -or ($PSVersionTable.PSVersion.Major -ge 7)) {
    try {
        # Check SHIFT state ASAP at startup so I can use that to control verbosity :)
        Add-Type -Assembly PresentationCore, WindowsBase
        if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -OR
            [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
            $ProfileDebugMode = "true"
        }
    } catch {
        # If that didn't work ... oh well.
    }
}

$isPwsh72 = $PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 2
$moduleNamespace = "PRF"
$prefix = "${moduleNamespace}: "

if ($env:ProfileDebugMode) {
    $ProfileDebugMode = "true"
}

$script:VerboseDepth = 0

Function Write-PrfDebug ($Message) {
    if ($ProfileDebugMode) {
        Write-Host "${prefix}$($PSStyle.Foreground.LightBlue)DEBUG$($PSStyle.Foreground.White): $Message"
    }
}

Function VerboseBlock {
    param(
        [Parameter(Mandatory=$true)]
        $Name,
        [Parameter(Mandatory=$true)]
        [scriptblock]$Scriptblock
    )

    $space = "  " * $script:VerboseDepth++

    if ($ProfileDebugMode) {
        Write-PrfDebug "$space$($PSStyle.Foreground.LightCyan)📖$($PSStyle.Foreground.Cyan)'$($PSStyle.Foreground.LightYellow)$Name$($PSStyle.Foreground.Cyan)'$($PSStyle.Reset)"
    }

    $Scriptblock.Invoke()

    if ($ProfileDebugMode) {
        Write-PrfDebug "$space$($PSStyle.Foreground.LightGreen)📕$($PSStyle.Foreground.Cyan)'$($PSStyle.Foreground.LightYellow)$Name$($PSStyle.Foreground.Cyan)'$($PSStyle.Reset)"
    }

    $script:VerboseDepth--
}

## Load Functions
$requiredModules = @(
    @{ Name = "PSReadline"; MinimumVersion = "2.2.0" }
    @{ Name = "Terminal-Icons" }
    @{ Name = "posh-git" }
    @{ Name = "oh-my-posh" }
)

VerboseBlock "Checking Modules" {
    $requiredModules | ForEach-Object {
        $_.Found = (Get-Module $_.Name -ListAvailable | Select-Object -First 1).Version

        Write-PrfDebug "    🔎 $($_.Name) $($_.MinimumVersion) 🎯 $($_.Found)"

        if ($null -eq $_.Found) {
            Write-Warning "${prefix}Missing module $($_.Name)"
        } elseif ($null -ne $_.MinimumVersion -and [Version]::new($_.MinimumVersion) -lt $_.Found) {
            Write-Warning "${prefix}Expected module $($_.Name) to >= $($_.MinimumVersion). Found $($_.Found)"
        }
    }
}

VerboseBlock "Functions" {
    @("Humanizer", "Types", "functions", "auto-completers") | ForEach-Object {
        Get-ChildItem -Path (Join-Path $PSScriptRoot $_) -Filter "*.psm1" | ForEach-Object {
            Write-Verbose "${prefix}Sourcing: '$_.Name'"
            Import-Module $_
        }
    }
}

## Colors / Formatting
VerboseBlock "Colors / Formatting" {
    if ($isPwsh72) {
        $PSStyle.Formatting.Debug = $PSStyle.Foreground.Blue
        $PSStyle.Formatting.Verbose = $PSStyle.Foreground.LightGray
        $PSStyle.Formatting.Warning = $PSStyle.Foreground.Yellow
        $PSStyle.Formatting.Error = $PSStyle.Foreground.Red

        $PSStyle.Progress.UseOSCIndicator = $true
    } else {
        $Host.PrivateData.VerboseForegroundColor = [System.ConsoleColor]::Gray
        $Host.PrivateData.DebugForegroundColor = [System.ConsoleColor]::DarkBlue
        $Host.PrivateData.WarningForegroundColor = [System.ConsoleColor]::Yellow
        $Host.PrivateData.ErrorForegroundColor = [System.ConsoleColor]::Red
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
        Set-PoshPrompt -Theme (Join-Path $PSScriptRoot 'themes' -AdditionalChildPath 'mytheme.omp.json')
    }
}

VerboseBlock "Auto-Completers" {
    Add-AutoCompleters
}

VerboseBlock "Aliases" {
    Update-ToolPath
}

if ($PSVersionTable.Platform -eq "Windows") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
}

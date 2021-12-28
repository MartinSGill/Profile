
########
# Debug Mode
########
if (("Desktop" -eq $PSVersionTable.PSEdition) -or ($PSVersionTable.PSVersion.Major -ge 7)) {
    # Detect Shift Key
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

if ($env:ProfileDebugMode) {
    $ProfileDebugMode = "true"
}

########
# Critical Variables
########
$isPwsh72 = $PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 2
$moduleNamespace = "MyPro"
$messagePrefix = "$($PSStyle.Foreground.Blue)${moduleNamespace}$($PSStyle.Reset): "

########
# Critical Functions
########
Function Write-PrfDebug ($Message) {
    if ($ProfileDebugMode) {
        Write-Host "${messagePrefix}$($PSStyle.Foreground.Cyan)DEBUG$($PSStyle.Reset): ${Message}"
    }
}

Function Write-PrfError ($Message) {
    Write-Error "${messagePrefix}${Message}"
}

function Write-PrfWarning ($Message) {
    Write-Warning "${messagePrefix}${Message}"
}

$script:VerboseDepth = 0
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

########
# Setup Profile
########
$abort = $false
VerboseBlock "Checking Modules" {

    $requiredModules = @(
        @{ Name = "PSReadline"; MinimumVersion = "2.2.0" }
        @{ Name = "Terminal-Icons" }
        @{ Name = "posh-git" }
        @{ Name = "oh-my-posh" }
    )

    $requiredModules | ForEach-Object {
        $_.Found = (Get-Module $_.Name -ListAvailable | Select-Object -First 1).Version

        Write-PrfDebug "    🔎 $($_.Name) $($_.MinimumVersion) 🎯 $($_.Found)"

        if ($null -eq $_.Found) {
            $abort = $true
            Write-Error "${prefix}Missing module $($_.Name)"
        } elseif ($null -ne $_.MinimumVersion -and [Version]::new($_.MinimumVersion) -lt $_.Found) {
            $abort = $true
            Write-Error "${prefix}Expected module $($_.Name) to >= $($_.MinimumVersion). Found $($_.Found)"
        }
    }
}

if ($abort) {
    throw "Aborting Profile Import."
}

VerboseBlock "Functions" {
    $script:publicFunctions =  @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
    $privateFunctions =  @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

    foreach($import in @($publicFunctions + $privateFunctions))
    {
        try
        {
            Write-PrfDebug "Importing $($import.BaseName)"
            . $import.FullName
        }
        catch
        {
            Write-Error -Message "Failed to import function $($import.FullName): $_"
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

VerboseBlock "Exports" {
    foreach ($item in $publicFunctions) {
        Write-PrfDebug "Exporting $($item.BaseName)"
        Export-ModuleMember -Function $item.BaseName
    }

}

if ($PSVersionTable.Platform -eq "Windows") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
}

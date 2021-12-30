
$moduleSw = [System.Diagnostics.Stopwatch]::StartNew()
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

if ($env:MyProfileDebugMode) {
    $ProfileDebugMode = "true"
}

########
# Critical Variables
########
$isPwsh72 = $PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 2
$moduleNamespace = "MyPro"
$messagePrefix = "$($PSStyle.Foreground.BrightBlack)${moduleNamespace}$($PSStyle.Reset): "

########
# Critical Functions
########
function Write-MyProDebug ($Message) {
    if ($ProfileDebugMode) {
        $space = "  " * $script:VerboseDepth
        Write-Information "${messagePrefix}$($PSStyle.Foreground.Cyan)DEBUG$($PSStyle.Reset): ${space}${Message}" -Tags @('MyPro', 'Debug') -InformationAction "Continue"
    }
}

function Write-MyProError ($Message) {
    Write-Error "${messagePrefix}${Message}"
}

function Write-MyProWarning ($Message) {
    Write-Warning "${messagePrefix}${Message}"
}

if ($ProfileDebugMode) {
    Write-MyProDebug ">>> MyProfile Runing in DEBUG Mode <<<"
}

$script:VerboseDepth = 0
Function VerboseBlock {
    param(
        [Parameter(Mandatory=$true)]
        $Name,
        [Parameter(Mandatory=$true)]
        [scriptblock]$Scriptblock
    )

    if ($ProfileDebugMode) {
        Write-MyProDebug "🔽 '$($PSStyle.Foreground.BrightYellow)$Name$($PSStyle.Reset)'"
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $script:VerboseDepth++

    $Scriptblock.Invoke()

    $script:VerboseDepth--
    $sw.Stop

    if ($ProfileDebugMode) {
        Write-MyProDebug "🔼 '$($PSStyle.Foreground.BrightYellow)$Name$($PSStyle.Reset)' $($sw.ElapsedMilliseconds)ms"
    }
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

        Write-MyProDebug "    🔎 $($_.Name) $($_.MinimumVersion) 🎯 $($_.Found)"

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
    $script:publicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
    $privateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

    foreach($import in @($publicFunctions + $privateFunctions))
    {
        try
        {
            Write-MyProDebug "Importing $($import.BaseName)"
            . $import.FullName
        }
        catch
        {
            Write-Error -Message "Failed to import function $($import.FullName): $_"
        }
    }
}

VerboseBlock "Check for Update" {
    if (Test-Path "$PSScriptRoot\.git") {
        if (Test-MyProCommand -Name git) {
            $null = git fetch
            $count = git rev-list --count master..origin/master
            if ($count -gt 0) {
                Write-Host "$($PSStyle.Forground.BrightGreen)MyProfile Update Available"
            } else {
                Write-MyProDebug "Local repo up-to-date with remote."
            }
        } else {
            Write-MyProDebug "GIT Cli not available. Skipping."
        }
    } else {
        Write-MyProDebug "Not a GIT repo. Skipping."
    }
}

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

VerboseBlock "Auto-Completers" {
    $autoCompleters =  @( Get-ChildItem -Path $PSScriptRoot\Private\auto-completers\*.ps1 -ErrorAction SilentlyContinue )
    foreach ($item in $autoCompleters) {
        try
        {
            Write-MyProDebug "Sourcing Completer: $($item.BaseName)"
            . $item.FullName
        }
        catch
        {
            Write-Error -Message "Failed to import function $($import.FullName): $_"
        }
    }
}

VerboseBlock "Aliases" {
    Update-ToolPath
}

VerboseBlock "Exports" {
    foreach ($item in $publicFunctions) {
        Write-MyProDebug "Exporting $($item.BaseName)"
        Export-ModuleMember -Function $item.BaseName
    }
}

VerboseBlock "Format Views" {
    Import-MyProHumanizer
    $formats = @( Get-ChildItem -Path $PSScriptRoot\Formats\*.formats.ps1xml -ErrorAction SilentlyContinue )
    foreach ($item in $formats) {
        Write-MyProDebug "Add Format View $($item.BaseName)"
        Update-FormatData -PrependPath $item
    }
}

VerboseBlock "Type Views" {
    $formats = @( Get-ChildItem -Path $PSScriptRoot\Types\*.types.ps1xml -ErrorAction SilentlyContinue )
    foreach ($item in $formats) {
        Write-MyProDebug "Add Type View $($item.BaseName)"
        Update-TypeData -PrependPath $item
    }
}

VerboseBlock "Drives" {
    $drives = @(
        @{ Name = 'dbox'; Root = (Get-MyProDropboxFolder -WarningAction 'SilentlyContinue'); PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'repo'; Root = '~\source\repos'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'src'; Root = 'c:\source'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'src'; Root = '\source'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'mypro'; Root = $PSScriptRoot; PSProvider = 'FileSystem'; Scope = 'Global' }
    )

    foreach ($drive in $drives) {
        if ($null -ne $drive.Root -and (Test-Path $drive.Root)) {
            Write-MyProDebug "Adding '$($drive.Name)' drive --> '$($drive.Root)'"
            New-PSDrive @drive
        }
    }
}

if ($PSVersionTable.Platform -eq "Windows") {
    Write-MyProDebug "Setting Execution Policy to RemoteSigned"
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
}

if ($null -eq $env:TERM) {
    Write-MyProDebug "TERM not set, setting to 'xterm'"
    $env:TERM = 'xterm'
}

$moduleSw.Stop()
Write-Information "$($PSStyle.Foreground.BrightYellow)MyProfile$($PSStyle.Foreground.BrightBlue) processed in $($PSStyle.Foreground.BrightYellow)$($moduleSw.ElapsedMilliseconds)$($PSStyle.Foreground.BrightBlue)ms.$($PSStyle.Reset)" -InformationAction 'Continue' -Tags @($moduleNamespace)

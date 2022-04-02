
$moduleSw = [System.Diagnostics.Stopwatch]::StartNew()
$script:timers = @()
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
function Write-MyProDebug() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Message
    )

    if ($ProfileDebugMode) {
        $space = "  " * $script:VerboseDepth
        Write-Information "${messagePrefix}$($PSStyle.Foreground.Cyan)DEBUG$($PSStyle.Reset): ${space}${Message}" -Tags @('MyPro', 'Debug') -InformationAction "Continue"
    }
}

function Write-MyProError() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Message
    )
    $space = "  " * $script:VerboseDepth
    Write-Information "${messagePrefix}$($PSStyle.Foreground.Red)ERROR$($PSStyle.Reset): ${space}${Message}" -Tags @('MyPro', 'Error') -InformationAction "Continue"
}

if ($ProfileDebugMode) {
    Write-MyProDebug ">>> MyProfile Runing in DEBUG Mode <<<"
}

$script:VerboseDepth = 0
$script:VerboseBlockName = [System.Collections.Stack]::new()
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
    $script:VerboseBlockName.Push($Name)

    $Scriptblock.Invoke()

    $sw.Stop
    $nameArray = $script:VerboseBlockName.ToArray()
    [array]::Reverse($nameArray)
    $fullName = [string]::Join( "  ", $nameArray)
    $script:timers += [PSCustomObject]@{ Name = $fullName; Timer = $sw.ElapsedMilliseconds }
    $null = $script:VerboseBlockName.Pop()
    $script:VerboseDepth--

    if ($ProfileDebugMode) {
        Write-MyProDebug "🔼 '$($PSStyle.Foreground.BrightYellow)$Name$($PSStyle.Reset)' $($sw.ElapsedMilliseconds)ms"
    }
}

########
# Setup Profile
########
$script:abort = $false
VerboseBlock "Checking Modules" {

    $requiredModules = @(
        @{ Name = "PSReadline"; MinimumVersion = "2.2.0" }
        @{ Name = "Terminal-Icons" }
        @{ Name = "posh-git" }
        @{ Name = "oh-my-posh" }
    )

    $requiredModules | ForEach-Object {
        $_.Found = (Get-Module $_.Name -ListAvailable | Select-Object -First 1).Version

        Write-MyProDebug "🎯 $($_.Name) $($_.MinimumVersion) 🔎 $($_.Found)"

        if ($null -eq $_.Found) {
            $script:abort = $true
            Write-MyProError "${prefix}Missing module $($_.Name)"
        } elseif ($null -ne $_.MinimumVersion -and [Version]::new($_.MinimumVersion) -lt $_.Found) {
            $script:abort = $true
            Write-MyProError "${prefix}Expected module $($_.Name) to >= $($_.MinimumVersion). Found $($_.Found)"
        }
    }
}

if ($script:abort) {
    Write-MyProError "Aborting Profile Import."
    throw "Aborting Profile Import."
}

VerboseBlock "Functions" {
    $script:publicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
    $privateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

    foreach($import in @($publicFunctions + $privateFunctions))
    {
        try
        {
            Write-MyProDebug "📥 $($import.BaseName)"
            . $import.FullName
        }
        catch
        {
            Write-MyProError -Message "Failed to import function $($import.FullName): $_"
        }
    }
}

VerboseBlock "Exports" {
    foreach ($item in $publicFunctions) {
        Write-MyProDebug "📤 $($item.BaseName)"
        Export-ModuleMember -Function $item.BaseName
    }
}

VerboseBlock "Config Blocks" {
    $configs = @(Get-ChildItem -Path $PSScriptRoot\config\*.ps1 -ErrorAction SilentlyContinue ) | Sort-Object -Property Name
    foreach ($item in $configs) {
        Write-MyProDebug "⚙️ $($item.BaseName)"
        . $item.FullName
    }
}

$moduleSw.Stop()
$script:timers += @{ Name = 'Total'; Timer = $moduleSw.ElapsedMilliseconds }

$longest = ($script:timers | Sort-Object -Property @{ Expression = { $_.Name.Length } } -Descending | Select-Object -First 1).Name.Length
$script:timers | ForEach-Object {
    Write-MyProDebug ("⌛ {0,-$longest} {1,5} ms" -f $_.Name, $_.Timer)
}

Write-Information "⏲️ $($PSStyle.Foreground.BrightYellow)MyProfile$($PSStyle.Foreground.BrightBlue) processed in $($PSStyle.Foreground.BrightYellow)$($moduleSw.ElapsedMilliseconds)$($PSStyle.Foreground.BrightBlue)ms.$($PSStyle.Reset)" -InformationAction 'Continue' -Tags @($moduleNamespace)


$moduleSw = [System.Diagnostics.Stopwatch]::StartNew()
$script:timers = @()
########
# Debug Mode
########
if (('Desktop' -eq $PSVersionTable.PSEdition) -or ($PSVersionTable.PSVersion.Major -ge 7)) {
    # Detect Shift Key
    try {
        # Check SHIFT state ASAP at startup so I can use that to control verbosity :)
        Add-Type -Assembly PresentationCore, WindowsBase
        if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -OR
            [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
            $ProfileDebugMode = 'true'
        }
    } catch {
        # If that didn't work ... oh well.
    }
}

if ($env:MartinsProfileDebugMode) {
    $ProfileDebugMode = 'true'
}

########
# Critical Variables
########
$messagePrefix = "$($PSStyle.Foreground.BrightBlack)${moduleNamespace}$($PSStyle.Reset): "

if ($ProfileDebugMode) {
    WriteDebug '>>> MyProfile Runing in DEBUG Mode <<<'
}

$VerboseDepth = 0
$VerboseBlockName = [System.Collections.Stack]::new()

########
# Setup Profile
########

VerboseBlock 'Config Blocks' {
    $configs = @(Get-ChildItem -Path $PSScriptRoot\config\init.d\*.ps1 -ErrorAction SilentlyContinue ) | Sort-Object -Property Name
    foreach ($item in $configs) {
        WriteDebug "⚙️ $($item.BaseName)"
        . $item.FullName
    }
}

$moduleSw.Stop()
$script:timers += @{ Name = 'Total'; Timer = $moduleSw.ElapsedMilliseconds }

if ($ProfileDebugMode) {
    $longest = ($script:timers | Sort-Object -Property @{ Expression = { $_.Name.Length } } -Descending | Select-Object -First 1).Name.Length
    $script:timers | ForEach-Object {
        WriteDebug ("⌛ {0,-$longest} {1,5} ms" -f $_.Name, $_.Timer)
    }
}

$formats = Get-ChildItem -Path $PSScriptRoot/Formats -Filter '*.ps1xml'
Update-FormatData -PrependPath $formats

$types = Get-ChildItem -Path $PSScriptRoot/Types -Filter '*.ps1xml'
Update-TypeData -PrependPath $types


Write-Information "⏲️  $($PSStyle.Foreground.BrightYellow)MartinsProfile$($PSStyle.Foreground.BrightBlue) processed in $($PSStyle.Foreground.BrightYellow)$($moduleSw.ElapsedMilliseconds)$($PSStyle.Foreground.BrightBlue) ms.$($PSStyle.Reset)" -InformationAction 'Continue'

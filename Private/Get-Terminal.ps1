function script:Get-Terminal {
    [CmdletBinding()]
    param ()

    # if env:TERM is set, return that

    if (-not [string]::IsNullOrWhiteSpace($env:TERM)) {
        return $env:TERM
    }

    # VS Code
    if (-not [string]::IsNullOrWhiteSpace($env:TERM_PROGRAM)) {
        return $env:TERM_PROGRAM
    }

    # IntelliJ
    if (-not [string]::IsNullOrWhiteSpace($env:TERMINAL_EMULATOR)) {
        return $env:TERMINAL_EMULATOR
    }

    # Resort to Process Name
    $processName = (Get-Process -Id $PID).Parent.Name
    switch ($processName) {
        'code' { 'VSCode' }
        'idea64' { 'JetBrains-JediTerm' }
        'rider64' { 'JetBrains-JediTerm' }
        'WindowsTerminal' { 'Windows Terminal' }
        { $PSItem -in 'explorer', 'conhost' } { 'Windows Console' }
        'Console' { 'Console2/Z' }
        'ConEmuC64' { 'ConEmu' }
        'FluentTerminal.SystemTray' { 'Fluent Terminal' }
        Default { $PSItem }
    }
}

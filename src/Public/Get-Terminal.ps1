

enum Terminals {
    Unknown
    VsCode
    JetBrainsJediTerm
    WindowsTerminal
    WindowsConsole
    Console2Z
    ConEmu
    FluentTerminal
    AzureCloudShell
}

function Get-Terminal {
    [OutputType([Terminals])]
    [CmdletBinding()]
    param (
        [switch]$ListKnown
    )

    if ($ListKnown) {
        return [Terminals].GetEnumNames() | Select-Object -Skip 1
    }

    # VS Code
    if ($env:TERM_PROGRAM -eq 'vscode' ) {
        return [Terminals]::VsCode
    }

    # IntelliJ
    if ($env:TERMINAL_EMULATOR -eq 'JetBrains-JediTerm') {
        return [Terminals]::JetBrainsJediTerm
    }

    # AzureCloudShell
    if ($null -ne $env:ACC_CLOUD) {
        return [Terminals]::AzureCloudShell
    }

    # Resort to Process Name
    $processName = (Get-Process -Id $PID).Parent.Name
    switch ($processName) {
        'code' {
            [Terminals]::VsCode
        }
        'idea64' {
            [Terminals]::JetBrainsJediTerm
        }
        'rider64' {
            [Terminals]::JetBrainsJediTerm
        }
        'WindowsTerminal' {
            [Terminals]::WindowsTerminal
        }
        { $PSItem -in 'explorer', 'conhost' } {
            [Terminals]::WindowsConsole
        }
        'Console' {
            [Terminals]::Console2Z
        }
        'ConEmuC64' {
            [Terminals]::ConEmu
        }
        'FluentTerminal.SystemTray' {
            [Terminals]::FluentTerminal
        }
        Default {
            [Terminals]::Unknown
        }
    }
}

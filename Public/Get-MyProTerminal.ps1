

enum MyProTerminals {
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

function script:Get-MyProTerminal {
    [OutputType([MyProTerminals])]
    [CmdletBinding()]
    param (
        [switch]$ListKnown
    )

    if ($ListKnown) {
        return [MyProTerminals].GetEnumNames() | Select-Object -Skip 1
    }

    # VS Code
    if ($env:TERM_PROGRAM -eq "vscode" ) {
        return [MyProTerminals]::VsCode
    }

    # IntelliJ
    if ($env:TERMINAL_EMULATOR -eq "JetBrains-JediTerm") {
        return [MyProTerminals]::JetBrainsJediTerm
    }

    # AzureCloudShell
    if ($null -ne $env:ACC_CLOUD)  {
        return [MyProTerminals]::AzureCloudShell
    }

    # Resort to Process Name
    $processName = (Get-Process -Id $PID).Parent.Name
    switch ($processName) {
        'code' { [MyProTerminals]::VsCode }
        'idea64' { [MyProTerminals]::JetBrainsJediTerm }
        'rider64' { [MyProTerminals]::JetBrainsJediTerm }
        'WindowsTerminal' { [MyProTerminals]::WindowsTerminal }
        { $PSItem -in 'explorer', 'conhost' } { [MyProTerminals]::WindowsConsole }
        'Console' { [MyProTerminals]::Console2Z }
        'ConEmuC64' { [MyProTerminals]::ConEmu }
        'FluentTerminal.SystemTray' { [MyProTerminals]::FluentTerminal }
        Default { [MyProTerminals]::Unknown }
    }
}

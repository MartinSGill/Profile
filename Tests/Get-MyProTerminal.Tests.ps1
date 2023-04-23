#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.4.0" }

Describe 'Get-Terminal' {
    BeforeAll {
        . "$PSScriptRoot\..\Public\Get-Terminal.ps1"
    }

    Context 'when -ListKnown switch is used' {
        It 'returns an array of known terminal names' {
            $result = Get-Terminal -ListKnown
            $result | Should -Not -Contain 'Unknown'
        }
    }

    $testCases = @(
        @{
            Name   = 'VS Code'
            Arrange  = {
                $env:TERM_PROGRAM = 'vscode'
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
            }
            Expected = 'VsCode'
        },
        @{
            Name   = 'JetBrains JediTerm'
            Arrange  = {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $env:TERMINAL_EMULATOR = 'JetBrains-JediTerm'
            }
            Expected = 'JetBrainsJediTerm'
        },
        @{
            Name   = 'Azure Cloud Shell'
            Arrange  = {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $env:ACC_CLOUD = 1
            }
            Expected = 'AzureCloudShell'
        },
        @{
            Name   = 'Windows Terminal'
            Arrange  = {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $processName = 'WindowsTerminal'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Expected = 'WindowsTerminal'
        },
        @{
            Name   = 'Windows Console'
            Arrange  = {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $processName = 'explorer'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Expected = 'WindowsConsole'
        },
        @{
            Name   = 'Console2Z'
            Arrange  = {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $processName = 'Console'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Expected = 'Console2Z'
        },
        @{
            Name   = 'ConEmu'
            Arrange  = {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $processName = 'ConEmuC64'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Expected = 'ConEmu'
        },
        @{
            Name   = 'FluentTerminal'
            Arrange  = {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $processName = 'FluentTerminal.SystemTray'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Expected = 'FluentTerminal'
        },
        @{
            Name   = 'Unknown'
            Arrange  = [scriptblock] {
                $env:TERM_PROGRAM = $null
                $env:TERMINAL_EMULATOR = $null
                $env:ACC_CLOUD = $null
                $processName = 'unknown'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Expected = 'Unknown'
        }
    )

    Context "Detecting Terminal" {
        It "Returns <expected> (<name>)" -TestCases $testCases {
            # Arrange
            Invoke-Command -ScriptBlock $Arrange

            # Act
            $actual = Get-MyProTerminal

            # Assert
            $actual | Should -Be $($Expected)
        }
    }
}

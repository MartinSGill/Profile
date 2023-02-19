
. '..\Public\Get-MyProTerminal.ps1'

Describe "Get-MyProTerminal" {
    Context "when $ListKnown switch is used" {
        It "returns an array of known terminal names" {
            $result = Get-MyProTerminal -ListKnown
            $result | Should -Not -Contain 'Unknown'
        }
    }

    $testCases = @(
        @{
            Name = 'VS Code'
            Input = { $env:TERM_PROGRAM = 'vscode' }
            Output = 'VsCode'
        },
        @{
            Name = 'JetBrains JediTerm'
            Input = { $env:TERMINAL_EMULATOR = 'JetBrains-JediTerm' }
            Output = 'JetBrainsJediTerm'
        },
        @{
            Name = 'Azure Cloud Shell'
            Input = { $env:ACC_CLOUD = 1 }
            Output = 'AzureCloudShell'
        },
        @{
            Name = 'Windows Terminal'
            Input = {
                $processName = 'WindowsTerminal'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Output = 'WindowsTerminal'
        },
        @{
            Name = 'Windows Console'
            Input = {
                $processName = 'explorer'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Output = 'WindowsConsole'
        },
        @{
            Name = 'Console2Z'
            Input = {
                $processName = 'Console'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Output = 'Console2Z'
        },
        @{
            Name = 'ConEmu'
            Input = {
                $processName = 'ConEmuC64'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Output = 'ConEmu'
        },
        @{
            Name = 'FluentTerminal'
            Input = {
                $processName = 'FluentTerminal.SystemTray'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Output = 'FluentTerminal'
        },
        @{
            Name = 'Unknown'
            Input = [scriptblock]{
                $processName = 'unknown'
                Mock Get-Process { return @{ Parent = @{ Name = $processName } } }
            }
            Output = 'Unknown'
        }
    )

    $testCases | ForEach-Object {
        Context "when run on $($_.Name)" {
            BeforeEach {
                Invoke-Command -ScriptBlock $_.Input
            }
            It "should return $($_.Output)" {
                (Get-MyProTerminal) | Should -Be $($_.Output)
            }
        }
    }
}

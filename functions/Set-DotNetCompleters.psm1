<#
.SYNOPSIS

.EXAMPLE
.NOTES

#>
function Set-DotNetCompleters {
    [CmdletBinding(PositionalBinding=$false)]
    Param (
    )

    if (@(Get-Command -Name Invoke-Build -ErrorAction SilentlyContinue).Length -gt 0) {
        Write-Verbose -Message "DotNet Completers."

        # https://docs.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete
        # PowerShell parameter completion shim for the dotnet CLI
        Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
            dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
}

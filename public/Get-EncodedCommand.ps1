function Get-EncodedCommand {
    [CmdletBinding()]
    param (
        [string]$Command
    )
    process {
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $encodedCommand
    }
}

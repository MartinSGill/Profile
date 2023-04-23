function ConvertTo-EncodedCommand {
    <#
        .Description
            Encode a command, as required by pwsh -EncodedCommand
    #>
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        # Command (string) to encode.
        $Command
    )
    process {
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $encodedCommand
    }
}

function script:Get-EncodedCommand {
    <#
        .Description
            Encode a command, as required by pwsh -EncodedCommand
    #>
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        # String to encode.
        $Command
    )
    process {
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $encodedCommand
    }
}

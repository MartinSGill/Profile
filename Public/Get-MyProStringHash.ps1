function script:Get-MyProStringHash {
    <#
        .Synopsis
            Get a hash/checksum for a string.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        # String to encode
        [string] $String,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
        # Hashing algorithm to use. Default is SHA1
        [string]$Algorithm = 'SHA1'
    )
    $stream = [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($String))
    Get-FileHash -InputStream $stream -Algorithm $Algorithm
}

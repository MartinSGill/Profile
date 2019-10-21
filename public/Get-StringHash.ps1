function Get-StringHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $String,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
        [string]$Algorithm = 'SHA1'
    )
    $stream = [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($String))
    Get-FileHash -InputStream $stream -Algorithm $Algorithm
}



function script:Get-MyProQuote {
    [CmdletBinding()][Alias('gq')]
    param(
        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [string]$Path,

        [Parameter(ParameterSetName = 'Known', Mandatory = $true)]
        [ValidateSet('ChuckNorris', 'Quotes')]
        [string]$Source,

        [int]$Count = 1,

        [switch]$Pretty
    )

    if ($PSCmdlet.ParameterSetName -eq 'Path') {
        if (!(Test-Path $Path) ) {
            throw "File not found: '$Path'"
        }
    }

    if ($PSCmdLet.ParameterSetName -eq 'Known') {
        switch ($Source) {
            'Quotes' {
                $Path = (Resolve-Path "$PSScriptRoot/../Quotes/attributed-quotes.txt")
            }
            'ChuckNorris' {
                $Path = (Resolve-Path "$PSScriptRoot/../Quotes/chuck-norris.txt")
            }
            Default {
                throw "Unknown Source '$Source'"
            }
        }
    }

    $quotes = Get-Content $Path | Where-Object { $_ } | Get-Random -Count $Count
    if ($Pretty) {
        $quotes | Show-MyProQuote
    } else {
        $quotes
    }
}

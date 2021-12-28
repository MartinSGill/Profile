
function script:Install-MyProFont {
    <#
    .Synopsis
        Install a font file. (otf, ttf)
    #>
    [CmdLetBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not $IsWindows) {
        Write-Error "Only supported on Windows."
        return
    }

    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Error "Must Run as Administrator."
        return
    }

    try {
        $font = $Path | split-path -Leaf
        If (!(Test-Path "$env:SYSTEMROOT\fonts\$($font)")) {
            switch (($font -split "\.")[-1]) {
                "TTF" {
                    $fn = "$(($font -split "\.")[0]) (TrueType)"
                    break
                }
                "OTF" {
                    $fn = "$(($font -split "\.")[0]) (OpenType)"
                    break
                }
            }
            Copy-Item -Path $Path -Destination "C:\Windows\Fonts\$font" -Force -WhatIf:$WhatIf
            New-ItemProperty -Name $fn -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $font -WhatIf:$WhatIf
        }
    }
    catch {
        Write-Error $_.exception.message
    }
}

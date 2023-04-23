
function script:Find-VisualStudio {
    [CmdletBinding()]
    param ()

    if (-not $IsWindows) {
        Write-Error 'Only supported on Windows.'
        return
    }

    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vsWhere)) {
        Write-Error "'vswhere.exe' not found in default location: '$vsWhere'. Is Visual Studio installed?"
    }

    &$vsWhere -format json | ConvertFrom-Json | ForEach-Object { $_.PSObject.TypeNames.Insert(0, 'VsWhereOutput'); $_ }
}

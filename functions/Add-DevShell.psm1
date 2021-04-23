function Add-DevShell {
    <#
        .Synopsis
            Add Visual Studio Developer Powershell Prompt functionality to the
            current session.
    #>
    [CmdletBinding()]
    param ()

    $vsWhere = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

    if (!(Test-Path $vsWhere)) {
        throw "Visual Studio Installer not found. Cannot determine VS location."
    }

    $installPath = &$vsWhere -version 16.0 -property installationpath
    Import-Module (Join-Path $installPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll")
    Enter-VsDevShell -VsInstallPath $installPath -SkipAutomaticLocation
}

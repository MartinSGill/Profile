
function Switch-DarkMode {
    <#
        .SYNOPSIS
            Switch Windows Dark Mode
    #>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Only show current state, do not switch')]
        [switch]
        $OnlyShowState
    )

    if (!$IsWindows) {
        Write-Error 'Only supported on Windows'
        return
    }

    $personalizePath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    $appState = Get-ItemProperty -Path $personalizePath -Name 'AppsUseLightTheme' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'AppsUseLightTheme'
    $osState = Get-ItemProperty -Path $personalizePath -Name 'SystemUsesLightTheme' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'SystemUsesLightTheme'

    if (!$OnlyShowState.IsPresent) {
        Set-ItemProperty -Path $personalizePath -Name 'AppsUseLightTheme' -Value ($appState -eq 0 ? 1 : 0)
        Set-ItemProperty -Path $personalizePath -Name 'SystemUsesLightTheme' -Value ($osState -eq 0 ? 1 : 0)
    }

    $appState = Get-ItemProperty -Path $personalizePath -Name 'AppsUseLightTheme' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'AppsUseLightTheme'
    $osState = Get-ItemProperty -Path $personalizePath -Name 'SystemUsesLightTheme' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'SystemUsesLightTheme'
    $light = "[" + $PSStyle.Background.White + $PSStyle.Foreground.Black + "  LIGHT  " + $PSStyle.Reset + "]"
    $dark  = "[" +$PSStyle.Background.Black + $PSStyle.Foreground.White + "  DARK   " + $PSStyle.Reset + "]"

    Write-Output "Apps: $($appState -eq 0 ? $dark : $light)  OS: $($osState -eq 0 ? $dark : $light)"
}

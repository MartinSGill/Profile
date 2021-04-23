function Test-ProfileVersion() {
    <#
    .SYNOPSIS
        Tests if the repo version of the module is the same as the local version.
    #>

    $repoVersion = [version](
            (
                Invoke-RestMethod   -Method Get `
                                    -Uri https://raw.githubusercontent.com/MartinSGill/Profile/master/Profile.psd1 `
            ) -split '\r?\n' |
            Select-String -Pattern "ModuleVersion = '([.0-9]+)'"
        ).Matches.Groups[1].Value

    $localVersion = Get-Module -ListAvailable -Name Profile | Select-Object -ExpandProperty Version -First 1

    if ($repoVersion -ne $localVersion) {
        Write-Warning "New Version Available: Local: $localVersion | Remote: $repoVersion"
        return $false
    }
    return $true
}


VerboseBlock "Retire Oh-My-Posh PS" {
    ## https://ohmyposh.dev/docs/migrating

    if (@(Get-Module oh-my-posh -ListAvailable).Length -gt 0) {
        Write-Warning "Migrating to new Oh-My-Posh"
        Write-Warning "If you keep seeing this message, manually remove old versions as"
        Write-Warning "they may be in use. See https://ohmyposh.dev/docs/migrating"
        if (Test-Path "env::POSH_PATH") {
            Write-Warning "Removing cache"
            Remove-Item $env:POSH_PATH -Force -Recurse
        }

        Write-Warning "Uninstalling Modules"
        Uninstall-Module oh-my-posh -AllVersions

        if (Get-Command -Name "winget.exe") {
            Write-Warning "Installing Oh-My-Posh using winget"
        }
        elseif (Get-Command -Name "scoop.ps1") {
            Write-Warning "Installing Oh-My-Posh using scoop (winget not found)"
            scoop install "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json"
        }
        else {
            Write-MyProError "Cannot install oh-my-posh, see https://ohmyposh.dev/docs/installation"
        }
    }
}

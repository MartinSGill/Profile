
# Synopsis: Ensure scoop is available.
task installScoop -If { (Get-Command scoop -ErrorAction SilentlyContinue) -eq $null  } {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Synopsis: Install required CLI tools.
task installTools installScoop, {
    scoop install DocFx
}

# Synopsis: Install required PS modules.
task installModules {
    $modules = Get-Module -ListAvailable | Select-Object -ExpandProperty Name -Unique

    if ($modules -notcontains "platyps") {
        Install-Module -Name platyps -Scope CurrentUser
    }
}

# Synopsis: Warn for out-dated powershell
task warnPwsh -If { $PSVersionTable.PSVersion.Major -lt 7 } {
    Write-Warning "Powershell 7 is strongly recommended. You are running $($PSVersionTable.PSVersion)"
}

# Synopsis: Ensure valid build environment
task bootstrap warnPwsh, installTools, installModules

# Synopsis: Updatae the Help documents
task updateHelp bootstrap, {
    if (Get-Command -Name pwsh -ErrorAction SilentlyContinue) {
        pwsh -NoProfile -NonInteractive -Command {
            Import-Module -Name platyps -MinimumVersion 0.14.0
            Import-Module -Name ./Profile.psd1
            Update-MarkdownHelp -Path ./docs
        }
    } else {
        Write-Warning "PWSH not found. Falling back to powershell."
        powershell -NoProfile -NonInteractive -Command {
            Import-Module -Name platyps -MinimumVersion 0.14.0
            Import-Module -Name ./Profile.psd1
            Update-MarkdownHelp -Path ./docs
        }
    }
}

# Synopsis: Build
task build bootstrap, {

}

# Synopsis: Default
task . build

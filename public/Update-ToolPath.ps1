function Update-ToolPath {
    <#
        .Synopsis
            Add useful things to the PATH which aren't normally there on Windows.
        .Description
            Add Tools, Utilities, or Scripts folders which are in your profile to your Env:PATH variable
            Also adds the location of msbuild, merge, tf and python, as well as iisexpress
            Is safe to run multiple times because it makes sure not to have duplicates.
    #>
    param()

    ## I add my "Scripts" directory and all of its direct subfolders to my PATH
    [string[]]$folders = Get-ChildItem $ProfileDir\Tool[s], $ProfileDir\Utilitie[s], $ProfileDir\Script[s]\*, $ProfileDir\Script[s] -ad | % FullName

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        New-Alias -Name 'd' -Value docker -Scope Global
        Import-Module DockerCompletion
        if (-not $?) {
            Write-Warning "DockerCompletion module not found, installing."
            Install-Module DockerCompletion -Scope CurrentUser
            Import-Module DockerCompletion
        }
    }

    if (Get-Command docker-compose.exe -ErrorAction SilentlyContinue) {
        New-Alias -Name dc -Value docker-compose.exe -Scope Global
    }

    if (Test-Path 'c:\Program Files\Sublime Text 3\sublime_text.exe') {
        New-Alias -Name 'st' -Value 'c:\Program Files\Sublime Text 3\sublime_text.exe' -Scope Global
    }

    if (Test-Path 'c:\Program Files\Sublime Merge\smerge.exe') {
        New-Alias -Name 'sm' -Value 'c:\Program Files\Sublime Merge\smerge.exe' -Scope Global
    }

    if (Get-Command -Name 'code-insiders.cmd' -ErrorAction SilentlyContinue) {
        New-Alias -Name 'ci' -Value 'code-insiders.cmd' -Scope Global
    }

    Trace-Message "Development aliases set"

    $ENV:PATH = Select-UniquePath $folders ${Env:Path}
    Trace-Message "Env:PATH Updated"
}

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

    ## Developer tools stuff ...
    ## I need MSBuild, and TF (TFS) and they're all in the .Net RuntimeDirectory OR Visual Studio*\Common7\IDE
    # if("System.Runtime.InteropServices.RuntimeEnvironment" -as [type]) {
    #     $folders += [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    # }

    # Set-AliasToFirst -Alias "iis","iisexpress" -Path 'C:\Progra*\IIS*\IISExpress.exe' -Description "IISExpress"
    # $folders += Set-AliasToFirst -Alias "msbuild" -Path 'C:\Program*Files*\*Visual?Studio*\*\*\MsBuild\*\Bin\MsBuild.exe', 'C:\Program*Files*\MSBuild\*\Bin\MsBuild.exe' -Description "Visual Studio's MsBuild" -Force -Passthru
    # $folders += Set-AliasToFirst -Alias "tf" -Path "C:\Program*Files*\*Visual?Studio*\*\*\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team?Explorer\TF.exe", "C:\Program*Files*\*Visual?Studio*\Common7\IDE\TF.exe" -Description "TFVC" -Force -Passthru

    # if ($python = Set-AliasToFirst -Alias "Python", "py" -Path "C:\Program*Files*\Anaconda3*\python.exe", "C:\Program*Files*\*Visual?Studio*\Shared\Anaconda3*\python.exe" -Description "Python 3.x" -Force -Passthru) {
    #     $folders += $python
    #     $folders += @("Library\mingw-w64\bin", "Library\usr\bin", "Library\bin", "Scripts").ForEach({[io.path]::Combine($python, $_)})
    #     if ($python -match "conda") {
    #         $ENV:CONDA_PREFIX = $python
    #     }
    # }

    ## I don't use Python2 lately, but I can't quite convince myself I won't need it again
    #   $folders += Set-AliasToFirst -Alias "Python2", "py2" -Path "C:\Program*Files*\Anaconda3\python.exe", "C:\Python2*\python.exe" -Description "Python 2.x" -Force -Passthru

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        New-Alias -Name 'd' -Value docker -Scope Global
        Import-Module posh-docker
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

    Trace-Message "Development aliases set"

    $ENV:PATH = Select-UniquePath $folders ${Env:Path}
    Trace-Message "Env:PATH Updated"
}

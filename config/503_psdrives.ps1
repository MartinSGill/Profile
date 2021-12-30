
VerboseBlock "Drives" {
    $drives = @(
        @{ Name = 'dbox'; Root = (Get-MyProDropboxFolder -WarningAction 'SilentlyContinue'); PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'repo'; Root = '~/source/repos'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'src'; Root = 'c:/source'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'src'; Root = '/source'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'mypro'; Root = "$PSScriptRoot/.."; PSProvider = 'FileSystem'; Scope = 'Global' }
    )

    foreach ($drive in $drives) {
        if ($null -ne $drive.Root -and (Test-Path $drive.Root)) {
            Write-MyProDebug "💽 '$($drive.Name)' --> '$($drive.Root)'"
            New-PSDrive @drive
        }
    }
}

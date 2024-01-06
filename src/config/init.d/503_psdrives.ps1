
VerboseBlock "Drives" {
    $drives = @(
        @{ Name = 'dbox'; Root = (Get-DropboxFolder -WarningAction 'SilentlyContinue'); PSProvider = 'FileSystem'; Scope = 'Global' }
        # Needs updating to deal with Business and Personal on same account
        # @{ Name = 'odrive'; Root = (Get-OneDriveFolder -WarningAction 'SilentlyContinue'); PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'repo'; Root = '~/source/repos'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'projects'; Root = 'c:/projects'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'projects'; Root = '/projects'; PSProvider = 'FileSystem'; Scope = 'Global' }
        @{ Name = 'mypro'; Root = "$PSScriptRoot/.."; PSProvider = 'FileSystem'; Scope = 'Global' }
    )

    foreach ($drive in $drives) {
        if ($null -ne $drive.Root -and (Test-Path $drive.Root)) {
            WriteDebug "💽 '$($drive.Name)' --> '$($drive.Root)'"
            New-PSDrive @drive
        }
    }
}


function script:Get-MyProOneDriveFolder() {
    [CmdletBinding()]
    param(
        [switch]$FullInfo
    )
    if (-not $IsWindows) {
        Write-Error "Only supported on Windows"
        return
    }

    $folders = Get-ChildItem HKCU:\Software\Microsoft\OneDrive\Accounts\ |
        ForEach-Object { [pscustomobject]@{
            Name = Split-Path $_.Name -Leaf;
            Folder = $_.GetValue('UserFolder');
            UserEmail = $_.GetValue('UserEmail') } }

    if ($FullInfo) {
        $folders
    } else {
        $folders.Folder | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }
}

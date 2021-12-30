
class NerdFontInfo {
    [string]$ReleaseName
    [string]$FontName
    [string]$DownloadUrl
}

function script:Get-MyProNerdFont() {
    $url = "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
    $releaseInfo = Invoke-RestMethod -Method Get -Uri $url

    foreach ($asset in $releaseInfo.assets) {
        $fontInfo = [NerdFontInfo]::new()
        $fontInfo.ReleaseName = $releaseInfo.name
        $fontInfo.FontName = Split-Path -Path $asset.name -LeafBase
        $fontInfo.DownloadUrl = $asset.browser_download_url
        $fontInfo
    }
}

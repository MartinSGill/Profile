
VerboseBlock "Views" {
    Import-MyProHumanizer
    $formats = @( Get-ChildItem -Path $PSScriptRoot\..\Formats\*.formats.ps1xml -ErrorAction SilentlyContinue )
    foreach ($item in $formats) {
        Write-MyProDebug "🪟 $($item.BaseName)"
        Update-FormatData -PrependPath $item
    }
}

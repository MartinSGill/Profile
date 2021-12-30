
VerboseBlock "Type Extensions" {
    $formats = @( Get-ChildItem -Path $PSScriptRoot\..\Types\*.types.ps1xml -ErrorAction SilentlyContinue )
    foreach ($item in $formats) {
        Write-MyProDebug "🧷 $($item.BaseName)"
        Update-TypeData -PrependPath $item
    }
}

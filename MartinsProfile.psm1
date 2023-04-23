# Used for debug/development

$srcRoot = "$PSScriptRoot/src"
$classes = @( Get-ChildItem -Path $srcRoot\Classes\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$publicFunctions = @( Get-ChildItem -Path $srcRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$privateFunctions = @( Get-ChildItem -Path $srcRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach ($import in @($classes + $privateFunctions + $publicFunctions)) {
    try {
        . $import.FullName
    } catch {
        WriteError -Message "Failed to import function $($import.FullName): $_"
    }
}

foreach ($item in $publicFunctions) {
    Export-ModuleMember -Function $item.BaseName
}

. $srcRoot/init.ps1

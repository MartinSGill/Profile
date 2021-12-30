
VerboseBlock "Auto-Completers" {
    $autoCompleters =  @( Get-ChildItem -Path $PSScriptRoot\..\Private\auto-completers\*.ps1 -ErrorAction SilentlyContinue )
    foreach ($item in $autoCompleters) {
        try
        {
            Write-MyProDebug "📎 $($item.BaseName)"
            . $item.FullName
        }
        catch
        {
            Write-Error -Message "Failed to import function $($import.FullName): $_"
        }
    }
}


VerboseBlock "Auto-Completers" {
    $autoCompleters =  @( Get-ChildItem -Path $PSScriptRoot/../auto-completers/*.ps1 -ErrorAction SilentlyContinue )
    foreach ($item in $autoCompleters) {
        try
        {
            WriteDebug "📎 $($item.BaseName)"
            . $item.FullName
        }
        catch
        {
            Write-Error -Message "Failed to import function $($import.FullName): $_"
        }
    }
}

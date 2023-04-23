
function GetParentProcess {
        <#
        .Synopsis
            Get the Process of the current process' parent.
    #>
    [CmdletBinding()]
    param ()
    Get-Process -Id (GetParentProcessId)
}

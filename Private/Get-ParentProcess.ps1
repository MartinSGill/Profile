
function script:Get-ParentProcess {
        <#
        .Synopsis
            Get the Process of the current process' parent.
    #>
    [CmdletBinding()]
    param ()
    Get-Process -Id (Get-ParentProcessId)
}

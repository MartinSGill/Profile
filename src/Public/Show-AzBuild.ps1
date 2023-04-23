function Show-AzBuild() {
    [CmdletBinding()]
    param ()

    $raw = az pipelines build list | ConvertFrom-Json
    $raw |
        Sort-Object -Property startTime -Descending |
        Format-Table -Property @(
            @{Label = 'R'; Expression = {
                    switch ($_.result) {
                        'succeeded' {
                            '💚'
                        }
                        'failed' {
                            '🔴'
                        }
                        'canceled' {
                            '🚫'
                        }
                        Default {
                            $_.result
                        }
                    } }
            }
            @{Label = 'DefName'; Expression = { $_.definition.name } }
            @{Label = 'DefId'; Expression = { $_.definition.id } }
            @{Label = 'BuildId' ; Expression = { $_.id } }
            @{Label = 'BuildNumber' ; Expression = { $PSStyle.FormatHyperlink($_.buildNumber, $_.url) } }
            @{Label = 'StartTime' ; Expression = { $_.startTime } }
            @{Label = 'Status' ; Expression = { $_.status } }
        )
}

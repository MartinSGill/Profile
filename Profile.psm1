class FileFormat {
    [string]$Color
    [char]$Icon

    FileFormat() {
        $this.Color = $global:Host.UI.RawUI.ForegroundColor
        $this.Icon = " "
    }

    FileFormat([string]$color) {
        $this.Color = $color
        $this.Icon = " "
    }

    FileFormat([string]$color, [char]$icon) {
        $this.Color = $color
        $this.Icon = $icon
    }
}

Add-MetadataConverter @{
    [FileFormat] = { "FileFormat '$($_.Color)' $($_.Icon)" }
    "FileFormat" = {
        param([string]$color, [char]$icon)
        [FileFormat]::new($color, $icon)
    }
}

$Configuration = Import-Configuration
if ($Configuration.FileColors) {
    $global:PSFileFormats = $Configuration.FileColors
}

function Get-DropBoxFolder {
    ##############################
    #.SYNOPSIS
    #   Find the location where Dropbox stores files
    #   for the current user.
    ##############################
    [CmdletBinding()]
    param ()
    $info = $null;
    if (Test-Path (Join-Path $env:APPDATA "dropbox\info.json")) {
        Write-Verbose "Found dropbox info in APPDATA"
        $info = Get-Content (Join-Path $env:APPDATA "dropbox\info.json") | ConvertFrom-Json
    } elseif (Test-Path (Join-Path $env:LOCALAPPDATA "dropbox\info.json")) {
        Write-Verbose "Found dropbox info in LOCALAPPDATA"
        $info = Get-Content (Join-Path $env:LOCALAPPDATA "dropbox\info.json") | ConvertFrom-Json
    }

    if ($null -eq $info) {
        Write-Warning "Dropbox Content Folder not found."
        return $null
    }

    $path = $info.personal.path
    Write-Verbose "Found Path: $path"
    $path
}

function Set-HostColor {
    <#
        .Description
            Set more reasonable colors, because yellow is for warning, not verbose
    #>
    [CmdletBinding()]
    param(
        # Change the background color only if ConEmu didn't already do that.
        [Switch]$Light,

        # Don't use the special PowerLine characters
        [Switch]$SafeCharacters,

        # If set, run the script even when it's not the ConsoleHost
        [switch]$Force
    )

    if ($Light) {
        Import-Theme Light
    } else {
        Import-Theme Dark
    }

    $PSReadLineOption = @{
        AnsiEscapeTimeout             = 100
        BellStyle                     = "Visual"
        CompletionQueryItems          = 100
        ContinuationPrompt            = ">> "
        DingDuration                  = 50 #ms
        DingTone                      = 1221
        EditMode                      = "Windows"
        HistoryNoDuplicates           = $true
        HistorySaveStyle              = "SaveIncrementally"
        HistorySearchCaseSensitive    = $false
        HistorySearchCursorMovesToEnd = $false
        MaximumHistoryCount           = 1024
        MaximumKillRingCount          = 10
        ShowToolTips                  = $true
        WordDelimiters                = ";:,.[]{}()/\|^&*-=+"
    }
    Set-PSReadlineOption @PSReadLineOption
}
# Set the colors as early as we can (before any output)
Set-HostColor

function Update-ToolPath {
    #.Synopsis
    # Add useful things to the PATH which aren't normally there on Windows.
    #.Description
    # Add Tools, Utilities, or Scripts folders which are in your profile to your Env:PATH variable
    # Also adds the location of msbuild, merge, tf and python, as well as iisexpress
    # Is safe to run multiple times because it makes sure not to have duplicates.
    param()

    ## I add my "Scripts" directory and all of its direct subfolders to my PATH
    [string[]]$folders = Get-ChildItem $ProfileDir\Tool[s], $ProfileDir\Utilitie[s], $ProfileDir\Script[s]\*, $ProfileDir\Script[s] -ad | % FullName

    ## Developer tools stuff ...
    ## I need MSBuild, and TF (TFS) and they're all in the .Net RuntimeDirectory OR Visual Studio*\Common7\IDE
    if("System.Runtime.InteropServices.RuntimeEnvironment" -as [type]) {
        $folders += [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    }

    Set-AliasToFirst -Alias "iis","iisexpress" -Path 'C:\Progra*\IIS*\IISExpress.exe' -Description "IISExpress"
    $folders += Set-AliasToFirst -Alias "msbuild" -Path 'C:\Program*Files*\*Visual?Studio*\*\*\MsBuild\*\Bin\MsBuild.exe', 'C:\Program*Files*\MSBuild\*\Bin\MsBuild.exe' -Description "Visual Studio's MsBuild" -Force -Passthru
    $folders += Set-AliasToFirst -Alias "tf" -Path "C:\Program*Files*\*Visual?Studio*\*\*\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team?Explorer\TF.exe", "C:\Program*Files*\*Visual?Studio*\Common7\IDE\TF.exe" -Description "TFVC" -Force -Passthru

    # if ($python = Set-AliasToFirst -Alias "Python", "py" -Path "C:\Program*Files*\Anaconda3*\python.exe", "C:\Program*Files*\*Visual?Studio*\Shared\Anaconda3*\python.exe" -Description "Python 3.x" -Force -Passthru) {
    #     $folders += $python
    #     $folders += @("Library\mingw-w64\bin", "Library\usr\bin", "Library\bin", "Scripts").ForEach({[io.path]::Combine($python, $_)})
    #     if ($python -match "conda") {
    #         $ENV:CONDA_PREFIX = $python
    #     }
    # }

    ## I don't use Python2 lately, but I can't quite convince myself I won't need it again
    #   $folders += Set-AliasToFirst -Alias "Python2", "py2" -Path "C:\Program*Files*\Anaconda3\python.exe", "C:\Python2*\python.exe" -Description "Python 2.x" -Force -Passthru

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        New-Alias -Name 'd' -Value docker -Scope Global
    }

    if (Get-Command docker-compose.exe -ErrorAction SilentlyContinue) {
        New-Alias -Name dc -Value docker-compose.exe -Scope Global
    }

    if (Test-Path 'c:\Program Files\Sublime Text 3\sublime_text.exe') {
        New-Alias -Name 'st' -Value 'c:\Program Files\Sublime Text 3\sublime_text.exe' -Scope Global
    }

    if (Test-Path 'c:\Program Files\Sublime Merge\smerge.exe') {
        New-Alias -Name 'sm' -Value 'c:\Program Files\Sublime Merge\smerge.exe' -Scope Global
    }

    Trace-Message "Development aliases set"

    $ENV:PATH = Select-UniquePath $folders ${Env:Path}
    Trace-Message "Env:PATH Updated"
}

function Reset-Module {
    <#
    .Synopsis
        Remove and re-import a module to force a full reload
    #>
    param($ModuleName)
    Microsoft.PowerShell.Core\Remove-Module $ModuleName
    Microsoft.PowerShell.Core\Import-Module $ModuleName -Force -Pass -Scope Global | Format-Table Name, Version, Path -Auto
}

if(!$ProfileDir -or !(Test-Path $ProfileDir)) {
    $ProfileDir = Split-Path $Profile.CurrentUserAllHosts
}
Write-Warning "ProfileDir $ProfileDir"

$QuoteDir = Join-Path (Split-Path $ProfileDir -parent) "Quotes"
if(!(Test-Path $QuoteDir)) {
    $QuoteDir = Join-Path $PSScriptRoot Quotes
}

# Only export $QuoteDir if it refers to a folder that actually exists
Set-Variable QuoteDir (Resolve-Path $QuoteDir) -Description "Personal Quotes Path Source"

function Get-Quote {
    [CmdletBinding()][Alias("gq")]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string]$Path = "${QuoteDir}\attributed quotes.txt",
        [int]$Count=1
    )
    if(!(Test-Path $Path) ) {
        $Path = Join-Path ${QuoteDir} $Path
        if(!(Test-Path $Path) ) {
            $Path = $Path + ".txt"
        }
    }
    Get-Content $Path | Where-Object { $_ } | Get-Random -Count $Count
}

# Run these functions once
Update-ToolPath

Trace-Message "Random Quotes Loaded"

## Get a random quote, and print it in yellow :D
if( Test-Path "${QuoteDir}\attributed quotes.txt" ) {
    Get-Quote | Write-Host -Foreground "xt214"
}

# If you log in with a Microsoft Identity, this will capture it
Set-Variable LiveID (
    [Security.Principal.WindowsIdentity]::GetCurrent().Groups.Where{
        $_.Value -match "^S-1-11-96"
    }.Translate([Security.Principal.NTAccount]).Value
) -Option ReadOnly -ErrorAction SilentlyContinue

function Update-PSReadLine {
    Set-PSReadlineKeyHandler Ctrl+Shift+C CaptureScreen
    Set-PSReadlineKeyHandler Ctrl+Shift+R ForwardSearchHistory
    Set-PSReadlineKeyHandler Ctrl+R ReverseSearchHistory

    Set-PSReadlineKeyHandler Ctrl+DownArrow HistorySearchForward
    Set-PSReadlineKeyHandler Ctrl+UpArrow HistorySearchBackward
    Set-PSReadLineKeyHandler Ctrl+Home BeginningOfHistory

    Set-PSReadlineKeyHandler Ctrl+M SetMark
    Set-PSReadlineKeyHandler Ctrl+Shift+M ExchangePointAndMark

    Set-PSReadlineKeyHandler Ctrl+K KillLine
    Set-PSReadlineKeyHandler Ctrl+I Yank

    Set-PSReadLineKeyHandler Ctrl+h BackwardDeleteWord
    Set-PSReadLineKeyHandler Ctrl+Enter AddLine
    Set-PSReadLineKeyHandler Ctrl+Shift+Enter AcceptAndGetNext
    Trace-Message "PSReadLine hotkeys fixed"

    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

    # Sometimes you enter a command but realize you forgot to do something else first.
    # This binding will let you save that command in the history so you can recall it,
    # but it doesn't actually execute.  It also clears the line with RevertLine so the
    # undo stack is reset - though redo will still reconstruct the command line.
    Set-PSReadLineKeyHandler -Key Alt+w `
        -BriefDescription SaveInHistory `
        -LongDescription "Save current line in history but do not execute" `
        -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    }

    # Insert text from the clipboard as a here string
    Set-PSReadLineKeyHandler    -Key Ctrl+Shift+v `
                                -BriefDescription PasteAsHereString `
                                -LongDescription "Paste the clipboard text as a here string" `
                                -ScriptBlock {
        param($key, $arg)

        Add-Type -Assembly PresentationCore
        if ([System.Windows.Clipboard]::ContainsText()) {
            # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
            $text = ([System.Windows.Clipboard]::GetText() -replace "\p{Zs}*`r?`n", "`n").TrimEnd()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("@'`n$text`n'@")
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
        }
    }

    ## There were some problems with hosts using PSReadLine who shouldn't
    if ($Host.Name -ne "ConsoleHost") {
        Remove-Module PSReadLine -ErrorAction SilentlyContinue
        Trace-Message "PSReadLine unloaded!"
    }
}

function Set-MyPrompt {
    [CmdletBinding()]
    param(
        # Don't use the special PowerLine characters
        [Switch]$SafeCharacters
    )

    # Clear out any existing settings
    Remove-Item -Path (Get-ConfigurationPath -Module (Get-Module Powerline)) -Force -Recurse

    if (Get-Module posh-git) {
        if ($SafeCharacters) {
            $GitPromptSettings.BeforeStatus.Text = "["
            $GitPromptSettings.DelimStatus.Text = " |"
            $GitPromptSettings.AfterStatus.Text = "]"
        } else {
            $GitPromptSettings.BeforeStatus.Text = "{0} " -f [PoshCode.Pansies.Entities]::ExtendedCharacters.Branch
            $GitPromptSettings.DelimStatus.Text = " | " -f [PoshCode.Pansies.Entities]::ExtendedCharacters.Separator
            $GitPromptSettings.AfterStatus.Text = " "
        }
    }

    $plArgs = @{
        RestoreVirtualTerminal = $true
        FullColor = $true
        SetCurrentDirectory = $true
        PowerLineFont = (-not $SafeCharacters)
        Prompt = @()
        Save = $false
    }

    $plArgs.Prompt += {
        if($pushed = (Get-Location -Stack).count) {
            $pArgs = @{
                InputObject = "&raquo;$pushed"
                ForegroundColor = "White"
                BackgroundColor = "SlateBlue"
            }
            New-PromptText @pArgs
        }
    }

    $plArgs.Prompt += { Get-SegmentedPath -SegmentLimit 6 -ForegroundColor "Black" -BackgroundColor "White" }

    # $plArgs.Prompt += { "`t" }

    if ($SafeCharacters) {
        $plArgs.Prompt += {
            if (-not [string]::IsNullOrWhiteSpace($(Get-Elapsed)) ) {
                $pArgs = @{
                    InputObject = " $(Get-Elapsed -Format "{0:ss\.ffff}") "
                    ForegroundColor = "Black"
                    BackgroundColor = "#E7FFAC"
                    ErrorForegroundColor = "Black"
                    ErrorBackgroundColor = "#FFABAB"
                }
                New-PromptText @pArgs
            }
        }
    } else {
        $plArgs.Prompt += {
            if (-not [string]::IsNullOrWhiteSpace($(Get-Elapsed)) ) {
                $pArgs = @{
                    InputObject = " 祥 $(Get-Elapsed -Format "{0:ss\.ffff}") "
                    ForegroundColor = "Black"
                    BackgroundColor = "#E7FFAC"
                    ErrorForegroundColor = "Black"
                    ErrorBackgroundColor = "#FFABAB"
                }
                New-PromptText @pArgs
            }
        }
    }

    if (Get-Module posh-git) {
        $plArgs.Prompt += { New-PromptText -InputObject "$(Write-VcsStatus)" -ForegroundColor "white" -BackgroundColor "black" }
    }

    $plArgs.Prompt += { "`n" }

    if ($SafeCharacters) {
        $plArgs.Prompt += {
            $pArgs = @{
                InputObject = " $(Get-Date -Format "T") "
                ForegroundColor = "Black"
                BackgroundColor = "#BFFCC6"
            }
            New-PromptText @pArgs
        }
    } else {
        $plArgs.Prompt += {
            $pArgs = @{
                InputObject = "  $(Get-Date -Format "T") "
                ForegroundColor = "Black"
                BackgroundColor = "#BFFCC6"
            }
            New-PromptText @pArgs
        }
    }

    $plArgs.Prompt += {
        $pArgs = @{
            InputObject = " $("{0}" -f $PSVersionTable.PSVersion.Major) >_ "
            ForegroundColor = "Black"
            BackgroundColor = "#6EB5FF"
            ElevatedForegroundColor = "Black"
            ElevatedBackgroundColor = "#FFABAB"
        }
        New-PromptText @pArgs
    }

    Set-PowerLinePrompt @plArgs
}

# Only configure PSReadLine if it's already running
if (Get-Module PSReadline) {
    Update-PSReadLine
}

function Get-ParentProcessId {
    if ($PSVersionTable.PSVersion.Major -lt 6)
    {
        ((Get-WmiObject win32_process | Where-Object processid -eq  $pid).parentprocessid)
    } else {
        (Get-Process -Id $pid).Parent.Id
    }
}

function Get-ParentProcess {
    Get-Process -Id (Get-ParentProcessId)
}

switch -Regex ((Get-ParentProcess).Name) {
    'conemu|code|hyper|extraterm' {
        Trace-Message "Funky Prompt"
        Set-MyPrompt
    }
    Default {
        Trace-Message "Safe Prompt"
        Set-MyPrompt -SafeCharacters
    }
}

# Unfortunately, in order for our File Format colors and History timing to take prescedence, we need to PREPEND the path:
Update-FormatData -PrependPath (Join-Path $PSScriptRoot 'Formats.ps1xml')

Export-ModuleMember -Function * -Alias * -Variable LiveID, QuoteDir

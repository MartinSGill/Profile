function script:Clear-MyProSpace {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$Folders,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$Chocolatey,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$Scoop,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$NuGet,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$Info,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$RecycleBin,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$Docker,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$DockerVhdx,

        [Parameter(ParameterSetName = 'Individual')]
        [switch]$Yarn,

        [Parameter(ParameterSetName = 'Help')]
        [switch]$Help
    )

    if (-not $IsWindows) {
        Write-Error 'Only supported on Windows OS'
        return
    }

    if ($Help) {
        Get-Help Clear-MyProSpace
        return
    }

    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Error 'Must Run as Administrator.'
        return
    }

    Import-MyProHumanizer

    class SpaceInfo {
        $Before
        $After
        $Info
        $Command
    }

    function DirectorySize() {
        param (
            $Path
        )

        (du -c -nobanner -l 1000 $Path | ConvertFrom-Csv | Measure-Object -AllStats -Property DirectorySize).Sum.bytes
    }

    $cHeader = '{0}{1}' -f $PSStyle.Foreground.Black, $PSStyle.Background.LightYellow
    $cInfoStart = $PSStyle.Foreground.LightYellow
    $cText = $PSStyle.Foreground.Yellow
    $cName = $PSStyle.Foreground.Cyan
    $cFolder = $PSStyle.Foreground.Magenta
    $cReset = $PSStyle.Reset
    $cSuccess = $PSStyle.Foreground.LightGreen

    $drives = Get-PhysicalPsDrive | ForEach-Object { @{ Name = $_.Name ; StartFree = $_.Free } }

    $results = @()
    $startFree = (Get-PSDrive c).Free

    Write-Host
    Write-Host "$cHeader ---- Clean ----                        $cReset"
    Write-Host

    if ($All -or $Folders) {
        @(
            @{ Path = $env:TEMP; Name = '$env:TEMP' },
            @{ Path = $env:TMP; Name = '$env:TMP' },
            @{ Path = 'c:\temp'; Name = 'c:\temp' }) | ForEach-Object {
            Write-Host "$cText  $cName$($_.Name) $cText($cFolder$($_.Path)$cText) folder$cReset"

            $sizeBefore = DirectorySize -Path $_.Path
            if ($PSCmdlet.ShouldProcess($_, 'Clean')) {
                Get-ChildItem $_.Path | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

            }

            $sizeAfter = DirectorySize -Path $_.Path
            $results += [SpaceInfo]@{ Command = 'Folders'; Info = "Directory $($_.Name)"; Before = $sizeBefore; After = $sizeAfter }

            Write-Host
        }
    }

    if ($All -or $Docker) {
        if ($null -eq (Get-Command -ErrorAction SilentlyContinue docker)) {
            Write-Warning 'Docker not in PATH. Skipping.'
        } else {

            Write-Host "$cText Docker" -ForegroundColor Cyan
            if ($PSCmdlet.ShouldProcess('Docker', 'Prune')) {
                docker system prune --force
            }
            if ($All -or $DockerVhdx) {
                if ($null -eq (Get-Command -ErrorAction SilentlyContinue wsl)) {
                    Write-Warning 'WSL not in PATH. Skipping.'
                } else {
                    Write-Host "$cText  Docker VHXD" -ForegroundColor Cyan
                    if ($PSCmdlet.ShouldProcess('Docker', 'Shrink VXHD')) {
                        wsl --shutdown
                        Optimize-VHD -Path $env:LOCALAPPDATA\Docker\wsl\Data\ext4.vhdx, $env:LOCALAPPDATA\Packages\CanonicalGroupLimited.*\LocalState\ext4.vhdx  -Mode full
                        Write-Warning 'You Will Need to Restart Docker Desktop.'
                    }
                }
            }
            Write-Host
        }
    }

    if ($All -or $Chocolatey) {
        if ($null -eq (Get-Command -ErrorAction SilentlyContinue choco)) {
            Write-Warning 'Choco not in PATH. Skipping.'
        } else {
            Write-Host "$cText🍫 Chocolatey$cReset"
            if ($PSCmdlet.ShouldProcess('Chocolatey', 'Cleaner')) {
                cinst choco-cleaner -y
                choco-cleaner
            }
            Write-Host
        }
    }

    if ($All -or $Scoop) {
        if ($null -eq (Get-Command -ErrorAction SilentlyContinue scoop)) {
            Write-Warning 'Scoop not in PATH. Skipping.'
        } else {

            Write-Host "$cText🍧 Scoop$cReset"
            if ($PSCmdlet.ShouldProcess('Scoop', 'Cleanup, Empty Cache')) {
                scoop cleanup *
                scoop cache rm *
            }
            Write-Host
        }
    }

    if ($All -or $RecycleBin) {
        Write-Host "$cText  Recycle Bin$cReset"
        if ($PSCmdlet.ShouldProcess('Recycle Bin', 'Clear')) {
            Clear-RecycleBin -Force
        }
        Write-Host
    }

    if ($All -or $NuGet) {
        if ($null -eq (Get-Command -ErrorAction SilentlyContinue dotnet)) {
            Write-Warning 'dotnet cli not in PATH. Skipping.'
        } else {

            Write-Host "$cText NuGet$cReset"
            if ($PSCmdlet.ShouldProcess('NuGet', 'Clear Caches')) {
                dotnet nuget locals all --clear
            }
            Write-Host
        }
    }

    if ($All -or $Yarn) {
        if ($null -eq (Get-Command -ErrorAction SilentlyContinue yarn)) {
            Write-Warning 'yarn not in path. Skipping.'
        } else {
            if ($null -eq (Get-Command -ErrorAction SilentlyContinue node)) {
                Write-Warning 'node not in path. Skipping.'
            } else {
                Write-Host "$cText  Yarn$cReset"
                if ($PSCmdlet.ShouldProcess('Yarn', 'Clear Caches')) {
                    yarn cache clean --emoji true
                }
                Write-Host
            }
        }
    }

    $endFree = (Get-PSDrive c).Free
    $spaceRecovered = ($endFree - $startFree).bytes

    function InfoTable() {
        param (
            $DataTable,
            $Name

        )

        $tableFormat = @(@{
                Expression = { $v = ([int]$_.Size).bytes ; "$cName{0:n1} {1}$cReset" -f $v.LargestWholeNumberValue, $v.LargestWholeNumberSymbol }
                Label      = 'Size'
            }
            , 'Filename')

        Write-Host
        Write-Host "$cInfoStart === ${cText}$Name$cReset"
        $DataTable | Select-Object -First 10 | Format-Table -Property $tableFormat

        $stats = $DataTable | Measure-Object -Sum -Property Size
        Write-Host "Total Items: $($stats.Count)"
        Write-Host ("Total Size: $cName{0:n1} {1}$cReset" -f $stats.Sum.bytes.LargestWholeNumberValue, $stats.Sum.bytes.LargestWholeNumberSymbol)
    }

    if ($All -or $Info) {
        if ($null -eq (Get-Command -ErrorAction SilentlyContinue es)) {
            Write-Warning 'es [1] not in PATH. Skipping. [1] voidtools everything command line'
        } else {
            Write-Host "$cHeader ---- Info ----                        $cReset"
            InfoTable -DataTable (es -csv -sort-size -size wholefilename:cache attrib:D | ConvertFrom-Csv) -Name 'Caches'
            InfoTable -DataTable (es -csv -sort-size -size wholefilename:temp attrib:D | ConvertFrom-Csv) -Name 'Temps'
            InfoTable -DataTable (es -csv -sort-size -size ext:log attrib:F | ConvertFrom-Csv) -Name 'Logs'
            InfoTable -DataTable (es -csv -sort-size -size (Resolve-Path ~\downloads) | ConvertFrom-Csv) -Name 'Downloads'
        }
    }

    $drives = $drives | ForEach-Object { $_.EndFree = (Get-PSDrive -Name $_.Name).Free ; $_.Recovered = $_.EndFree - $_.StartFree; $_ } | ForEach-Object { [PSCustomObject]$_ }

    Write-Host
    $drives | Format-Table -Property    @{ Label = "💾 ${cText}Name$cReset"; Expression = { "💾 ${cText}$($_.Name)$cReset" } },
    @{ Label = "▶ ${cName}Start$cReset"; Expression = { "▶ ${cName}{0,6:n1} {1,-2:s}$cReset" -f $_.StartFree.bytes.LargestWholeNumberValue, $_.StartFree.bytes.LargestWholeNumberSymbol } },
    @{ Label = "🏁 ${cFolder}End$cReset"; Expression = { "🏁 ${cFolder}{0,6:n1} {1,-2:s}$cReset" -f $_.EndFree.bytes.LargestWholeNumberValue, $_.EndFree.bytes.LargestWholeNumberSymbol } },
    @{ Label = "✔ ${cSuccess}Freed$cReset"; Expression = { "✔ ${cSuccess}{0,6:n1} {1,-2:s}$cReset" -f $_.Recovered.bytes.LargestWholeNumberValue, $_.Recovered.bytes.LargestWholeNumberSymbol } }
    Write-Host
    Write-Host "${cSuccess}Done. Bye. 🙋‍$cReset"
}

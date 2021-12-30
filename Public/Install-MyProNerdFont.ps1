
class NerdFontFileInfo {
    [System.IO.FileInfo]$FileInfo
    [bool]$IsWindowsCompatible
    [bool]$IsMonoGlyphs
    [string]$Format
}

function script:Install-MyProNerdFont() {
    [CmdletBinding()]
    param()

    DynamicParam {
        $dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $fontNames =  Get-MyProNerdFont | Select-Object -ExpandProperty FontName
        New-MyProDynamicParam -Name FontName -ValidateSet $fontNames -Mandatory -DpDictionary $dictionary -ValueFromPipelineByPropertyName
        return $dictionary
    }

    begin {
        $fonts = Get-MyProNerdFont
        $fontFileRegex = [regex]'(?<name>.*?)Nerd Font Complete ?(?<mono>Mono)? ?(?<windows>Windows Compatible)?.(?<type>otf|ttf)'
    }

    process {

        if (-not $IsWindows) {
            Write-Error "Only supported on Windows."
            return
        }

        if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
            Write-Error "Must Run as Administrator."
            return
        }

        $FontName = $PSBoundParameters.FontName
        $fontInfo = $Fonts | Where-Object FontName -eq $FontName
        $url = $fontInfo.DownloadUrl

        $tempFolder = New-MyProTempFolder
        Write-Verbose "New Temp Folder: ${tempFolder}"

        $tempZip = Join-Path $tempFolder "$FontName.zip"
        Write-Verbose "Save: ${tempZip}"
        Invoke-WebRequest -Uri $url -OutFile $tempZip

        Write-Verbose "Extract: ${tempZip}"
        Expand-Archive -Path $tempZip -DestinationPath $tempFolder

        $fontFiles = Get-ChildItem -Path $tempFolder -Filter "*.?tf" -Verbose

        $fontFileInfos = @()
        foreach ($file in $fontFiles) {
            Write-Verbose "Evalute: $($file.Name)"
            $match = $fontFileRegex.Match($file.Name)
            if ($match.Success) {
                $info = [NerdFontFileInfo]::new()
                $info.FileInfo = $file
                $info.Format = $match.Groups['type'].Value
                $info.IsMonoGlyphs = $match.Groups['mono'].Success
                $info.IsWindowsCompatible = $match.Groups['windows'].Success
                $fontFileInfos += $info
            } else {
                Write-Warning "Unexpected Font Filename Format: '$($file.Name)'"
            }
        }

        $format = 'otf'
        $preferMono = $false

        $fontFileInfos |
            Where-Object { $_.IsWindowsCompatible -eq $IsWindows } |
            Where-Object { $_.IsMonoGlyphs -eq $preferMono } |
            Where-Object { $_.Format -eq $format } |
            ForEach-Object {
                Install-MyProFont -Path $_.FileInfo
            }
    }
}



function New-TemporaryFolder {
    $tempPath = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $tempPath
}

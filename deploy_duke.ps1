[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$BuildPath = (Join-Path $PSScriptRoot 'build\web'),
    [string]$DestinationPath = 'Z:\public_html\everfront'
)

$ErrorActionPreference = 'Stop'
$requiredFiles = @('index.html', 'index.js', 'index.wasm', 'index.pck')
foreach ($fileName in $requiredFiles) {
    $sourceFile = Join-Path $BuildPath $fileName
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        throw "Godot Web file missing: $sourceFile. Export the Web preset first; this script does not build."
    }
}

if (-not (Test-Path -LiteralPath 'Z:\' -PathType Container)) {
    throw 'Z: is unavailable. Connect the Duke CIFS home directory before deploying.'
}

$sourceRoot = (Resolve-Path -LiteralPath $BuildPath).Path
$destinationRoot = [System.IO.Path]::GetFullPath($DestinationPath)
if ($sourceRoot.TrimEnd('\') -eq $destinationRoot.TrimEnd('\')) {
    throw 'Build and deployment directories must be different.'
}

if ($PSCmdlet.ShouldProcess($destinationRoot, 'Upload Godot Web build; replace matching files including index.html')) {
    New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null
    # Copy only build files. Do not delete the existing Unity build or other hosted content.
    foreach ($file in Get-ChildItem -LiteralPath $sourceRoot -File) {
        if ($file.Extension -eq '.import') { continue }
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $destinationRoot $file.Name) -Force
    }
    $mimeConfig = Join-Path $PSScriptRoot 'tools\duke.htaccess'
    $destinationConfig = Join-Path $destinationRoot '.htaccess'
    if (Test-Path -LiteralPath $mimeConfig) {
        if (Test-Path -LiteralPath $destinationConfig) {
            $existingConfig = Get-Content -LiteralPath $destinationConfig -Raw
            foreach ($mimeLine in Get-Content -LiteralPath $mimeConfig) {
                if (-not $existingConfig.Contains($mimeLine)) { Add-Content -LiteralPath $destinationConfig -Value $mimeLine }
            }
        } else {
            Copy-Item -LiteralPath $mimeConfig -Destination $destinationConfig
        }
    }
    foreach ($fileName in $requiredFiles) {
        $sourceHash = (Get-FileHash -LiteralPath (Join-Path $sourceRoot $fileName) -Algorithm SHA256).Hash
        $deployedHash = (Get-FileHash -LiteralPath (Join-Path $destinationRoot $fileName) -Algorithm SHA256).Hash
        if ($sourceHash -ne $deployedHash) { throw "Deployment verification failed: $fileName" }
    }
    Write-Host 'Deployment succeeded.'
    Write-Host "Destination: $destinationRoot"
    Write-Host 'Default Duke URL: https://people.duke.edu/~wz204/everfront/'
}

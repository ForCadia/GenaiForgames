[CmdletBinding()]
param([int]$Port = 8000)

$ErrorActionPreference = 'Stop'
$buildPath = Join-Path $PSScriptRoot 'build\web'
$indexPath = Join-Path $buildPath 'index.html'
if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
    throw 'Web build missing. Export the Web preset first.'
}
$url = "http://127.0.0.1:$Port/"
$existing = $null
try { $existing = Invoke-WebRequest ($url + 'index.html') -UseBasicParsing -TimeoutSec 2 } catch {}
if ($null -ne $existing) {
    if ($existing.Content.Trim() -ne (Get-Content -LiteralPath $indexPath -Raw).Trim()) {
        throw "Port $Port serves another project. Use .\start_web.ps1 -Port 8001."
    }
} else {
    $python = (Get-Command python -ErrorAction Stop).Source
    $arguments = @('-m', 'http.server', "$Port", '--bind', '127.0.0.1', '--directory', ('"' + $buildPath + '"'))
    $server = Start-Process -FilePath $python -ArgumentList $arguments -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru
    $ready = $false
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        Start-Sleep -Milliseconds 250
        try {
            $response = Invoke-WebRequest ($url + 'index.html') -UseBasicParsing -TimeoutSec 1
            if ($response.Content.Trim() -eq (Get-Content -LiteralPath $indexPath -Raw).Trim()) { $ready = $true; break }
        } catch {}
    }
    if (-not $ready) { throw "HTTP server failed to start. Check port $Port and Python." }
    Write-Host "Server PID: $($server.Id). Stop with: Stop-Process -Id $($server.Id)"
}
Write-Host "Open: $url (do not double-click index.html)"
Start-Process $url

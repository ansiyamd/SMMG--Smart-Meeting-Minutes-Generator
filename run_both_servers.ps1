<#
One-click launcher for both services used by the Flutter app:
 - Bot server (Node/Puppeteer) on port 3000
 - Minutes backend (Flask) on port 5000

Run from PowerShell:
  .\run_both_servers.ps1
#>

$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$botDir = Join-Path $projectRoot "Smartmeetingminutesgeneratojitsimeet\server"
$backendDir = Join-Path $projectRoot "minutes_generator_jitsi_meet"

function Test-PortOpen {
	param([int]$Port)
	try {
		$conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1
		return $null -ne $conn
	} catch {
		return $false
	}
}

function Get-PortOwnerPid {
	param([int]$Port)
	try {
		$conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1
		if ($null -ne $conn) {
			return $conn.OwningProcess
		}
	} catch {}
	return $null
}

function Wait-Http {
	param(
		[string]$Url,
		[int]$Retries = 20,
		[int]$DelayMs = 1000
	)

	for ($i = 0; $i -lt $Retries; $i++) {
		try {
			$res = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2
			if ($res.StatusCode -ge 200 -and $res.StatusCode -lt 500) {
				return $true
			}
		} catch {}
		Start-Sleep -Milliseconds $DelayMs
	}
	return $false
}

Write-Host "" 
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Smart Meeting Minutes - Start Both" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $botDir)) {
	throw "Bot server folder not found: $botDir"
}
if (-not (Test-Path $backendDir)) {
	throw "Flask backend folder not found: $backendDir"
}

# Detect local IPv4 for app URL hints
$ip = $null
try {
	$addrs = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {
		$_.IPAddress -match '^\d+\.\d+\.\d+\.\d+$' -and
		$_.IPAddress -notmatch '^127\.' -and
		$_.IPAddress -notmatch '^169\.'
	}
	if ($addrs) {
		$ip = ($addrs | Select-Object -First 1).IPAddress
	}
} catch {}

if ([string]::IsNullOrWhiteSpace($ip)) {
	try {
		$ip = (ipconfig | Select-String -Pattern 'IPv4 Address.*?:\s*([0-9\.]+)' | Select-Object -First 1).Matches[0].Groups[1].Value
	} catch {}
}

if ([string]::IsNullOrWhiteSpace($ip)) {
	$ip = "localhost"
}

# Start bot server if not already running
if (Test-PortOpen -Port 3000) {
	Write-Host "Bot server already running on port 3000." -ForegroundColor Yellow
} else {
	Write-Host "Starting bot server (port 3000)..." -ForegroundColor Cyan
	Start-Process powershell -ArgumentList @(
		"-NoExit",
		"-ExecutionPolicy", "Bypass",
		"-Command", "cd '$botDir'; if (-not (Test-Path node_modules)) { npm install }; `$env:BOT_HEADLESS='false'; npm start"
	) -WindowStyle Normal | Out-Null
}

# Start Flask backend (must be modular backend exposing /api/health)
$backendNeedsStart = $true
if (Test-PortOpen -Port 5000) {
	$backendApiOk = Wait-Http -Url "http://localhost:5000/api/health" -Retries 2 -DelayMs 400
	if ($backendApiOk) {
		Write-Host "Flask modular backend already running on port 5000." -ForegroundColor Yellow
		$backendNeedsStart = $false
	} else {
		Write-Host "Port 5000 is in use by a non-modular backend. Restarting with modular backend..." -ForegroundColor Yellow
		$ownerPid = Get-PortOwnerPid -Port 5000
		if ($ownerPid) {
			try { Stop-Process -Id $ownerPid -Force -ErrorAction Stop } catch {}
			Start-Sleep -Milliseconds 700
		}
	}
}

if ($backendNeedsStart) {
	Write-Host "Starting Flask backend (modular, port 5000)..." -ForegroundColor Cyan
	Start-Process powershell -ArgumentList @(
		"-NoExit",
		"-ExecutionPolicy", "Bypass",
		"-Command", "cd '$backendDir'; .\run_backend.ps1"
	) -WindowStyle Normal | Out-Null
}

# Wait for services
$botOk = Wait-Http -Url "http://localhost:3000/api/health"
$backendOk = Wait-Http -Url "http://localhost:5000/api/health"

Write-Host ""
if ($botOk) {
	Write-Host "Bot server: OK  -> http://${ip}:3000" -ForegroundColor Green
} else {
	Write-Host "Bot server: NOT READY on port 3000" -ForegroundColor Red
}

if ($backendOk) {
	Write-Host "Backend:    OK  -> http://${ip}:5000" -ForegroundColor Green
} else {
	Write-Host "Backend:    NOT READY (expected /api/health on port 5000)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Set these in Flutter app:" -ForegroundColor White
Write-Host "  Bot URL:     http://${ip}:3000" -ForegroundColor White
Write-Host "  Backend URL: http://${ip}:5000" -ForegroundColor White
Write-Host ""
Write-Host "Run app: cd Smartmeetingminutesgeneratojitsimeet; flutter run -d <device>" -ForegroundColor Gray

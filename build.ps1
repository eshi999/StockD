# build_windows.ps1 — StockD Unified Production Windows Build Script
$projectRoot = Get-Location
$buildDir = "build\windows\x64\runner\Release"
$bundleDir = "backend_bundle"
$targetDir = "$buildDir\data\flutter_assets\backend_bundle"
$PythonUrl = "https://github.com/astral-sh/python-build-standalone/releases/download/20260510/cpython-3.12.13+20260510-x86_64-pc-windows-msvc-install_only.tar.gz"

Write-Host "--- Performing Workspace Cleanup ---" -ForegroundColor Yellow
if (Test-Path $bundleDir) { Remove-Item -Recurse -Force $bundleDir -ErrorAction SilentlyContinue }
if (Test-Path "build\windows") { Remove-Item -Recurse -Force "build\windows" -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

Write-Host "--- Generating Icon & Injecting into Frontend ---" -ForegroundColor Cyan
$PngPath = "$projectRoot\assets\images\StockD.png"
$IcoPath = "$projectRoot\assets\images\StockD.ico"
$FlutterIconPath = "$projectRoot\windows\runner\resources\app_icon.ico"
if (Test-Path $PngPath) { 
    magick $PngPath -define icon:auto-resize=256,128,64,48,32,16 $IcoPath 
    Copy-Item -Path $IcoPath -Destination $FlutterIconPath -Force
}

Write-Host "--- Building Flutter Native Frontend ---" -ForegroundColor Cyan
flutter clean
flutter build windows --release --build-name=1.2.0 --build-number=1
if ($LastExitCode -ne 0) { Write-Error "❌ Flutter build failed."; Exit 1 }

Write-Host "--- Downloading Python Engine ---" -ForegroundColor Cyan
$archiveName = "python.tar.gz"
if (Test-Path $archiveName) { Remove-Item -Force $archiveName }
Invoke-WebRequest -Uri $PythonUrl -OutFile $archiveName

Write-Host "--- Extracting Python Runtime ---" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $bundleDir | Out-Null
& "tar.exe" -xzf $archiveName -C $bundleDir --strip-components=1

Write-Host "--- Bootstrapping Environment ---" -ForegroundColor Cyan
$PythonExe = "$bundleDir\python.exe"
& $PythonExe -m ensurepip
& $PythonExe -m pip install --no-cache-dir tensorflow fastapi uvicorn pandas scikit-learn yfinance numpy peewee h5py joblib

Write-Host "--- Syncing ML Scripts & Platform-Agnostic Artifacts ---" -ForegroundColor Cyan
Remove-Item -Path "ML\artifacts\*.pkl", "ML\artifacts\*.keras" -ErrorAction SilentlyContinue
Copy-Item -Path "ML\*.py" -Destination $bundleDir -Force
if (!(Test-Path "$bundleDir\artifacts")) { New-Item -ItemType Directory -Path "$bundleDir\artifacts" }
Copy-Item -Path "ML\artifacts\*.json", "ML\artifacts\*.h5", "ML\artifacts\*.joblib" -Destination "$bundleDir\artifacts" -Force

Write-Host "--- Creating Windows Launcher ---" -ForegroundColor Cyan
# Ensure legacy launchers are gone to prevent execution confusion
Remove-Item -Path "$bundleDir\launch_sage.bat" -ErrorAction SilentlyContinue 

$LauncherPath = "$bundleDir\sage_launcher.bat"
$LauncherContent = @"
@echo off
REM Force the working directory to the location of this script
pushd "%~dp0"

REM Configure the environment to prioritize the bundled Python
set "PYTHONHOME=%~dp0"
set "PYTHONPATH=%~dp0"
set "PATH=%~dp0;%~dp0\Scripts;%PATH%"

REM Start the backend silently
start /B python.exe main.py
popd
"@
$LauncherContent | Set-Content -Path $LauncherPath

Write-Host "--- Merging Bundle into Flutter Assets ---" -ForegroundColor Cyan
if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force }
Copy-Item -Path "$bundleDir\*" -Destination $targetDir -Recurse -Force

if (Test-Path "$buildDir\runner.exe") {
    Rename-Item -Path "$buildDir\runner.exe" -NewName "StockD.exe" -Force
}

Write-Host "--- Compiling Inno Setup Installer ---" -ForegroundColor Cyan
$isccPath = "C:\Program Files (x86)\Inno Setup 6\iscc.exe"
if (Test-Path $isccPath) { & $isccPath "$projectRoot\stockd_installer.iss" }

Write-Host "Build Lifecycle Complete! Ready. ✅" -ForegroundColor Green
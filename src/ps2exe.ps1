$host.UI.RawUI.WindowTitle = "ps2exe"
cls

$ascii = @"
            ____               
  _ __  ___|___ \ _____  _____ 
 | '_ \/ __| __) / _ \ \/ / _ \
 | |_) \__ \/ __/  __/>  <  __/
 | .__/|___/_____\___/_/\_\___|
 |_|                           
"@
Write-Host $ascii -ForegroundColor Cyan

function Write-Prompt($text, $color='Green') {
    Write-Host $text -NoNewline -ForegroundColor $color
}

Write-Prompt "+ [ps2exe] - [input ps1 path] >> "
$ps1Path = Read-Host
if (-not (Test-Path $ps1Path)) {
    Write-Host "- [ps2exe] - [error] >> file not found" -ForegroundColor Red
    exit
}

Write-Prompt "+ [ps2exe] - [output exe path, leave blank for same name] >> "
$exePath = Read-Host
if ([string]::IsNullOrEmpty($exePath)) {
    $exePath = [System.IO.Path]::ChangeExtension($ps1Path, ".exe")
}

Write-Prompt "+ [ps2exe] - [select mode: 1=Console, 2=WinForms] >> "
$modeChoice = Read-Host
switch ($modeChoice) {
    '1' { $noConsole = $false; Write-Host "[*] Console mode selected" -ForegroundColor Yellow }
    '2' { $noConsole = $true;  Write-Host "[*] WinForms mode selected" -ForegroundColor Yellow }
    default { $noConsole = $false; Write-Host "[*] Invalid choice, defaulting to Console mode" -ForegroundColor Yellow }
}

$modulePath = "$env:TEMP\ps2exe.ps1"
if (-not (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue)) {
    Write-Host "[*] PS2EXE module not found, downloading..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MScholtes/PS2EXE/refs/heads/master/Module/ps2exe.ps1" -OutFile $modulePath -UseBasicParsing
        Import-Module $modulePath
    } catch {
        Write-Host "- [ps2exe] - [error] >> failed to download PS2EXE module" -ForegroundColor Red
        exit
    }
}

Write-Host "+ [ps2exe] - [compiling...]" -ForegroundColor Cyan
try {
    Invoke-ps2exe -InputFile $ps1Path -OutputFile $exePath -noConsole:$noConsole
    Write-Host "+ [ps2exe] - [success] >> $exePath created" -ForegroundColor Green
} catch {
    Write-Host "- [ps2exe] - [error] >> $($_.Exception.Message)" -ForegroundColor Red
}


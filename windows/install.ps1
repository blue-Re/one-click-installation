# =====================================================================
#  一键装机脚本（Windows / PowerShell）
#  用法（在本目录下）：
#    powershell -ExecutionPolicy Bypass -File .\install.ps1
#    .\install.ps1 40 50          # 只跑指定步骤（按前缀数字）
#    .\install.ps1 -Skip 70       # 跳过某些步骤
#  建议以【管理员】身份运行终端。各步骤脚本在 scripts\ 下，可单独运行。
# =====================================================================
[CmdletBinding()]
param(
  [string[]]$Select,       # 位置参数：要执行的步骤前缀，如 40 50
  [string[]]$Skip = @()    # 要跳过的步骤前缀
)

$ErrorActionPreference = 'Continue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $here
. "$here\scripts\lib.ps1"

# 按顺序执行的步骤（对应 scripts\*.ps1 文件名）
$steps = @(
  '00-preflight',
  '10-winget',
  '20-packages',
  '30-powershell',
  '40-node',
  '50-node-packages',
  '60-vscode-extensions',
  '70-databases',
  '90-manual-notes'
)

function Should-Run($id) {
  foreach ($s in $Skip)   { if ($id.StartsWith($s)) { return $false } }
  if (-not $Select -or $Select.Count -eq 0) { return $true }
  foreach ($s in $Select) { if ($id.StartsWith($s)) { return $true } }
  return $false
}

Write-Host @"
  +------------------------------------------+
  |  Windows 一键装机 . one-click-install     |
  +------------------------------------------+
"@ -ForegroundColor Cyan
Write-Log "项目目录：$here"
if ($Skip.Count -gt 0)   { Write-Warn2 "将跳过：$($Skip -join ', ')" }
if ($Select -and $Select.Count -gt 0) { Write-Warn2 "仅执行：$($Select -join ', ')" }

$failed = @()
foreach ($name in $steps) {
  $id = $name.Split('-')[0]
  if (Should-Run $id) {
    $path = Join-Path $here "scripts\$name.ps1"
    try { & $path }
    catch { Write-Err2 "步骤 $name 出错：$($_.Exception.Message)"; $failed += $name }
  } else {
    Write-Warn2 "跳过步骤：$name"
  }
}

Write-Host ""
if ($failed.Count -eq 0) {
  Write-Ok "全部步骤完成。关闭并重开终端即可生效。"
} else {
  Write-Err2 "以下步骤未成功，请查看上面日志：$($failed -join ', ')"
  exit 1
}

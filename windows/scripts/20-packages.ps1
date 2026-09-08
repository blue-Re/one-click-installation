# 20 安装 packages.winget 中列出的所有软件
. "$PSScriptRoot\lib.ps1"

Write-Step "安装 winget 软件清单"

$listFile = Join-Path $script:RepoRoot "packages.winget"
if (-not (Test-Path $listFile)) { Write-Err2 "缺少清单：$listFile"; exit 1 }

$new = 0; $skip = 0; $fail = @()
Get-Content $listFile | ForEach-Object {
  $id = ($_ -replace '#.*$', '').Trim()
  if (-not $id) { return }

  Write-Log "安装：$id"
  # winget 幂等：已装会自动跳过并返回“已安装”的退出码
  winget install --exact --id $id `
    --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
  $code = $LASTEXITCODE
  # 0 = 成功；-1978335189 (0x8A15002B) = 已安装最新版
  if ($code -eq 0) { $new++; Write-Ok "已安装：$id" }
  elseif ($code -eq -1978335189) { $skip++; Write-Ok "已是最新，跳过：$id" }
  else { $fail += $id; Write-Warn2 "安装可能失败（退出码 $code）：$id" }
}

Update-SessionPath
Write-Ok "软件清单完成：新增 $new，跳过 $skip"
if ($fail.Count -gt 0) { Write-Warn2 "以下项需留意：$($fail -join ', ')" }

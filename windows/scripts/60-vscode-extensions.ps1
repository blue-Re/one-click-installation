# 60 VS Code 插件：复用仓库根部 config/vscode-extensions.txt（与 mac 同一份清单）
. "$PSScriptRoot\lib.ps1"

Write-Step "安装 VS Code 插件"

Update-SessionPath

# 定位 code CLI
$codeBin = $null
if (Test-Cmd code) {
  $codeBin = 'code'
} else {
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
  )
  $codeBin = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $codeBin) {
  Write-Err2 "未找到 VS Code 的 code 命令。请确认已安装 Microsoft.VisualStudioCode，并重开终端。"
  exit 1
}

# 清单在仓库根目录的 config/ 下（mac 与 windows 共用）
$listFile = Join-Path $script:RepoRoot "..\config\vscode-extensions.txt"
$listFile = (Resolve-Path $listFile -ErrorAction SilentlyContinue).Path
if (-not $listFile -or -not (Test-Path $listFile)) {
  Write-Err2 "找不到插件清单 config/vscode-extensions.txt"
  exit 1
}

# 已装插件（小写便于比对）
$installed = @()
try { $installed = (& $codeBin --list-extensions 2>$null) | ForEach-Object { $_.ToLower() } } catch {}

$new = 0; $skip = 0
Get-Content $listFile | ForEach-Object {
  $ext = ($_ -replace '#.*$', '').Trim()
  if (-not $ext) { return }
  if ($installed -contains $ext.ToLower()) { $skip++; return }
  Write-Log "安装插件：$ext"
  & $codeBin --install-extension $ext --force
  if ($LASTEXITCODE -eq 0) { $new++ } else { Write-Warn2 "安装失败：$ext（ID 可能变更，去插件市场核对）" }
}

Write-Ok "VS Code 插件完成：新增 $new，已存在跳过 $skip"

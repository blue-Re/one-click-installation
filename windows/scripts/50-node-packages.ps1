# 50 pnpm / yarn：通过 Node 自带 corepack 启用；npm 切国内源
. "$PSScriptRoot\lib.ps1"

Write-Step "启用 pnpm 与 yarn"

Update-SessionPath

if (-not (Test-Cmd node)) {
  Write-Warn2 "找不到 node，请先完成第 40 步并重开终端，再运行本步骤。"
  return
}

# npm 国内镜像（加速）
try { npm config set registry https://registry.npmmirror.com; Write-Ok "npm registry -> npmmirror" } catch {}

if (Test-Cmd corepack) {
  Write-Log "corepack 启用 pnpm / yarn..."
  corepack enable
  corepack prepare pnpm@latest --activate
  corepack prepare yarn@stable --activate
  Update-SessionPath
  $pnpmV = (pnpm -v 2>$null); $yarnV = (yarn -v 2>$null)
  Write-Ok "pnpm $pnpmV / yarn $yarnV"
} else {
  Write-Warn2 "无 corepack，改用 npm 全局安装 pnpm / yarn"
  npm install -g pnpm yarn
  Write-Ok "pnpm / yarn 已通过 npm 安装"
}

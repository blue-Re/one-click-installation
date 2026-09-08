# 40 Node.js：通过 nvm-windows 安装 LTS
. "$PSScriptRoot\lib.ps1"

Write-Step "安装 Node.js（经 nvm-windows）"

Update-SessionPath

if (-not (Test-Cmd nvm)) {
  Write-Warn2 "当前会话找不到 nvm 命令。nvm-windows 已由 20 步装好，但需要新终端刷新 PATH。"
  Write-Warn2 "请关闭并重新打开（管理员）终端，再单独运行本步骤：  .\scripts\40-node.ps1"
  Write-Warn2 "或手动执行：nvm install lts;  nvm use lts"
  return
}

Write-Log "配置 nvm 国内镜像（加速 Node 下载）..."
try {
  nvm node_mirror https://npmmirror.com/mirrors/node/
  nvm npm_mirror  https://npmmirror.com/mirrors/npm/
  Write-Ok "nvm 镜像已设为 npmmirror"
} catch { Write-Warn2 "设置 nvm 镜像失败（旧版本 nvm 可能不支持，忽略即可）" }

Write-Log "安装 Node LTS..."
nvm install lts
nvm use lts

Update-SessionPath
if (Test-Cmd node) {
  Write-Ok "Node $(node -v) / npm $(npm -v)"
} else {
  Write-Warn2 "node 尚未进入 PATH，重开终端后应可用。"
}

# 30 PowerShell 美化与增强（对应 mac 的 oh-my-zsh）
# Oh My Posh 主题 + PSReadLine 自动建议/语法高亮 + posh-git + Terminal-Icons
. "$PSScriptRoot\lib.ps1"

Write-Step "配置 PowerShell（Oh My Posh + PSReadLine + posh-git + 图标）"

Update-SessionPath

# 确保 PSGallery 可用且被信任（安装模块用）
try {
  if (-not (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Default -ErrorAction SilentlyContinue
  }
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
} catch {}

# 安装增强模块（对应 zsh 的 autosuggestions/syntax-highlighting/git 插件/图标）
foreach ($m in 'PSReadLine','posh-git','Terminal-Icons') {
  if (Get-Module -ListAvailable -Name $m) {
    Write-Ok "模块已存在：$m"
  } else {
    Write-Log "安装模块：$m"
    try { Install-Module $m -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop; Write-Ok "已安装：$m" }
    catch { Write-Warn2 "模块安装失败（网络？）：$m —— 可稍后手动 Install-Module $m -Scope CurrentUser" }
  }
}

# 要写入的 profile 内容（相当于 .zshrc 里的插件配置）
$profileBlock = @'
# --- Oh My Posh 提示符主题 ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
  oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
}

# --- PSReadLine：历史自动建议 + 语法高亮（对应 zsh-autosuggestions / syntax-highlighting）---
if (Get-Module -ListAvailable -Name PSReadLine) {
  Import-Module PSReadLine
  Set-PSReadLineOption -PredictionSource History
  try { Set-PSReadLineOption -PredictionViewStyle ListView } catch {}
  Set-PSReadLineOption -EditMode Windows
}

# --- posh-git：git 状态提示（对应 zsh 的 git 插件）---
if (Get-Module -ListAvailable -Name posh-git) { Import-Module posh-git }

# --- Terminal-Icons：文件图标 ---
if (Get-Module -ListAvailable -Name Terminal-Icons) { Import-Module Terminal-Icons }
'@

# 同时写入 Windows PowerShell(5.1) 与 PowerShell 7 的 profile，谁打开都生效
$profiles = @(
  (Join-Path $HOME 'Documents\WindowsPowerShell\profile.ps1'),
  (Join-Path $HOME 'Documents\PowerShell\profile.ps1')
)
foreach ($p in $profiles) {
  Add-Block -File $p -Marker 'oci-powershell' -Content $profileBlock
  Write-Ok "已写入 profile：$p"
}

Write-Warn2 "提示符图标需要 Nerd Font 字体才好看。可在 Windows Terminal 设置里把字体改成 'CaskaydiaCove Nerd Font'（Oh My Posh 官网有安装方法）。"

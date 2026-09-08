# 10 winget：确认 Windows 包管理器可用
. "$PSScriptRoot\lib.ps1"

Write-Step "检查 winget（Windows 包管理器）"

if (Test-Cmd winget) {
  Write-Ok "winget 可用：$(winget --version)"
  # 接受源协议，避免后续每次安装都交互询问
  try { winget source update | Out-Null } catch {}
} else {
  Write-Err2 "未找到 winget。它随『应用安装程序 (App Installer)』提供。"
  Write-Warn2 "请到 Microsoft Store 搜索并安装『应用安装程序』，或访问："
  Write-Warn2 "  https://aka.ms/getwinget"
  Write-Warn2 "装好后重开终端，再重新运行本脚本。"
  exit 1
}

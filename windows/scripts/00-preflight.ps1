# 00 预检：确认 Windows 版本、PowerShell 版本
. "$PSScriptRoot\lib.ps1"

Write-Step "预检环境"

if ($PSVersionTable.PSVersion.Major -lt 5) {
  Write-Err2 "需要 PowerShell 5.1 或更高版本。"
  exit 1
}

$arch = if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { 'x86' }
$os = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue)
if ($os) { Write-Ok "$($os.Caption)  ($arch)" }
Write-Ok "PowerShell $($PSVersionTable.PSVersion)"

# 建议以管理员运行（安装软件、注册服务更顺）
$isAdmin = ([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
  Write-Warn2 "当前不是管理员。部分软件/服务安装可能失败或弹 UAC。"
  Write-Warn2 "建议：右键 Windows Terminal / PowerShell -> 以管理员身份运行，再执行本脚本。"
}

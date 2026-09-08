# 90 收尾提示：无法脚本化的部分集中提醒
. "$PSScriptRoot\lib.ps1"

Write-Step "需要手动完成的部分"

@"

Chrome 扩展无法命令行批量安装，请点开逐个安装：
  • React Developer Tools  https://chromewebstore.google.com/detail/fmkadmapgofadopljbjfkapdkoienihi
  • Vue.js devtools         https://chromewebstore.google.com/detail/nhdogjmejiglipccpnnnanhbledajbpd
  • Redux DevTools          https://chromewebstore.google.com/detail/lmhkpmbekcpmknklioeibfkpmmfibljd
  • Lighthouse              https://chromewebstore.google.com/detail/blipmdconlkpinefehnmjammfjpmpbjk
  • ColorZilla              https://chromewebstore.google.com/detail/bhlhnicpbhignbdhedgjhgdocnmhomnp
  • JSON Viewer             https://chromewebstore.google.com/detail/gbmdgpbipfallnflgajpaliibnhdgobh

Xcode：仅 macOS 才有，Windows 无对应物（已跳过）。

MySQL：若第 70 步提示需手动，请用『开始菜单 -> MySQL Installer』安装 Server，
       安装向导里把 root 密码设为 12345678。

Docker Desktop：首次需手动打开完成初始化；Windows 需开启 WSL2（Docker 会引导）。

字体：想让 Oh My Posh 图标正常显示，装一个 Nerd Font 并在 Windows Terminal 里选它：
       oh-my-posh font install CascadiaCode

全部完成后，关闭并重新打开终端即可让所有配置生效。
"@ | Write-Host

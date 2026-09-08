#!/usr/bin/env bash
# 90 收尾提示：无法脚本化的部分（Chrome 扩展、完整版 Xcode 等）集中提醒
set -uo pipefail
source "$(dirname "$0")/lib.sh"

step "需要手动完成的部分"

cat <<'EOF'

Chrome 扩展无法命令行批量安装（Chrome 网上应用店限制），请点开逐个安装：
  • React Developer Tools  https://chromewebstore.google.com/detail/fmkadmapgofadopljbjfkapdkoienihi
  • Vue.js devtools         https://chromewebstore.google.com/detail/nhdogjmejiglipccpnnnanhbledajbpd
  • Redux DevTools          https://chromewebstore.google.com/detail/lmhkpmbekcpmknklioeibfkpmmfibljd
  • Lighthouse              https://chromewebstore.google.com/detail/blipmdconlkpinefehnmjammfjpmpbjk
  • ColorZilla              https://chromewebstore.google.com/detail/bhlhnicpbhignbdhedgjhgdocnmhomnp
  • JSON Viewer             https://chromewebstore.google.com/detail/gbmdgpbipfallnflgajpaliibnhdgobh

完整版 Xcode（体积大、需 Apple ID）：
  先登录  mas signin <你的AppleID>
  再安装  mas install 497799835
  或直接在 App Store 搜索 Xcode 安装。
  （命令行工具 Command Line Tools 已在预检阶段自动装好，日常前端开发够用。）

Docker Desktop：首次需手动打开 /Applications/Docker.app 完成初始化并授予权限。

全部完成后，执行下面这行让配置生效（或直接重开终端）：
  source ~/.zshrc
EOF

#!/usr/bin/env bash
# 40 nvm + Node：装 nvm、配置环境变量、装 LTS 版 Node
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "安装 nvm 与 Node.js"

export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
  ok "nvm 已安装"
else
  log "安装 nvm..."
  # 官方源；国内失败可改用 gitee 镜像（见下方注释）
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    || curl -o- https://gitee.com/mirrors/nvm/raw/v0.39.0/install.sh | bash
fi

# 环境变量写入 .zshrc（幂等）。nvm 安装脚本通常也会写一份，这里确保存在。
append_block "$HOME/.zshrc" "nvm" \
  'export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# 国内加速 Node 下载（可选）
export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"'

# 本次会话加载 nvm
export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if has nvm; then
  log "安装 Node.js LTS..."
  nvm install --lts
  nvm alias default 'lts/*'
  nvm use --lts
  ok "Node $(node -v) / npm $(npm -v)"
else
  err "nvm 未能加载，请重开终端后手动执行：nvm install --lts"
fi

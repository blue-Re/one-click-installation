#!/usr/bin/env bash
# 10 Homebrew：用国内 gitee 镜像安装，并把下载源也切到国内镜像加速
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "安装 Homebrew（国内镜像）"

if has brew; then
  ok "Homebrew 已安装：$(brew --version | head -1)"
else
  log "通过 gitee 镜像安装 Homebrew..."
  # 该镜像脚本会交互式询问，跟随提示即可
  /bin/bash -c "$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)"
fi

# 把 brew 加入当前 shell 的 PATH（Apple Silicon 在 /opt/homebrew，Intel 在 /usr/local）
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  BREW_PREFIX="/opt/homebrew"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
  BREW_PREFIX="/usr/local"
fi

# 持久化到 .zshrc（幂等）
append_block "$HOME/.zshrc" "homebrew-shellenv" \
  "eval \"\$(${BREW_PREFIX:-/opt/homebrew}/bin/brew shellenv)\""

# 配置国内下载镜像（中科大源），大幅加速 formula/bottle 下载
append_block "$HOME/.zshrc" "homebrew-mirror" \
  'export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_NO_AUTO_UPDATE=1'

# 让镜像在本次会话即刻生效
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_NO_AUTO_UPDATE=1

ok "Homebrew 就绪：$(brew --prefix)"

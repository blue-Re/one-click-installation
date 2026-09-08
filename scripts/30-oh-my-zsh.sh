#!/usr/bin/env bash
# 30 oh-my-zsh：安装框架 + 两个外部插件，并配置 plugins 数组
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "安装 oh-my-zsh 及插件"

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
if [ -d "$ZSH_DIR" ]; then
  ok "oh-my-zsh 已安装"
else
  log "安装 oh-my-zsh..."
  # --unattended：不自动改默认 shell、不自动启动新 zsh，便于脚本继续往下跑
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
ensure_dir "$ZSH_CUSTOM/plugins"

# 外部插件（内置插件 git/node/npm/docker/vscode 无需下载）
clone_plugin() {
  local name="$1" url="$2" dest="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dest" ]; then ok "插件已存在：$name"; else
    log "下载插件：$name"; git clone --depth=1 "$url" "$dest"
  fi
}
clone_plugin zsh-autosuggestions     https://gitee.com/mirror-github/zsh-autosuggestions.git
clone_plugin zsh-syntax-highlighting https://gitee.com/mirror-github/zsh-syntax-highlighting.git

# 设置 plugins 数组：先删掉旧的 plugins=(...) 多行块，再追加我们的
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

# 用 awk 删除从 "plugins=(" 到其后第一个 ")" 之间的所有行
awk '
  /^plugins=\(/ {del=1}
  del==0 {print}
  del==1 && /\)/ {del=0}
' "$ZSHRC" > "$ZSHRC.tmp" && mv "$ZSHRC.tmp" "$ZSHRC"

# 追加标准 plugins 数组（zsh-syntax-highlighting 必须放最后）
append_block "$ZSHRC" "omz-plugins" 'plugins=(
  git
  zsh-autosuggestions
  node
  npm
  docker
  vscode
  zsh-syntax-highlighting
)'

ok "已配置 plugins 数组（syntax-highlighting 置于末尾）"

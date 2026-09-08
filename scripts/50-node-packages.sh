#!/usr/bin/env bash
# 50 pnpm / yarn：通过 Node 自带的 corepack 启用（无需额外下载）
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "启用 pnpm 与 yarn"

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm use --lts >/dev/null 2>&1 || true

if ! has node; then
  err "未找到 node，请先跑 40-nvm-node.sh 并重开终端"; exit 1
fi

# npm 国内镜像（可选，加速）
npm config set registry https://registry.npmmirror.com
ok "npm registry -> npmmirror"

if has corepack; then
  log "corepack 启用 pnpm / yarn..."
  corepack enable
  corepack prepare pnpm@latest --activate
  corepack prepare yarn@stable --activate
  ok "pnpm $(pnpm -v 2>/dev/null || echo '?') / yarn $(yarn -v 2>/dev/null || echo '?')"
else
  warn "无 corepack，改用 npm 全局安装 pnpm / yarn"
  npm install -g pnpm yarn
  ok "pnpm / yarn 已通过 npm 安装"
fi

#!/usr/bin/env bash
# 20 brew bundle：按 Brewfile 一次性安装所有 CLI / 数据库 / GUI 软件
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "安装 Brewfile 中的软件"

if ! has brew; then err "未找到 brew，请先跑 10-homebrew.sh"; exit 1; fi

log "brew bundle 安装中（首次较慢，耐心等）..."
brew bundle --file="$REPO_ROOT/Brewfile" --no-lock

ok "Brewfile 软件安装完成"

#!/usr/bin/env bash
# 00 预检：确认 macOS、架构、Xcode 命令行工具（编译很多东西的前提）
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "预检环境"

if [ "$(uname)" != "Darwin" ]; then
  err "此脚本仅用于 macOS。"; exit 1
fi

ok "macOS $(sw_vers -productVersion 2>/dev/null || echo '?')  架构 $(uname -m)"

# Xcode 命令行工具（Homebrew / git / 编译原生模块都依赖它）
if xcode-select -p >/dev/null 2>&1; then
  ok "Xcode 命令行工具已安装"
else
  log "安装 Xcode 命令行工具（会弹系统对话框，点“安装”后等它装完）..."
  xcode-select --install || true
  warn "请在弹窗里完成安装后，重新运行本脚本继续。"
  # 等待用户装完
  until xcode-select -p >/dev/null 2>&1; do
    printf "  等待命令行工具安装完成... (按 Ctrl+C 可中断)\r"
    sleep 5
  done
  echo
  ok "Xcode 命令行工具安装完成"
fi

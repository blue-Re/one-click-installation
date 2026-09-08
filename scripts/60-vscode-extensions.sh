#!/usr/bin/env bash
# 60 VS Code 插件：按 config/vscode-extensions.txt 增量安装
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "安装 VS Code 插件"

# 定位 code CLI（cask 安装后可能还没进 PATH）
CODE_BIN=""
if has code; then
  CODE_BIN="code"
elif [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [ -z "$CODE_BIN" ]; then
  err "未找到 VS Code 的 code 命令，请确认已安装 visual-studio-code（Brewfile 里有）。"
  exit 1
fi

LIST="$REPO_ROOT/config/vscode-extensions.txt"
[ -f "$LIST" ] || { err "缺少插件清单：$LIST"; exit 1; }

# 已装列表（小写，便于比对）
INSTALLED="$("$CODE_BIN" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"

count=0; skip=0
while IFS= read -r raw; do
  # 去掉行内注释与首尾空白
  ext="$(printf '%s' "$raw" | sed 's/#.*//' | xargs)"
  [ -z "$ext" ] && continue
  if printf '%s\n' "$INSTALLED" | grep -qx "$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"; then
    skip=$((skip+1)); continue
  fi
  log "安装插件：$ext"
  "$CODE_BIN" --install-extension "$ext" --force || warn "安装失败：$ext（可能 ID 变更，去插件市场核对）"
  count=$((count+1))
done < "$LIST"

ok "VS Code 插件完成：新增 $count，已存在跳过 $skip"

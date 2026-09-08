#!/usr/bin/env bash
# =====================================================================
#  一键装机脚本（macOS）
#  用法：
#    ./install.sh              # 按顺序执行全部步骤
#    ./install.sh 40 50        # 只跑指定步骤（按前缀数字）
#    SKIP="70" ./install.sh    # 跳过某些步骤
#  各步骤脚本在 scripts/ 下，可单独运行。
# =====================================================================
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
source "$HERE/scripts/lib.sh"

# 所有步骤（按文件名前缀排序）
ALL_STEPS=(
  "00-preflight"
  "10-homebrew"
  "20-brew-bundle"
  "30-oh-my-zsh"
  "40-nvm-node"
  "50-node-packages"
  "60-vscode-extensions"
  "70-databases"
  "90-manual-notes"
)

SKIP="${SKIP:-}"
SELECT=("$@")   # 命令行传入的步骤前缀（可选）

want() {
  local id="$1"
  # 命中 SKIP 则不跑
  for s in $SKIP; do [[ "$id" == "$s"* ]] && return 1; done
  # 未指定 SELECT 则全跑
  [ ${#SELECT[@]} -eq 0 ] && return 0
  for s in "${SELECT[@]}"; do [[ "$id" == "$s"* ]] && return 0; done
  return 1
}

printf "${C_BOLD}${C_BLUE}"
cat <<'BANNER'
  ┌────────────────────────────────────────┐
  │   macOS 一键装机  ·  one-click-install   │
  └────────────────────────────────────────┘
BANNER
printf "${C_RESET}"
log "项目目录：$HERE"
[ -n "$SKIP" ] && warn "将跳过：$SKIP"
[ ${#SELECT[@]} -gt 0 ] && warn "仅执行：${SELECT[*]}"

FAILED=()
for name in "${ALL_STEPS[@]}"; do
  id="${name%%-*}"
  if want "$id"; then
    if bash "$HERE/scripts/${name}.sh"; then :; else
      err "步骤 ${name} 执行失败（继续后续步骤）"
      FAILED+=("$name")
    fi
  else
    warn "跳过步骤：${name}"
  fi
done

echo
if [ ${#FAILED[@]} -eq 0 ]; then
  ok "全部步骤完成 🎉  运行 'source ~/.zshrc' 或重开终端生效。"
else
  err "以下步骤未成功，请查看上面的日志：${FAILED[*]}"
  exit 1
fi

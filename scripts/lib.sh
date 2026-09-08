#!/usr/bin/env bash
# 公共函数库：日志、工具检测、幂等辅助。被各模块 source 引用。

# ---- 颜色与日志 ----
if [ -t 1 ]; then
  C_RESET="\033[0m"; C_BLUE="\033[34m"; C_GREEN="\033[32m"
  C_YELLOW="\033[33m"; C_RED="\033[31m"; C_BOLD="\033[1m"
else
  C_RESET=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_BOLD=""
fi

log()   { printf "${C_BLUE}==>${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GREEN}✓${C_RESET} %s\n" "$*"; }
warn()  { printf "${C_YELLOW}!${C_RESET} %s\n" "$*"; }
err()   { printf "${C_RED}✗${C_RESET} %s\n" "$*" >&2; }
step()  { printf "\n${C_BOLD}${C_BLUE}▸ %s${C_RESET}\n" "$*"; }

# 命令是否存在
has() { command -v "$1" >/dev/null 2>&1; }

# 向文件中幂等追加一段带标记的内容。
# 用法: append_block <文件> <唯一标记> <内容...>
append_block() {
  local file="$1" marker="$2"; shift 2
  local content="$*"
  touch "$file"
  if grep -qF "# >>> ${marker} >>>" "$file" 2>/dev/null; then
    return 0   # 已存在，跳过
  fi
  {
    printf '\n# >>> %s >>>\n' "$marker"
    printf '%s\n' "$content"
    printf '# <<< %s <<<\n' "$marker"
  } >> "$file"
}

# 确保某目录存在
ensure_dir() { [ -d "$1" ] || mkdir -p "$1"; }

# 项目根目录（脚本所在目录的上一级）
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT

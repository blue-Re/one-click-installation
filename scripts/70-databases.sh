#!/usr/bin/env bash
# 70 数据库：启动 mysql / postgresql / mongodb，并把 root 密码设为 12345678
# 说明：数据库初始化较易受环境影响，本脚本尽力而为，失败会给出手动命令而非中断整体安装。
set -uo pipefail
source "$(dirname "$0")/lib.sh"

step "配置数据库（root / 12345678）"

if ! has brew; then err "需要 brew"; exit 1; fi
BREW_PREFIX="$(brew --prefix)"
DB_PASS="12345678"

# 等待某命令成功（最多 ~30s）
wait_ok() { local i=0; until "$@" >/dev/null 2>&1; do i=$((i+1)); [ $i -ge 15 ] && return 1; sleep 2; done; }

# ---------------- MySQL ----------------
if has mysql; then
  log "启动 MySQL..."
  brew services start mysql >/dev/null 2>&1 || true
  if wait_ok mysqladmin -u root ping; then
    if mysqladmin -u root password "$DB_PASS" 2>/dev/null; then
      ok "MySQL root 密码已设为 $DB_PASS"
    elif mysql -u root -p"$DB_PASS" -e "SELECT 1" >/dev/null 2>&1; then
      ok "MySQL root 密码已是 $DB_PASS（跳过）"
    else
      warn "MySQL root 密码疑似已被设置为其他值。手动重置：mysqladmin -u root -p password '$DB_PASS'"
    fi
  else
    warn "MySQL 未就绪，手动：brew services start mysql && mysqladmin -u root password '$DB_PASS'"
  fi
else
  warn "未安装 mysql，跳过"
fi

# ---------------- PostgreSQL ----------------
if brew list postgresql@16 >/dev/null 2>&1; then
  export PATH="$BREW_PREFIX/opt/postgresql@16/bin:$PATH"
  log "启动 PostgreSQL@16..."
  brew services start postgresql@16 >/dev/null 2>&1 || true
  if wait_ok pg_isready; then
    # 创建/更新 root 超级用户
    psql -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='root'" 2>/dev/null | grep -q 1 \
      || createuser -s root 2>/dev/null || true
    if psql -d postgres -c "ALTER ROLE root WITH LOGIN SUPERUSER PASSWORD '$DB_PASS';" >/dev/null 2>&1; then
      ok "PostgreSQL root 超级用户密码已设为 $DB_PASS（连接：psql -U root -d postgres）"
    else
      warn "PostgreSQL 设置 root 失败，手动：createuser -s root; psql -d postgres -c \"ALTER ROLE root PASSWORD '$DB_PASS';\""
    fi
  else
    warn "PostgreSQL 未就绪，手动：brew services start postgresql@16"
  fi
  # 让 psql 常驻 PATH
  append_block "$HOME/.zshrc" "postgresql16-path" \
    "export PATH=\"$BREW_PREFIX/opt/postgresql@16/bin:\$PATH\""
else
  warn "未安装 postgresql@16，跳过"
fi

# ---------------- MongoDB ----------------
if brew list mongodb-community >/dev/null 2>&1; then
  log "启动 MongoDB..."
  brew services start mongodb-community >/dev/null 2>&1 || true
  if has mongosh && wait_ok mongosh --quiet --eval "db.runCommand({ping:1})"; then
    mongosh admin --quiet --eval "
      if (!db.getUser('root')) {
        db.createUser({user:'root', pwd:'$DB_PASS', roles:[{role:'root', db:'admin'}]});
        print('created');
      } else { print('exists'); }" >/dev/null 2>&1 \
      && ok "MongoDB root 用户就绪（密码 $DB_PASS）" \
      || warn "MongoDB 创建用户失败，手动用 mongosh 执行 db.createUser(...)"
    warn "MongoDB 默认未开启鉴权；如需强制账号登录，编辑 $BREW_PREFIX/etc/mongod.conf 加 security.authorization: enabled 后重启服务。"
  else
    warn "MongoDB 未就绪，手动：brew services start mongodb-community"
  fi
else
  warn "未安装 mongodb-community，跳过"
fi

# 70 数据库：安装并把 root/超级用户密码设为 12345678
# 说明：Windows 上数据库安装差异较大，脚本尽力而为，失败会给手动指引而非中断整体。
. "$PSScriptRoot\lib.ps1"

Write-Step "配置数据库（密码统一 12345678）"

$pass = "12345678"
Update-SessionPath

# ---------------- PostgreSQL ----------------
Write-Log "安装 PostgreSQL 16（安装时直接设定超级用户密码）..."
try {
  winget install --exact --id PostgreSQL.PostgreSQL.16 `
    --silent --accept-package-agreements --accept-source-agreements `
    --override "--mode unattended --unattendedmodeui none --superpassword $pass --serverport 5432"
  Write-Ok "PostgreSQL 安装命令已执行（postgres 用户密码 = $pass）"
} catch { Write-Warn2 "PostgreSQL 安装出错：$($_.Exception.Message)" }

# 找 psql，并额外创建一个与 mac 一致的 root 超级用户
$psql = Get-ChildItem "C:\Program Files\PostgreSQL\*\bin\psql.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
if ($psql) {
  $env:PGPASSWORD = $pass
  Start-Sleep -Seconds 3
  try {
    # 先建（已存在则报错被忽略），再改密码/权限确保一致
    & $psql -U postgres -h localhost -p 5432 -c "CREATE ROLE root LOGIN SUPERUSER PASSWORD '$pass';" 2>$null
    & $psql -U postgres -h localhost -p 5432 -c "ALTER ROLE root WITH LOGIN SUPERUSER PASSWORD '$pass';" 2>$null
    Write-Ok "PostgreSQL 已创建 root 超级用户（密码 $pass）。连接：psql -U root -h localhost"
  } catch { Write-Warn2 "创建 root 角色失败，可手动：psql -U postgres 后执行 CREATE ROLE root LOGIN SUPERUSER PASSWORD '$pass';" }
  Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
} else {
  Write-Warn2 "未找到 psql，PostgreSQL 可能未装好。可用『开始菜单 -> PostgreSQL』确认。"
}

# ---------------- MongoDB ----------------
Write-Log "安装 MongoDB 服务..."
try {
  winget install --exact --id MongoDB.Server `
    --silent --accept-package-agreements --accept-source-agreements
  Write-Ok "MongoDB 安装命令已执行（会注册为 Windows 服务并自启）"
} catch { Write-Warn2 "MongoDB 安装出错：$($_.Exception.Message)" }

Update-SessionPath
Start-Sleep -Seconds 3
if (Test-Cmd mongosh) {
  try {
    $js = "if(!db.getUser('root')){db.createUser({user:'root',pwd:'$pass',roles:[{role:'root',db:'admin'}]});print('created')}else{print('exists')}"
    mongosh "mongodb://localhost:27017/admin" --quiet --eval $js | Out-Null
    Write-Ok "MongoDB root 用户就绪（密码 $pass）"
    Write-Warn2 "MongoDB 默认未开启鉴权；如需强制登录，编辑 mongod.cfg 加 security.authorization: enabled 后重启 MongoDB 服务。"
  } catch { Write-Warn2 "MongoDB 建用户失败，可稍后 mongosh 连上后手动 db.createUser(...)" }
} else {
  Write-Warn2 "未找到 mongosh（应由 20 步的 MongoDB.Shell 提供），重开终端后重试本步骤。"
}

# ---------------- MySQL ----------------
Write-Log "安装 MySQL..."
try {
  winget install --exact --id Oracle.MySQL `
    --silent --accept-package-agreements --accept-source-agreements
} catch { Write-Warn2 "MySQL 安装出错：$($_.Exception.Message)" }

Update-SessionPath
if (Test-Cmd mysqladmin) {
  try {
    mysqladmin -u root password $pass 2>$null
    Write-Ok "MySQL root 密码已设为 $pass"
  } catch { Write-Warn2 "MySQL 密码设置失败，手动：mysqladmin -u root -p password '$pass'" }
} else {
  Write-Warn2 "MySQL：winget 装的是『MySQL Installer』，需再用它安装服务端。"
  Write-Warn2 "  打开『开始菜单 -> MySQL Installer』，选 Server，安装向导里把 root 密码设为 $pass 即可。"
  Write-Warn2 "  或命令行：& 'C:\Program Files (x86)\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe' community install server;8.4 -silent"
}

# Windows 一键装机脚本

macOS 版的 Windows 对等实现。工具换成 Windows 生态，但覆盖内容一致。

## 快速开始

1. 按 `Win`，输入 **PowerShell** 或 **Windows Terminal**，右键 **以管理员身份运行**。
2. `cd` 到本目录（`windows\`），执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

跑完后**关闭并重开终端**让配置生效。

> 说明：`-ExecutionPolicy Bypass` 是为了让脚本能运行（Windows 默认禁止运行未签名脚本），只对这一次执行生效，不改系统全局策略。

## macOS ↔ Windows 对应关系

| 需求 | macOS 版用 | Windows 版用 |
|------|-----------|-------------|
| 包管理器 | Homebrew | **winget**（系统自带） |
| 脚本语言 | Bash | **PowerShell** |
| Shell 美化/插件 | oh-my-zsh + 插件 | **Oh My Posh + PSReadLine + posh-git + Terminal-Icons** |
| Node 版本管理 | nvm | **nvm-windows** |
| pnpm / yarn | corepack | corepack（相同） |
| VS Code 插件 | 同一份清单 | **复用同一份**（`..\config\vscode-extensions.txt`） |
| Xcode | 命令行工具 | 无（Windows 没有，已跳过） |
| 数据库 | brew | winget + 安装参数 |

## 步骤一览

| 步骤 | 内容 |
|------|------|
| `00-preflight` | 检查系统/PowerShell，提示管理员权限 |
| `10-winget` | 确认 winget 可用 |
| `20-packages` | 按 [`packages.winget`](packages.winget) 装：Git、PowerShell7、Windows Terminal、Oh My Posh、nvm、Python、VS Code、Chrome、Docker Desktop、mongosh |
| `30-powershell` | 配置 Oh My Posh + PSReadLine（历史自动建议/语法高亮）+ posh-git + 图标，写入 profile |
| `40-node` | nvm-windows 装 Node LTS（配国内镜像） |
| `50-node-packages` | corepack 启用 pnpm/yarn，npm 切国内源 |
| `60-vscode-extensions` | 复用根目录 `config/vscode-extensions.txt` 装插件 |
| `70-databases` | 装 PostgreSQL/MongoDB/MySQL，密码统一 `12345678` |
| `90-manual-notes` | 打印需手动完成的部分 |

## 常用操作

```powershell
.\install.ps1 40 50          # 只装 Node 和 pnpm/yarn
.\install.ps1 -Skip 70       # 跳过数据库
.\scripts\60-vscode-extensions.ps1   # 单独重跑某步
```

## 重要说明

- **可重复运行**：winget/插件/模块都会跳过已装项，改完清单重跑只补新增。
- **PATH 刷新**：装完 nvm 等工具，同一个终端里命令有时还认不到，需**重开终端**。若第 40 步提示找不到 `nvm`，重开管理员终端后单独跑 `.\scripts\40-node.ps1` 即可。
- **数据库**：
  - **PostgreSQL**：安装时直接把超级用户 `postgres` 密码设为 `12345678`，并额外建一个 `root` 超级用户（与 mac 一致）。
  - **MongoDB**：装成 Windows 服务，建 `root` 用户（密码 `12345678`）；默认不强制鉴权，需要的话按脚本提示改 `mongod.cfg`。
  - **MySQL**：winget 装的是 *MySQL Installer*（不是服务端本体），多数情况下需要再用它的向导装 Server 并把 root 密码设为 `12345678`——脚本会检测并给出提示。
- **Chrome 扩展**：无法命令行装，最后会打印 6 个安装链接。
- **字体**：想让提示符图标好看，装 Nerd Font：`oh-my-posh font install CascadiaCode`，再在 Windows Terminal 设置里选该字体。
- **网络**：nvm、npm 已配国内镜像；winget 本体走微软/厂商源，一般可直连。

## 从现有 Windows 机器导出清单（换机前）

```powershell
winget export -o packages.json                       # 导出已装 winget 软件
code --list-extensions > ..\config\vscode-extensions.mine.txt  # 导出 VS Code 插件
```

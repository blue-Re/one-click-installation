# 一键装机脚本（macOS + Windows）

换新电脑时，跑一条命令把开发环境装回来。清单化维护，下次再换机只改清单。

- **macOS** → 用本目录下的 `install.sh`（Homebrew + Bash），见下文。
- **Windows** → 用 [`windows/`](windows/) 目录下的 `install.ps1`（winget + PowerShell），见 [windows/README.md](windows/README.md)。

VS Code 插件清单 [`config/vscode-extensions.txt`](config/vscode-extensions.txt) **两个平台共用同一份**，只维护一处。

---

# macOS 版

换新 Mac 时，跑一条命令把开发环境装回来。

## 快速开始

```bash
cd one-click-installation
chmod +x install.sh scripts/*.sh
./install.sh
```

跑完后执行 `source ~/.zshrc` 或重开终端。

> 首次会先弹「Xcode 命令行工具」安装框，点安装等它装完；Homebrew 安装脚本也会交互式询问，跟着提示走即可。

## 它装了什么

| 步骤 | 内容 |
|------|------|
| `00-preflight` | 检查 macOS、安装 Xcode 命令行工具 |
| `10-homebrew` | 用 gitee 镜像装 Homebrew，并切换到国内下载源加速 |
| `20-brew-bundle` | 按 [`Brewfile`](Brewfile) 装：git/python/mysql/postgresql/mongodb、Chrome、VS Code、Docker Desktop |
| `30-oh-my-zsh` | oh-my-zsh + autosuggestions + syntax-highlighting，配好 `plugins` 数组 |
| `40-nvm-node` | nvm + Node LTS，写好环境变量 |
| `50-node-packages` | corepack 启用 pnpm / yarn，npm 切国内源 |
| `60-vscode-extensions` | 按 [`config/vscode-extensions.txt`](config/vscode-extensions.txt) 装 VS Code 插件 |
| `70-databases` | 启动三个数据库，root 密码统一设为 `12345678` |
| `90-manual-notes` | 打印需手动完成的部分（Chrome 扩展、完整版 Xcode） |

## 常用操作

只跑某几步（按前缀数字）：
```bash
./install.sh 40 50        # 只装 node 和 pnpm/yarn
```

跳过某步：
```bash
SKIP="70" ./install.sh    # 不碰数据库
```

单独重跑一步：
```bash
bash scripts/60-vscode-extensions.sh
```

## 怎么维护清单

- **加/减软件**：编辑 [`Brewfile`](Brewfile)，一行一个。`brew` 是 CLI，`cask` 是 GUI 应用。
- **加/减 VS Code 插件**：编辑 [`config/vscode-extensions.txt`](config/vscode-extensions.txt)，一行一个扩展 ID。
- **从现有机器导出清单**（换机前在老电脑上跑）：
  ```bash
  brew bundle dump --file=Brewfile.mine --describe --force   # 导出 brew 清单
  code --list-extensions > config/vscode-extensions.mine.txt  # 导出 VS Code 插件
  ```

## 说明与注意

- **脚本可重复运行**：已装的会跳过，改完清单重跑只补新增的。
- **数据库**：MySQL / PostgreSQL(root 超级用户) / MongoDB 的 root 密码都设为 `12345678`。MongoDB 默认不强制鉴权，如需强制登录见脚本末尾提示。数据库初始化受环境影响较大，若失败脚本会打印手动命令而不中断。
- **Chrome 扩展**：无法命令行批量装，跑到最后会打印 6 个扩展的安装链接，手动点一下。
- **完整版 Xcode**：体积大且要登录 Apple ID，默认不装（`Brewfile` 里已注释）。日常前端用命令行工具就够。
- **国内网络**：已尽量用 gitee / 中科大 / npmmirror 镜像。nvm、oh-my-zsh 个别源若仍慢，脚本里有 fallback 或可自行替换镜像地址。

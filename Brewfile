# =====================================================================
# Brewfile —— 你的软件清单（brew bundle 读取）
# 增删软件就改这里。运行 `brew bundle --file=Brewfile` 即可全部安装。
# 想从当前机器导出已装内容：`brew bundle dump --file=Brewfile.mine --describe`
# =====================================================================

# ---- taps（第三方仓库）----
tap "mongodb/brew"

# ---- 命令行工具（CLI）----
brew "git"
brew "wget"
brew "jq"
brew "mas"          # Mac App Store 命令行（装 Xcode 用）
brew "python"       # Python 3（含 pip）

# ---- 数据库 ----
brew "mysql"
brew "postgresql@16"
brew "mongodb-community"

# ---- GUI 桌面软件（cask）----
cask "google-chrome"
cask "visual-studio-code"
cask "docker"                    # Docker Desktop

# ---- Mac App Store 应用 ----
# Xcode 体积很大且需登录 Apple ID，默认注释。需要就取消注释并先 `mas signin`。
# mas "Xcode", id: 497799835

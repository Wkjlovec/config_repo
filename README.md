# macOS migration dotfiles

这个仓库用于把 Windows 开发习惯迁移到新的 macOS 实习机。它的目标不是完整复制 Windows，而是保留关键配置和习惯，让 Mac 可以快速恢复到可工作的开发环境。

## 仓库分层

- `Brewfile`: macOS 应用和 CLI 安装清单。
- `mac/`: 会被应用到 macOS 的配置。
- `windows-reference/`: Windows 现有配置的参考备份，不直接应用到 macOS。
- `scripts/mac-bootstrap.sh`: 新 Mac 初始化脚本。
- `scripts/collect-windows-config.ps1`: Windows 侧配置收集脚本。

## 不要提交的内容

不要把这些内容放进仓库：

- SSH 私钥、GitHub token、API key、Clash/VPN 订阅。
- 公司证书、`.mobileconfig`、数据库密码、真实 `.env`。
- 浏览器完整 profile、IDE cache、插件缓存、项目构建产物。

## Windows 侧迁移

先把这个目录作为 GitHub 私有仓库推上去。推荐仓库名：

- `dotfiles`: 偏传统，表示个人配置仓库。
- `mac-bootstrap`: 更直观，表示新 Mac 初始化入口。

如果已经安装并登录 GitHub CLI：

```powershell
gh auth login
gh repo create dotfiles --private --source . --remote origin --push
```

如果你想先手动建仓库，也可以：

```powershell
git remote add origin git@github.com:<your-name>/dotfiles.git
git branch -M main
git push -u origin main
```

在 Windows PowerShell 里执行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\collect-windows-config.ps1
```

脚本会把常见配置复制到 `windows-reference/`，包括：

- Scoop 安装列表。
- Neovim 配置。
- Nushell 配置。
- PowerShell profile。
- Windows Terminal 设置。
- AutoHotkey 脚本。
- Cursor settings/keybindings/extensions。

收集完成后检查一遍，不要把任何密钥或公司配置提交到 GitHub。

建议提交顺序：

```powershell
git status
git add Brewfile README.md .gitignore mac scripts windows-reference
git commit -m "Initialize macOS migration dotfiles"
git push
```

## Mac 侧初始化

在新 Mac 上先安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

然后 clone 这个私有仓库并运行：

```bash
./scripts/mac-bootstrap.sh
```

脚本会：

- 安装 Homebrew。
- 执行 `brew bundle` 安装软件。
- 备份已有配置。
- 把 `mac/` 下的配置链接到 macOS 对应位置。
- 尝试把默认 shell 切换为 fish。

## 手动步骤

这些步骤不适合自动化，需要手动完成：

- Chrome 登录账号并开启同步，重要扩展配置单独导入。
- JetBrains Toolbox 安装 IntelliJ IDEA，登录后开启 Backup and Sync。
- Cursor 登录账号，同步账号配置；本仓库里的配置只作为兜底。
- Karabiner-Elements、Hammerspoon、Rectangle、Snipaste 首次启动时授予系统权限。
- 输入法里关闭 Shift 切换中英文，并设置 `Ctrl + Space` 切换输入法。
- 在 Mac 上重新生成 SSH key，不迁移 Windows 私钥。

## 后续维护

新增软件后更新 `Brewfile`：

```bash
brew bundle dump --force --file Brewfile
```

改完配置后提交：

```bash
git status
git add .
git commit -m "Update mac migration config"
git push
```

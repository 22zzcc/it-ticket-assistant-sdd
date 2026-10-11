# 在 Cursor 使用 Claude Code + DeepSeek 编写 Spec

## 当前准备

- Cursor 官方插件：`anthropic.claude-code`，已安装 2.1.296。
- 独立 Claude Code CLI：原生安装器下载连接失败，已改用官方支持的 `npm install -g @anthropic-ai/claude-code` 安装。
- CLI 2.1.296 的 `--version` 和 `doctor` 已通过；doctor 未发现安装问题。
- 本项目的 `.claude/settings.local.json` 指向 DeepSeek Anthropic 兼容端点，默认使用 `deepseek-flash[1m]`；以 2026-10-11 查阅的官方文档为准。
- 密钥不在项目中。配置脚本用 Windows DPAPI 加密，保存在当前用户的 `%LOCALAPPDATA%/FDEClaudeCode/deepseek-key.dpapi`；Claude Code 通过 `apiKeyHelper` 读取。
- 这套配置仅应用于 `IT_SDD`，不更改其他项目的模型配置。CLI 安装与 PATH 属于用户级软件安装。

检查记录（2026-10-11）：JSON 与 PowerShell 语法检查通过；Windows DPAPI 加密/解密机制检查通过；DeepSeek 端点在未提供密钥时返回预期的 401。尚未输入真实密钥，因此真实模型连接与 Cursor 对话尚待验证。

运行环境修复：Cursor 终端可能把 PowerShell 7 模块搜索路径传给 Windows PowerShell 5.1，导致 `ConvertTo-SecureString` 自动加载失败。脚本现已明确导入当前运行版本自带的模块，且在请求真实密钥之前检查加密能力。可仅检查环境：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Set-DeepSeekKey.ps1 -CheckRuntime
```

## 第一次启动

1. 在 Cursor 打开本文件所在的 `IT_SDD` 文件夹。必须打开这个文件夹，才能加载其项目配置。
2. 到 https://platform.deepseek.com/api_keys 创建/准备 API 密钥。
3. 在 Cursor 的 PowerShell 终端运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Set-DeepSeekKey.ps1
```

粘贴密钥时输入会隐藏。脚本会执行一个很短的模型请求，验证通过后才加密保存。不要把密钥发到聊天里。
也可以按 Ctrl+Shift+P，选择“Tasks: Run Task”，再选择“配置 DeepSeek API 密钥”。

4. 按 Ctrl+Shift+P，搜索 `Claude Code`，打开新对话；首次出现工作区信任提示时核对这是自己创建的项目。
5. 把 `first-prompt.md` 的正文粘贴进 Claude Code 对话，与它回答问题、修订 `spec.md`。
6. 每次修订读一遍差异，核对建议有没有被误写成事实。尚未回答的问题继续保留 TBD。

若插件安装后没有出现，运行“Developer: Reload Window”。已有对话在密钥配置后也建议重新创建。

## 终端方式

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Start-Claude.ps1
```

启动后 `/status` 核对项目设置，`/model` 查看模型。当前配置默认使用 DeepSeek；Claude Code 是工具名称，并不表示后端调用 Claude 模型。

## 常见连接结果

- 401：密钥无效，重新配置。
- 402：检查 DeepSeek API 账户余额。
- 429：触发限流，稍后重试。
- 网络错误：检查能否访问 DeepSeek API；不要把完整请求头或密钥贴进错误报告。

使用的是 DeepSeek 云端模型 API。这个决定用于 coding agent；你的工单助手将来是否使用本地模型仍待规格讨论。

## 官方依据

- DeepSeek 接入 Claude Code：https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code/
- DeepSeek Anthropic 兼容 API（支持 X-Api-Key）：https://api-docs.deepseek.com/guides/anthropic_api/
- Claude Code Windows 安装：https://code.claude.com/docs/en/setup
- Cursor / VS Code 官方插件：https://code.claude.com/docs/en/vs-code
- apiKeyHelper 设置：https://code.claude.com/docs/en/settings-reference#apikeyhelper

安装、JSON 校验、凭证加密机制检查与真实模型连接验证是不同检查。真实连接需要你在本地输入有效密钥，不能以“配置文件已写好”当作“模型已连接成功”。

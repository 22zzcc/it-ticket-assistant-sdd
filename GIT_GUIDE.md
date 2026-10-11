# Spec 项目的 Git 操作入门

Git 保存本地修改历史；GitHub 保存你上传的仓库。保存文件、提交版本和上传是三个步骤。

```text
修改并保存文件 → git add（选择本次修改）→ git commit（本地版本）→ git push（上传 GitHub）
```

## 当前项目状态

已初始化 `main` 分支，尚未创建首次提交、绑定远程地址或上传。
仓库范围仅为 `IT_SDD`。父目录里的简历、投递表和研究资料不在这个仓库中。

忽略规则已排除 `.claude/settings.local.json`、`.env`、`*.dpapi` 和本机安装检查记录。实际 DeepSeek 密钥保存在项目外。首次上传的是规格、项目规则、说明和无密钥的工具脚本。

## 一、首次本地提交

在 Cursor 的 PowerShell 终端逐行运行。两条身份命令中的内容需要先替换，不要原样使用占位文字。

```powershell
cd C:\Users\zzc\Desktop\FDE\IT_SDD
git config user.name "你的提交署名"
git config user.email "你的GitHub提交邮箱"
git status
git add .
git diff --cached --stat
git commit -m "docs: initialize ticket assistant spec"
git log --oneline -5
```

这两条 `git config` 只配置当前仓库。署名可以是你的姓名或用户名；邮箱建议使用 GitHub Settings → Emails 显示的提交邮箱或 noreply 邮箱。

本项目已经执行过 `git init -b main`，不必重复。新建其他项目时，在那个项目目录先执行这条命令。

## 二、创建 GitHub 仓库

打开 https://github.com/new ，选择自己的账户，填写仓库名（例如 `it-ticket-assistant-sdd`），选择可见性。练习阶段可以选 Private，整理成求职作品后再决定是否公开。

新仓库不要勾选初始化 README、`.gitignore` 或 license，因为本地已有文件及首次提交。
创建后复制页面上的 HTTPS 仓库地址。地址里不要包含令牌。

## 三、首次上传

把地址替换成你刚创建的仓库地址，然后逐行运行：

```powershell
git remote add origin https://github.com/你的用户名/你的仓库名.git
git remote -v
git push -u origin main
```

电脑已配置 Git Credential Manager。首次上传如果弹出浏览器登录，按提示登录你的 GitHub 账户。Git 提交邮箱和 GitHub 登录是两件不同的事。

上传后刷新 GitHub 仓库页，确认有 `spec.md` 和首次提交。

## 四、以后每轮 SDD 修改

让 coding agent 修改 Spec 后，先保存并看差异，再记录这轮修改：

```powershell
git status
git diff
git add spec.md brief.md
git diff --cached
git commit -m "docs: clarify ticket categories and review boundary"
git push
```

`git add` 选择本轮实际修改的文件；如果还修改了其他文件，按需添加。`git diff` 显示尚未暂存的修改，`git diff --cached` 显示即将提交的修改。差异页面里可按 `q` 退出。

每确认一组完整需求或验收条件，做一次有意义的提交。提交说明写清楚变化，例如“clarify reviewer role”“define missing-information behavior”“add acceptance cases”。

## 五、开始练习分支

完成首次提交后，可以在独立分支与 agent 完善规格：

```powershell
git switch -c spec/clarify-v1
```

在该分支完成修改并提交后，可以上传它：

```powershell
git push -u origin spec/clarify-v1
```

规格确认后，在本地合并回主分支：

```powershell
git switch main
git merge spec/clarify-v1
git push
```

第一次练习可以只使用 `main`；理解提交与上传后再练分支。

## 六、常用查看与取消暂存

```powershell
git status
git log --oneline -10
git show HEAD --stat
git restore --staged spec.md
```

最后一条在已有首次提交后使用：取消对 `spec.md` 的暂存，文件修改仍然保留。

如果多个设备都会修改同一仓库，工作区干净时先 `git pull --ff-only` 再继续；遇到冲突先看报错和差异，不要用强制推送覆盖远程历史。

## 给 coding agent 的指令示例

```text
先读取 spec.md 和 brief.md，提出这轮需要澄清的问题。
根据我的回答更新规格。结束后列出改动，并解释 git diff。
本轮的 git commit 和 git push 由我在终端练习执行。
```

## 官方资料

- Git 入门：https://git-scm.com/docs/gittutorial
- 上传本地项目：https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github
- GitHub 提交邮箱：https://github.com/settings/emails

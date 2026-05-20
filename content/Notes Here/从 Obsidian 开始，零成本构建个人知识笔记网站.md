---
title: 从 Obsidian 开始，零成本构建个人知识笔记网站
created: 2026-05-20
description: 用 Obsidian + Quartz + GitHub + Cloudflare Pages，将本地 Markdown 笔记发布为公开网站，实现零成本自动化部署。
tags:
  - obsidian
  - quartz
  - guide
  - web
  - knowledge-management
related:
  - "[[Quartz 配置指南]]"
---

在信息过载时代，你的笔记、知识和经验，如果只是躺在硬盘里，它们的价值就远远没有被释放。

将个人笔记发布为一个可公开访问的"数字花园"，不仅能让你的知识惠及更多人，更能帮你构建长期可复利的个人品牌与内容资产。

这篇教程将带你从零走完"本地笔记→公开网站"的全部流程——即使你没有任何建站经验，也能很快地完成部署。

**总体思路：** 用 Obsidian 在本地以 Markdown 格式写作；用 Quartz 把这些 Markdown 文件转换成静态网站；通过 GitHub 管理版本，并对接 Cloudflare Pages 实现自动化部署。**你只需在 Obsidian 里写好文章、运行一行脚本，网站就会自动更新上线**。
![[assets/Pasted-image-20260520204941.png]]

> [!warning] 提醒
> 本教程中所有涉及本地路径的地方（如 `C:\Users\<用户名>\...`）请替换为你自己电脑实际用户名和路径，GitHub 用户名、邮箱等个人信息也请改为你自己的。

---

## 一、为什么用 Obsidian ？

Obsidian 的优势在于：它本质上就是一个 Markdown 文件编辑器。

你的笔记不是被锁在某个平台里，而是保存在本地。这对 Quartz 非常友好，因为 Quartz 需要的正是 Markdown 文件。

Obsidian 负责：

- 写文章
- 管理笔记
- 建立双链
- 插入图片
- 管理标签
- 组织知识库
- 本地预览 Markdown
- 维护长期内容资产

推荐建立一个单独的公开目录`Public/`，建议 `Public/` 公开区这样设计：
```
Obsidian Vault/
└── Public/
     ├── index.md    # 定义网站首页
     ├── Notes/      # 存放公开笔记
     └── assets/     # 存放图片、图表附件
```

只有 `Public/` 里的内容会被同步到 Quartz。

**首页 `index.md` 示例**

```markdown
# About me

大家好，我是老曹。业余时间喜欢折腾 AI 和知识管理。 
这里分享我关于 AI workflows / 效率工具 / 价值资讯 的公开笔记。

- [[Notes]]
```

Quartz 通常需要 `index.md` 作为首页。

如果没有 `index.md`，下一步访问本地站点或线上站点时会出现 404。

---

## 二、安装并初始化 Quartz

### 1. 安装前提

你需要先安装：

- Node.js
- Git
- 一个代码编辑器，例如 VS Code

### 2. 下载 Quartz

```bash
cd C:\Users\<用户名>
git clone https://github.com/jackyzha0/quartz.git
cd quartz
npm install
```

### 3. 初始化 Quartz

```bash
npx quartz create
```

初始化时会问你：

```
Choose how to initialize the content in C:\Users\<用户名>\quartz\content
```

推荐选择：

```
Copy an existing folder
```

将 Obsidian 的 `Public/` **文件夹内的所有内容**，复制进 Quartz 的 `content/`。

---

## 三、同步 Public/ 到 Quartz/content

Quartz 读取的是：

```
C:\Users\<用户名>\quartz\content
```

而你的 Obsidian 公开笔记可能在：

```
C:\Users\<用户名>\Documents\ObsidianVault\Public
```

所以需要把：

```
Obsidian/Public/
```

同步到：

```
Quartz/content/
```

### Windows 推荐用 PowerShell 脚本

在 Quartz 项目根目录创建 `publish.ps1` 脚本

内容如下（**前两行改成自己的真实路径**）：

```powershell
$ObsidianPublic = "C:\Users\<用户名>\Documents\ObsidianVault\Public"
$QuartzDir = "C:\Users\<用户名>\quartz"
$QuartzContent = "$QuartzDir\content"

Write-Host "Syncing Public to Quartz content..."

robocopy $ObsidianPublic $QuartzContent /MIR /XD ".obsidian" ".trash" /XF ".DS_Store" "Thumbs.db"

Set-Location $QuartzDir

Write-Host "Building Quartz locally..."
npx quartz build

Write-Host "Committing changes..."
git add .
git commit -m "sync public notes"

Write-Host "Pushing to GitHub..."
git push

Write-Host "Done. Cloudflare Pages will deploy automatically."
```

**你只需在 Obsidian 里写好文章、运行这个脚本，网站就会自动更新上线。**

---

## 四、本地预览 Quartz 网站

进入 Quartz 目录：

```bash
cd C:\Users\<用户名>\quartz
```

运行：

```bash
npx quartz build --serve
```

然后打开浏览器：

```
http://localhost:8080
```

这一步的作用主要是：在发布到 GitHub / Cloudflare 之前，先在自己电脑上检查网站能不能正常生成、首页是否 404、图片和链接是否正常。

---

## 五、配置 Quartz

Quartz 的配置文件通常是：

```
C:\Users\<用户名>\quartz\quartz.config.ts
```

打开 `quartz.config.ts`，找到：

```tsx
pageTitle: "Quartz 4",
```

改成：

```tsx
pageTitle: "任何你想要的名字",
```

如果主要是中文内容，找到：

```tsx
locale: "en-US",
```

改成：

```tsx
locale: "zh-CN",
```

---

## 六、把 Quartz 项目推送到 GitHub

进入 Quartz 目录：

```bash
cd C:\Users\<用户名>\quartz
```

初始化 Git：

```bash
git init
git add .
git commit -m "initial quartz site"
```

如果提示没有配置用户名和邮箱：

```bash
git config --global user.name "<你的GitHub用户名>"
git config --global user.email "<你的邮箱>"
```

然后重新提交：

```bash
git add .
git commit -m "initial quartz site"
```

在 GitHub 创建一个新仓库，例如：

```
quartz
```

然后绑定远程仓库：

```bash
git remote add origin https://github.com/你的用户名/quartz.git
git branch -M main
git push -u origin main
```

之后每次更新只需要：

```bash
git add .
git commit -m "update notes"
git push
```

---

## 七、用 Cloudflare Pages 发布

Cloudflare Pages 的作用是：

```
从 GitHub 拉取 Quartz 项目
→ 执行 npx quartz build
→ 生成 public/
→ 发布 public/ 为网站
```

### 1. 打开 Cloudflare

进入：

```
https://dash.cloudflare.com/
```

路径：

```
Workers & Pages
→ Create
→ Pages
→ Connect to Git
```

连接 GitHub 后，选择你的 Quartz 仓库。

### 2. 填写构建配置

推荐配置：

```
Project name: evan-quartz
Production branch: main
Framework preset: None
Build command: npx quartz build
Build output directory: public
Root directory: 留空
```

### 3. 点击部署

点击：

```
Save and Deploy
```

部署成功后会得到一个地址，例如：

```
https://evan-quartz.caojiantaocn.workers.dev/
```

**保存这个链接，它就是你的个人知识笔记公开网站了。**

---

### 4. 修改 Quartz baseUrl

得到域名地址后，记得在 [[#五、配置 Quartz]] 中把 `quartz.config.ts` 的 `baseUrl` 改成：

```tsx
baseUrl: "evan-quartz.caojiantaocn.workers.dev",
```

### 5. 重新部署一次

```bash
git add .
git commit -m "update baseUrl"
git push
```

> [!tip] 恭喜
> 到这一步，你拥有了属于你的知识笔记网站。

![[assets/Pasted-image-20260520205115.png]]
## 八、日常发布流程

最终，你每天只需要这样做：

### 1. 在 Obsidian 写文章

把准备公开的文章放入 `Public/`。

### 2. 运行发布脚本（powershell）

```powershell
cd C:\Users\<用户名>\quartz
.\publish.ps1
```

脚本会自动：

```
同步 Public/
→ 构建 Quartz
→ git add
→ git commit
→ git push
→ Cloudflare 自动部署
```

### 3. 等待 Cloudflare 部署完成

几分钟后访问：

```
https://evan-quartz.caojiantaocn.workers.dev/
```

---

## 这套系统的优势：

- 写作在本地
- 内容归你所有
- 网站可公开访问
- 发布流程可自动化
- 长期积累能形成个人内容资产
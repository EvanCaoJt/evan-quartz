---
title: GPT 用不了？来看 Codex 如何使用 DeepSeek 模型
tags:
  - codex
  - deepseek
  - guide
  - cli
  - AI
created: 2026-05-18
description: 通过 Moon Bridge 协议转换，让 Codex 使用 DeepSeek 模型的完整配置指南。
---

Codex 主要通过 OpenAI Responses API 与模型通信，而 DeepSeek 不兼容这种协议，所以 Codex 直接调用 DeepSeek API 是行不通的。

**我的做法是使用 Moon Bridge 做协议转换。**

> **技巧**：操作过程中遇到的任何报错，都可以问大模型，基本上都能提供解决思路。

> **提示**：以下步骤以 Windows 系统为例，macOS 操作和方法一致。

---

## 一、你需要准备什么？

| # | 所需内容 | 说明 |
|---|---------|------|
| 1 | **Codex App / Codex CLI** | OpenAI 的终端 AI 编程工具 |
| 2 | **Go 环境** | Moon Bridge 是 Go 项目，需要 Go 运行时 |
| 3 | **Moon Bridge** | 协议转换桥梁，让 Codex 能调用 DeepSeek |
| 4 | **DeepSeek API Key** | 在 DeepSeek 开放平台创建（需先充值） |

---

## 二、操作步骤

### 1. 安装 Codex CLI / Codex App

**安装 CLI：**

```bash
npm install -g @openai/codex
```

**验证安装：**

```bash
codex --version
```

输出版本号即代表安装成功。

**安装桌面 App**：[下载 Codex App](https://openai.com/zh-Hans-CN/codex/)，按步骤安装即可。

---

### 2. 安装 Go

Go 是一种让程序员更快、更稳地写后端服务的软件开发语言。Moon Bridge 是 Go 项目，因此 Windows 上需要安装 Go。

- 前往 [Go 官方下载页](https://go.dev/dl/)，下载对应系统的最新安装包
- 安装完成后，终端验证：

```bash
go version
```

---

### 3. 获取 DeepSeek API Key

进入 [DeepSeek 开放平台](https://platform.deepseek.com/)，创建 API Key（需先充值）。

---

### 4. 安装 Moon Bridge

```bash
git clone https://github.com/ZhiYi-R/moon-bridge.git
```

> **如果遇到网络问题**，导致 GitHub 连接失败：
>
> - 从这里下载已打包好的文件：[蓝奏云下载](https://wwant.lanzouu.com/iIzJ83psdate)
> - 在 `C:\Users\<用户名>\`（终端默认目录）下新建 `moon-bridge` 文件夹，将下载的文件解压进去
> - **解压时注意别嵌套多层文件夹**，确保进入 `moon-bridge` 就能看到 `go.mod`

---

### 5. 创建 Moon Bridge 配置文件

在终端依次执行：

```bash
cd moon-bridge
```

```bash
notepad config.yml
```

将以下配置粘贴到 `config.yml` 中，**将 `api_key` 改成你的真实 DeepSeek API Key**，保存退出：

```yaml
mode: "Transform"

log:
  level: "info"
  format: "text"

server:
  addr: "127.0.0.1:38440"

defaults:
  model: "moonbridge"
  max_tokens: 65536

providers:
  deepseek:
    base_url: "https://api.deepseek.com/anthropic"
    api_key: "sk-your-deepseek-api-key"
    version: "2023-06-01"
    user_agent: "moonbridge/1.0"
    offers:
      - model: deepseek-v4-pro

models:
  deepseek-v4-pro:
    context_window: 1000000
    max_output_tokens: 384000
    display_name: "DeepSeek V4 Pro"
    description: "DeepSeek V4 Pro for Codex"
    default_reasoning_level: "high"
    supported_reasoning_levels:
      - effort: "high"
        description: "High reasoning effort"
      - effort: "xhigh"
        description: "Extra high reasoning effort"
    supports_reasoning_summaries: true
    default_reasoning_summary: "auto"
    extensions:
      deepseek_v4:
        enabled: true

routes:
  moonbridge:
    model: deepseek-v4-pro
    provider: deepseek
```

---

### 6. 启动 Moon Bridge

```bash
cd moon-bridge
```

```bash
go run ./cmd/moonbridge --config config.yml
```

首次启动会下载外部依赖。如遇到网络问题，先设置国内代理：

```bash
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GOSUMDB=sum.golang.google.cn
```

再执行启动命令：

```bash
go run ./cmd/moonbridge --config config.yml
```

启动成功后，它会监听 `127.0.0.1:38440`。

> ⚠️ **这个 CMD 窗口不要关**，它相当于一个本地中转站。

---

### 7. 生成 Codex App 配置

这是关键步骤。**重新打开一个 CMD 窗口**，依次执行：

```bash
cd moon-bridge
```

```bash
set CODEX_HOME_DIR=%USERPROFILE%\.codex
mkdir "%CODEX_HOME_DIR%"
```

```bash
for /f "delims=" %i in ('go run ./cmd/moonbridge --config config.yml --print-codex-model') do set MODEL=%i
```

```bash
go run ./cmd/moonbridge --config config.yml --print-codex-config "%MODEL%" --codex-base-url "http://127.0.0.1:38440/v1" --codex-home "%CODEX_HOME_DIR%" > "%CODEX_HOME_DIR%\config.toml"
```

**检查是否生成成功：**

进入 `C:\Users\<用户名>\.codex`，你应该能看到：

- `config.toml`
- `models_catalog.json`

如果没有看到 `models_catalog.json`，先确认 `config.toml` 是否已生成，再重新运行生成命令。

---

### 8. 启动 Codex App

> ⚠️ 确保 Moon Bridge 已经在另一个 CMD 窗口中运行。

新开一个 CMD 窗口，执行：

```bash
set CODEX_HOME=%USERPROFILE%\.codex
codex app
```

登录页面操作：

1. 选择 **「使用其他方式登录」**
2. 选择 **API Key** 方式
3. 如果要求输入 Key，先填：`sk-local`
4. 进入 App 后，确认模型可以选择 **Moon Bridge**

---

## 三、写在最后

到这一步，你应该就可以通过 DeepSeek 模型顺畅使用 Codex 了，快去试试吧！



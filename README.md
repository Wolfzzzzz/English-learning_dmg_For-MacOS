<div align="center">

# IELTS 雅思绿宝书默写练习

**IELTS Green Book Dictation Practice — macOS Native App**

> 软件版权 © [Wolfzzzzz](https://github.com/Wolfzzzzz) · 单词版权归属新东方教育科技集团与译林出版社

A native macOS application for daily English word dictation practice based on the **IELTS Green Book (《雅思词汇绿宝书》)**.

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?logo=swift&logoColor=white)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-13+-0078D6?logo=apple&logoColor=white)](https://developer.apple.com/macos)
[![Platform](https://img.shields.io/badge/Platform-arm64%20%7C%20x86__64-lightgrey)](https://developer.apple.com/macos)
[![Tests](https://img.shields.io/badge/Tests-38%2F38-22C55E)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

</div>

---

## 📖 简介 / About

一款 macOS 原生应用，基于**雅思词汇绿宝书**自动推送每日默写练习。按 `List` 为单位，每 2 个 List 为一课，自动剔除初中课标基础词，帮你高效巩固高阶雅思词汇。

- 🇨🇳 **中译英默写**：展示中文释义，训练主动回忆能力
- ⏰ **自动课程推进**：基于 UTC+8 时区，每日自动跳至下 2 个 List
- 🎯 **智能筛选**：从当日课中选取 50 个不在初中课标范围的单词
- ✅ **即时批改**：点击「校对」即可生成正确率与错词报告
- 📊 **历史追踪**：历史报告、错词本、学习进度可视化
- 🗣️ **发音朗读**：支持英文单词 TTS 朗读（P2 功能）
- 🌙 **深色主题**：全局深色界面舒适护眼

---

## 🖥️ 截图 / Screenshots

```
┌───────────────────────────────────────────────┐
│  📖 第 2 课 (List 19–20)    2026-07-14 UTC+8   │
│  今日单词：50 个     未开始                      │
├───────────────────────────────────────────────┤
│  1.  v. 保护；维持；保存，保藏：腌渍            │
│      _______________                            │
│  2.  n. 文学（作品）：文献                      │
│      _______________                            │
│  3.  v. 遭受，忍受；忍耐；容许                  │
│      _______________                            │
│          ... 共 50 题 ...                       │
├───────────────────────────────────────────────┤
│         [   校  对   ]                         │
│  正确率：82%（41/50）                           │
│  1. 保护 → 你填：preverse   正确：preserve      │
└───────────────────────────────────────────────┘
```

---

## ⚙️ 系统要求 / Requirements

- macOS **13.0** (Ventura) 或更高版本
- Swift **5.9+** (Swift **6.0** 推荐)
- Apple Silicon **(arm64)** 或 Intel **(x86_64)**

---

## 🚀 安装与运行 / Installation & Usage

### 方法 1：下载 DMG 安装包

从本仓库直接下载 [`IELTSDictationApp.dmg`](IELTSDictationApp.dmg)，双击安装。

1. 双击 `IELTSDictationApp.dmg` 挂载磁盘映像
2. 将 `IELTSDictationApp.app` 拖入「应用程序」文件夹
3. 首次打开如被 Gatekeeper 拦截：**右键 → 打开 → 仍要打开**

### 方法 2：网页版（无需安装）

在浏览器中打开 [`web/index.html`](web/index.html)（需通过本地服务器访问）：

```bash
cd English-learning_dmg_For-MacOS/web
python3 -m http.server 8080
# 浏览器访问 http://localhost:8080
```

功能与 macOS 原生版完全一致，数据存储在浏览器 localStorage。

### 方法 3：从源码构建

```bash
git clone https://github.com/Wolfzzzzz/English-learning_dmg_For-MacOS.git
cd English-learning_dmg_For-MacOS

# 构建（调试模式）
swift build

# 运行
open .build/debug/IELTSDictationApp

# 或 Release 模式
swift build -c release
open .build/release/IELTSDictationApp
```

### 方法 3：用 Xcode 打开

```bash
open Package.swift
# 选择 scheme: IELTSDictationApp → Run
```

### 运行测试

```bash
swift test
```

---

## 📂 项目结构 / Project Structure

```
English-learning_dmg_For-MacOS/
├── Package.swift                         # SwiftPM 包描述
├── IELTSDictationApp.dmg                 # macOS 安装包（即下即用）
├── Sources/
│   ├── IELTSDictationCore/               # 核心逻辑（纯 Foundation，可 swift test）
│   │   ├── Models/                       # 数据模型：Word, VocabList, Vocabulary
│   │   ├── Scheduling/                   # 课程推进：CourseSchedule, DateProvider
│   │   ├── Selection/                    # 单词筛选：WordSelector
│   │   ├── Session/                      # 默写会话与批改：DictationSession, Grading
│   │   └── Persistence/                  # 本地存储：ReportStore, FileReportStore
│   └── IELTSDictationApp/                # SwiftUI macOS 应用
│       ├── ViewModels/                   # DictationViewModel
│       ├── Views/                        # 13 个 SwiftUI 视图
│       └── Audio/                        # AVFoundation 发音
├── Tests/IELTSDictationCoreTests/        # 38 个单元测试
├── tools/
│   ├── extract_vocab.py                  # OCR 文本 → 词库 JSON 解析器
│   └── ocr.swift                         # Vision 框架 OCR 工具
├── Resources/
│   ├── junior_high.json                  # 初中排除词表
│   └── override_keep.json                # 偏难/易错保留词
└── docs/
    ├── PRD.md                            # 产品需求文档
    ├── ARCHITECTURE.md                   # 架构设计文档
    ├── class-diagram.mermaid             # 类图
    └── sequence-diagram.mermaid          # 时序图
```

---

## 🧠 架构说明 / Architecture

### 分层设计

```
IELTSDictationApp (SwiftUI) ──依赖──► IELTSDictationCore (Foundation only)
                                            │
                                    Resources/vocab.json (2651 词)
                                    Resources/junior_high.json (3030 词)
```

- **Core** 层纯 Foundation，可在任意平台 `swift test`
- **App** 层依赖 Core，不反向
- 资源随包打包，运行时零网络依赖

### 课程推进公式

| 变量 | 值 |
|------|-----|
| 锚定日 | 首次运行日期（可恢复出厂重置） |
| 起始 List | `List 17` |
| 每课 | 2 个连续 List |
| 第 d 天 | `List(17+2d)` + `List(17+2d+1)` |
| 每日目标 | 50 词（不足取全部） |
| 溢出策略 | `.stop`（学完显示"所有课程已完成"） |

### 单词筛选流程

```
当日 2 个 list 的词库
  → 排除 junior_high 中的词
  → 加回 override_keep 中的偏难/易错词
  → 随机选 50 个
  → 不足 50 取全部
```

### 答案比对规则

- 首尾空格忽略 (`trimWhitespace = true`)
- 大小写不敏感 (`caseInsensitive = true`)
- 支持多可接受答案 (`acceptableAnswers`，覆盖英美变体)
- 多词答案中间空格归一化

---

## 🧪 测试 / Tests

```bash
# 全部 38 个单元测试
swift test
```

| 测试模块 | 测试数量 | 覆盖内容 |
|---------|---------|----------|
| `CourseScheduleTests` | 9 | UTC+8 调度、锚定日、课次递增、溢出策略 |
| `WordSelectorTests` | 6 | 排除、overrideKeep、每日上限、shuffle |
| `GradingTests` | 11 | 精确匹配、大小写、空格、多答案、完整批改 |
| `DictationSessionTests` | 6 | 初始化、提交、覆盖、isComplete |
| `FileReportStoreTests` | 6 | 存/读、替换、错词聚合、报告转换 |

---

## 📚 数据来源 / Data Source

词库数据来自《雅思词汇绿宝书(1).pdf》（518 页纯图像扫描件）。通过以下流水线生成：

1. **OCR** — macOS Vision 框架 (`VNRecognizeTextRequest`)，中文优先 (`zh-Hans`, `en`)
2. **解析** — `tools/extract_vocab.py` 按 `Word List N` 章节标题分割，提取英文词 + 中文释义 + 词性
3. **排除词表** — `Resources/junior_high.json`（可替换为译林版等）
4. **保留词表** — `Resources/override_keep.json`（72 个常见偏难/易错单词，不受排除影响）

**结果**：47 个 List、2651 个单词，均已清理无例句混入。

---

## 🔧 配置自定义 / Configuration

### 更换初中排除词表

直接替换 `Sources/IELTSDictationCore/Resources/junior_high.json` 的 `words` 数组，无需改代码。

### 调整每日词量

修改 `Sources/IELTSDictationCore/Scheduling/CourseSchedule.swift` 中的 `dailyTarget`：
```swift
public static let dailyTarget: Int = 50
```

### 重新运行 OCR 抽取

```bash
python3 tools/extract_vocab.py \
  --input tools/ocr_output.txt \
  --output Sources/IELTSDictationCore/Resources/vocab.json
```

---

## 🤝 贡献 / Contributing

欢迎 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交改动 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

---

## 👤 作者

- **Wolfzzzzz** — 软件作者
- 联系邮箱：zhang429500@icloud.com

---

## ⚖️ 版权声明 / Copyright

- **单词版权** © 新东方教育科技集团（《雅思词汇绿宝书》）& 译林出版社（初中英语词汇表）  
  本应用所使用的词库数据来自公开的纸质出版物，仅供个人学习使用。如需商业使用，请联系版权方获取授权。
- **软件版权** © Wolfzzzzz  
  本应用的源代码基于 MIT License 开源，详见 [LICENSE](LICENSE) 文件。但本许可**不涵盖**词库数据本身，词库数据的版权归原始权利人所有。

---

<div align="center">
  <sub>Built with ❤️ by Wolfzzzzz</sub>
  <br>
  <sub>Contact: zhang429500@icloud.com</sub>
</div>

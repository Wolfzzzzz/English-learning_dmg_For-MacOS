# IELTS 绿宝书默写练习应用 · 交付总结

> 软件开发团队（主理人：齐活林 Qi）
> 交付日期：2026-07-13
> 团队：software-ielts-dictation

---

## TL;DR

基于《雅思词汇绿宝书》的 **Swift macOS 原生英语单词默写练习应用**。每日按 UTC+8 时区自动推进一课（2 个 list），从 2651 个词库中排除初中基础词后抽查 50 个。三段式 SwiftUI 界面：顶部课次/日期信息 → 中部中文释义+下划线输入 → 底部「校对」批改报告。**38 个单元测试全部通过**，零第三方依赖。

---

## 交付概览

| 指标 | 值 |
|------|-----|
| 测试通过率 | **38/38 (100%)** |
| 词库规模 | **2651 词 / 47 个 list** |
| 初中排除词表 | 3030 词（可替换） |
| 第三方依赖 | **零** |
| 平台 | macOS 13+, Swift 5.9+ |

---

## 文件清单

### Swift 源文件（16 个 Core + 11 个 App + 5 个测试）

| 模块 | 文件 | 说明 |
|------|------|------|
| **Core 模型** | `Models/Word.swift`, `VocabList.swift`, `Vocabulary.swift`, `JuniorHighWordSet.swift` | 词条数据模型与加载 |
| **Core 调度** | `Scheduling/DateProvider.swift`, `CourseSchedule.swift` | UTC+8 课程推进 |
| **Core 筛选** | `Selection/WordSelector.swift` | 排除初中词 + override 加回 |
| **Core 会话** | `Session/Lesson.swift`, `DictationSession.swift`, `Grading.swift`, `GradingReport.swift` | 默写会话与批改 |
| **Core 持久化** | `Persistence/ReportStore.swift`, `FileReportStore.swift`, `InMemoryReportStore.swift`, `DailyReport.swift` | 本地报告存储 |
| **App 入口** | `IELTSDictationApp.swift` | @main SwiftUI 入口 |
| **App VM** | `ViewModels/DictationViewModel.swift` | 核心视图模型 |
| **App Views** | `Views/ContentView.swift`, `HeaderView.swift`, `QuestionListView.swift`, `DictationQuestionView.swift`, `GradingReportView.swift` | 三段式默写界面 |
| **App P1** | `Views/HistoryView.swift`, `MistakeBookView.swift`, `ProgressView.swift` | 历史/错词本/进度 |
| **App P2** | `Audio/WordSpeaker.swift` | AVFoundation 发音 |
| **测试** | `Tests/IELTSDictationCoreTests/CourseScheduleTests.swift`, `WordSelectorTests.swift`, `GradingTests.swift`, `DictationSessionTests.swift`, `FileReportStoreTests.swift` | 38 个单测 |

### 资源文件

| 文件 | 说明 |
|------|------|
| `Resources/vocab.json` | OCR 词库（2651 词，47 list） |
| `Resources/junior_high.json` | 初中排除词表（3030 词，可替换） |
| `Resources/override_keep.json` | 偏难/易错保留词（72 词） |

### 工具与文档

| 文件 | 说明 |
|------|------|
| `tools/extract_vocab.py` | OCR 文本 → vocab.json 解析器 |
| `tools/ocr_output.txt` | Vision OCR 原文件（1.2MB，含中文） |
| `docs/PRD.md` | 产品需求文档 |
| `docs/ARCHITECTURE.md` | 架构设计文档 |
| `docs/class-diagram.mermaid` | 类图 |
| `docs/sequence-diagram.mermaid` | 时序图 |

---

## 关键设计决策

- **课程推进**：锚定日 + startListId=17，第 d 课 = list(17+2d) / list(17+2d+1)，Overflow.stop
- **时区**：硬编码 `Asia/Shanghai`，通过 `DateProvider` 协议可注入（单测用固定日期）
- **单词筛选**：排除 junior_high → 加回 override_keep → 随机抽 50 → 不足取全部
- **答案比对**：trim + 大小写不敏感 + 可接受答案数组（英美变体）
- **持久化**：`FileReportStore` → `~/Library/Application Support/<bundle-id>/reports.json`
- **深色主题**：`.preferredColorScheme(.dark)` 全局统一

---

## 使用说明

### 构建与运行

```bash
cd /Users/zzn/WorkBuddy/2026-07-13-22-35-34/ielts-dictation

# 构建
/usr/bin/swift build

# 运行（macOS 原生 App）
open .build/debug/IELTSDictationApp

# 或者用 Xcode 打开 Package.swift
open Package.swift
```

### 运行测试

```bash
cd /Users/zzn/WorkBuddy/2026-07-13-22-35-34/ielts-dictation
/usr/bin/swift test
```

### 更换词库数据

如需更换初中排除词表或全量词库，替换对应 JSON 后重新 build 即可（结构不变，无需改代码）：

- `Sources/IELTSDictationCore/Resources/junior_high.json`
- `Sources/IELTSDictationCore/Resources/vocab.json`

### 重新运行 OCR 抽取

```bash
cd /Users/zzn/WorkBuddy/2026-07-13-22-35-34/ielts-dictation
/Users/zzn/.workbuddy/binaries/python/envs/default/bin/python tools/extract_vocab.py \
  --input tools/ocr_output.txt \
  --output Sources/IELTSDictationCore/Resources/vocab.json
```

---

## 用户下一步建议

1. **首次运行**：确保 macOS 13+，允许文件读取权限（首次运行后自动创建报告文件）
2. **校对初中词表**：查看 `junior_high.json`，如需替换为译林版原表（zxxyy.cn 2272 词）直接覆盖 `words` 数组
3. **优化 OCR 词库**：`vocab.json` 中部分中文释义含 OCR 噪声（记忆法混入），可逐条清理或等待精确文本版词库后替换
4. **自定义每日词量**：修改 `WordSelector.swift` 中 `DictationConstants.dailyTarget`（默认 50），或改为用户可配置
5. **沉浸式功能**：计划中的 P2 功能可逐项完善（报告导出 PDF、错词加权、拼写模糊匹配等）

---

*本交付由软件开发团队（齐活林/许清楚/高见远/寇豆码/严过关）协作完成，遵循标准 SOP 流程。*

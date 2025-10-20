# FoundationModelsTranslator ![](https://img.shields.io/badge/A%20FRAD%20PRODUCT-green)

[![Twitter Follow](https://img.shields.io/twitter/follow/FradSer?style=social)](https://twitter.com/FradSer) [![Foundation Models](https://img.shields.io/badge/Foundation%20Models-blue.svg)](https://developer.apple.com/documentation/foundationmodels/) [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**[English](README.md) | 中文**

一款基于 Apple FoundationModels 框架构建的原生 macOS 英中翻译应用，采用现代化 SwiftUI 界面设计。

![FoundationModelsTranslator 截图](cover.png)

## 功能特性

- **实时流式翻译**：通过 FoundationModels 流式 API 观察翻译实时生成过程
- **自定义适配器集成**：针对网络搜索内容训练的专业英中翻译适配器
- **置信度评分**：AI 驱动的置信度评级，用于评估翻译质量
- **文化背景说明**：解释文化适应性和细微差别的上下文注释
- **原生 macOS 界面**：针对 macOS 优化的现代化 SwiftUI 液体玻璃设计
- **智能复制功能**：跨平台剪贴板集成的一键复制功能
- **简化体验**：专注于翻译功能，无历史记录管理复杂性

## 系统要求

- **macOS 26+** (Tahoe) - FoundationModels 框架的必需版本
- **Xcode 26.0.1+** - 集成 AI 功能的最新开发工具
- **Swift 6.2+** - 增强并发支持的高级 Swift 版本
- **FoundationModels framework** - Apple 的端侧 AI 框架
- **注意**：macOS 26 Tahoe 是支持 Intel 处理器的最终版本

## 架构设计

应用遵循清洁架构原则，具有清晰的关注点分离：

### 核心组件

- **翻译模型** (`Translation.swift`)
  - `TranslationRequest`: 输入数据结构
  - `TranslationResult`: 包含置信度和注释的输出

- **翻译管理器** (`TranslationManager.swift`)
  - 管理 FoundationModels 会话
  - 处理适配器加载和回退
  - 提供流式翻译支持
  - 错误处理和状态管理

- **UI 组件**
  - `ContentView`: 主翻译界面
  - `GlassDesign`: 自定义玻璃拟态设计系统
  - 实时进度指示
  - 跨平台剪贴板支持

### 自定义翻译适配器

应用包含专门训练的 LoRA 适配器 (`translation_en_zh_CN.fmadapter`)，使用 **[Apple Foundation Models 适配器训练工具包](https://developer.apple.com/apple-intelligence/foundation-models-adapter/)**专门训练用于英中翻译：

#### 训练方法论
- **Apple 官方工具包**：使用 Apple Foundation Models 适配器训练工具包进行端侧语言模型专业化训练
- **参数高效微调**：使用 LoRA（低秩适应）技术，冻结基础模型权重
- **端侧优化**：专为 Apple Silicon 设计，内存高效训练工作流

#### 模型架构
- **基础模型**：针对翻译任务优化的 DeepSeek-R1 Distilled
- **LoRA 等级**：32，用于高效微调（约 160MB 存储）
- **推测解码**：5 个草稿标记，增强推理速度
- **领域专业化**：针对网络搜索内容翻译场景优化
- **回退支持**：适配器失败时优雅降级到基础模型

#### 训练数据集（100K 样本）
适配器使用多数据集方法结合高质量翻译对进行训练：

**主要数据集**（39K 样本 - 100% 保留）：
- `FradSer/DeepSeek-R1-Distilled-Translate-en-zh_CN-39k-Alpaca-GPT4-without-Think`
- 高质量英中翻译对
- Alpaca-GPT4 生成的内容，针对准确性优化

**补充数据集**（61K 样本 - 智能采样）：
- `shareAI/ShareGPT-Chinese-English-90k` - 对话翻译数据
- `Nexdata/Chinese-English_Parallel_Corpus_Data` - 专业平行语料库

**高级训练流水线特性**：
- **多源集成**：下载并组合多个 HuggingFace 数据集
- **智能采样**：主要数据集完全保留，其他采样以达到 100K 总量
- **网络搜索优化**：针对网络搜索翻译场景优化的内容过滤
- **格式标准化**：跨所有源自动消息格式转换
- **质量评估**：BLEU 分数和详细质量评估指标
- **自动化训练**：一键训练流水线，优化超参数

#### 技术规格
- **训练要求**：Apple Silicon Mac（32GB RAM）或 Linux GPU 机器
- **适配器大小**：133MB（adapter_weights.bin）+ 元数据
- **模型签名**：9799725ff8e851184037110b422d891ad3b92ec1
- **许可证**：适配器权重和训练代码采用 MIT 许可证
- **部署建议**：生产环境建议独立资源托管

## 快速开始

1. **克隆仓库**
   ```bash
   git clone https://github.com/FradSer/FoundationModelsTranslator.git
   cd FoundationModelsTranslator
   ```

2. **在 Xcode 中打开**
   ```bash
   open FoundationModelsTranslator.xcodeproj
   ```

3. **构建和运行**
   - 选择目标设备
   - 按 `⌘R` 构建并运行

## 测试

项目包含基础测试结构，可扩展性强：

### 当前测试覆盖
- **单元测试** (`FoundationModelsTranslatorTests`)：基础测试框架设置
- **UI 测试** (`FoundationModelsTranslatorUITests`)：应用启动和基本 UI 验证
- **启动测试** (`FoundationModelsTranslatorUITestsLaunchTests`)：应用启动性能测试

### 运行测试
```bash
# 在 Xcode 中运行所有测试
⌘U

# 从命令行运行测试
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS'

# 运行特定测试目标
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS' -only-testing:FoundationModelsTranslatorTests
```

### 测试扩展机会
当前测试结构为全面测试提供基础，包括：
- 翻译模型验证
- 管理器状态测试
- 错误场景处理
- UI 交互流程
- 集成测试

## 项目结构

```
FoundationModelsTranslator/
├── FoundationModelsTranslator/
│   ├── FoundationModelsTranslatorApp.swift    # 应用入口点
│   ├── ContentView.swift                      # 主界面
│   ├── GlassDesign.swift                      # 玻璃拟态设计系统
│   ├── Translation.swift                     # 数据模型
│   ├── TranslationManager.swift              # 业务逻辑
│   ├── Assets.xcassets/                      # 应用资源
│   └── translation_en_zh_CN.fmadapter/      # 自定义适配器
├── FoundationModelsTranslatorTests/          # 单元测试
│   └── GlassDesignTests.swift               # 设计系统测试
├── FoundationModelsTranslatorUITests/        # UI 测试
└── README.md
```

## 使用方法

1. **输入英文文本**：在输入区域键入或粘贴英文文本
2. **翻译**：点击翻译按钮开始实时翻译
3. **查看结果**：查看带有置信度和文化注释的流式翻译
4. **复制结果**：使用复制按钮将翻译导出到剪贴板

## 技术实现

### FoundationModels 集成
- **结构化输出**：使用 `@Generable` 协议和 `@Guide` 注释确保一致的翻译结果
- **流式支持**：使用 `LanguageModelSession.streamResponse` 进行实时翻译
- **适配器管理**：自定义适配器加载，自动回退到基础模型
- **会话预热**：使用 `prewarm()` 功能进行性能优化

### 架构模式
- **@Observable**：现代 SwiftUI 状态管理，用于响应式 UI 更新
- **@MainActor**：线程安全的 UI 操作，使用 async/await 模式
- **错误处理**：全面的 `TranslationError` 枚举，包含本地化描述
- **清洁架构**：数据模型、业务逻辑和 UI 组件的分离

### 数据流
```swift
TranslationRequest → TranslationManager → FoundationModels → TranslationResult → UI Update
```

### 性能优化
- Async/await 模式用于非阻塞翻译操作
- 流式结果提供即时用户反馈
- 最小内存占用，高效运行
- 后台会话初始化以加快启动速度

### 平台集成
- **跨平台剪贴板**：自动检测 UIKit/AppKit 进行复制操作
- **原生 UI 组件**：具有平台特定样式的 SwiftUI
- **文件系统访问**：从应用包安全加载适配器文件

## 开发说明

### 适配器文件管理
翻译适配器权重文件 (`adapter_weights.bin`，133MB) 因 GitHub 100MB 文件大小限制而被排除在��库之外。要使用完整的适配器功能：

1. 单独获取适配器权重文件
2. 将其放置在 `FoundationModelsTranslator/translation_en_zh_CN.fmadapter/` 中
3. 应用将自动检测并使用适配器，或回退到基础模型

### 代码统计
- **Swift 代码总量**：728 行
- **核心组件**：5 个主要 Swift 文件
- **测试结构**：3 个测试文件（可扩展）
- **架构**：清洁、模块化设计
- **训练数据**：3 个数据集中的 100K 翻译对
- **模型大小**：约 10MB 内存占用（LoRA 适配器）

## 贡献指南

1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 遵循传统提交格式（`feat:`、`fix:`、`docs:` 等）
4. 确保所有测试通过：在 Xcode 中按 `⌘U`
5. 推送到分支 (`git push origin feature/amazing-feature`)
6. 打开 Pull Request

### 开发指南
- 使用 SwiftUI 最佳实践
- 遵循 Swift 并发模式与 async/await
- 维护清洁架构分离
- 为新功能添加测试
- 为 API 变更更新文档

## 许可证

本项目采用 MIT 许可证。

## 致谢

- **Apple's FoundationModels Framework** - 支持端侧 AI 翻译
- **SwiftUI** - 现代声明式 UI 框架
- **DeepSeek-R1 Model** - 自定义适配器训练的基础模型
- **中文 NLP 社区** - 推进语言处理技术

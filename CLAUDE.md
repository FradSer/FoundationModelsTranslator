# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

```bash
# Build and run
xcodebuild -scheme FoundationModelsTranslator -configuration Debug build
open FoundationModelsTranslator.xcodeproj  # Opens in Xcode for development

# Testing
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS'
xcodebuild test -scheme FoundationModelsTranslator -only-testing:FoundationModelsTranslatorTests
⌘U  # Run all tests in Xcode

# Debug and monitoring
log stream --predicate 'subsystem == "FoundationModelsTranslator"' --level debug

# Adapter file verification
ls -la FoundationModelsTranslator/translation_en_zh_CN.fmadapter/
file FoundationModelsTranslator/translation_en_zh_CN.fmadapter/adapter_weights.bin

# Translation adapter training (reproduction)
cd /Users/FradSer/Downloads/adapter_training_toolkit_v26_0_0/translation/
./train_translation.sh  # Complete automated training
```

## Architecture Overview

This is a native macOS translation app implementing **Clean Architecture** with FoundationModels integration:

### Four-Layer Architecture

1. **Presentation Layer** (`ContentView.swift`)
   - SwiftUI interface with `@Observable` state management
   - Cross-platform clipboard handling (UIKit/AppKit conditional compilation)
   - Real-time streaming translation display with glass morphism design

2. **Application Layer** (`TranslationManager.swift`)
   - `@MainActor` business logic with FoundationModels session management
   - Adapter loading with transparent fallback to base model
   - Streaming translation with state preservation

3. **Domain Layer** (`Translation.swift`)
   - Data models with `@Generable` annotations for structured AI output
   - `TranslationRequest` and `TranslationResult` entities
   - Error enumeration with localized descriptions

4. **Infrastructure Layer**
   - Custom LoRA adapter (`translation_en_zh_CN.fmadapter/`, 133MB)
   - Bundle resource management for adapter loading
   - Glass design system (`GlassDesign.swift`) for consistent UI styling

## Critical Technical Constraints

### FoundationModels Integration
- **Main Thread Lock**: `TranslationManager` requires `@MainActor` - sessions cannot be passed between actors
- **Session Lifecycle**: `prewarm()` must be called before first translation to avoid 3-5 second cold start
- **Memory Boundaries**: Each session maintains isolated context - no state sharing across managers

### Streaming Architecture Pattern
```swift
// TranslationManager.swift:82-98 - Real-time translation with state preservation
let stream = session.streamResponse(generating: TranslationResult.self, includeSchemaInPrompt: false)
for try await partialResponse in stream {
    currentTranslation = partialResponse.content  // Live UI updates
}
```

### Transparent Adapter Fallback
- **Silent Degradation**: Adapter loading failure triggers automatic fallback with identical Chinese instructions
- **Bundle Resource Pattern**: Uses `Bundle.main.url(forResource:withExtension:)` for adapter detection
- **Instruction Duplication**: Chinese prompts duplicated in both adapter/fallback paths ensure behavior consistency

## Custom Translation Adapter

### Technical Specifications
- **Training**: Apple Foundation Models Adapter Training Toolkit
- **Base Model**: DeepSeek-R1 Distilled optimized for translation
- **LoRA Rank**: 32 for efficient fine-tuning (~133MB storage)
- **Speculative Decoding**: 5 draft tokens for enhanced inference speed
- **Training Dataset**: 100K samples across 3 datasets with intelligent sampling
- **License**: MIT License

### Training Pipeline Location
```
/Users/FradSer/Downloads/adapter_training_toolkit_v26_0_0/translation/
```
- Multi-dataset integration with automatic format standardization
- Quality evaluation with BLEU scores and assessment metrics
- Automated training with optimized hyperparameters

## Glass Design System

The `GlassDesign.swift` implements a sophisticated glass morphism system:
- **Material Hierarchy**: `ultraThin`, `thin`, `regular` materials
- **Surface Types**: `windowBackground`, `primarySurface`, `inputArea`, `outputAccent`, `listBackdrop`, `toolbarControl`
- **Descriptor Pattern**: Centralized configuration for corner radius, shadow, and stroke opacity
- **View Extension**: `.glassSurface(_:)` modifier for consistent application

### Input Area Implementation
```swift
// ContentView.swift:82-98 - Glass input area with transparent TextEditor
ZStack(alignment: .topLeading) {
    RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(Material.regularMaterial)
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(Color.white.opacity(0.08), lineWidth: 1))

    TextEditor(text: $inputText)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
}
```

## Cross-Platform Conditional Compilation

```swift
#if canImport(UIKit)
UIPasteboard.general.string = result.translatedText
#elseif canImport(AppKit)
NSPasteboard.general.setString(result.translatedText, forType: .string)
#endif
```

## Testing Architecture

Uses modern Swift Testing framework (`@Test`) instead of XCTest:
- **Parallel Execution**: Enabled by default
- **Model Validation**: Tests focus on `TranslationRequest`, `TranslationResult`, and `TranslationError` data structures
- **No Session Mocking**: FoundationModels sessions cannot be mocked due to `@MainActor` requirements

## File System Constraints

- **Git Exclusion**: `adapter_weights.bin` (133MB) excluded via .gitignore due to GitHub 100MB limit
- **Bundle Resource Detection**: Use `Bundle.main.url()` not filesystem existence checks
- **Adapter Metadata**: LoRA rank 32, 5 draft tokens for speculative decoding in `metadata.json`

## Performance Optimization Patterns

```swift
// TranslationManager.swift:129-131 - Prewarming for performance
func prewarm() {
    session.prewarm()  // Reduces cold start delay from 3-5 seconds
}
```

## Data Flow Architecture

```
TranslationRequest → TranslationManager → FoundationModels → TranslationResult → UI Update
```

- **Async/Await Pattern**: Non-blocking translation operations
- **Streaming Results**: Immediate user feedback during translation
- **Memory Isolation**: Each manager maintains isolated session context
- **Error Context**: Async errors set on `TranslationManager.error` property trigger SwiftUI alert binding

## Development Workflow Integration

- **Debug Logging**: OSLog with subsystem "FoundationModelsTranslator" for session lifecycle tracking
- **Adapter Loading**: Monitor console logs for adapter vs fallback behavior
- **Stream Monitoring**: Real-time debugging of partial translation responses
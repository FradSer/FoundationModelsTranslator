# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

```bash
# Build and run
xcodebuild -scheme FoundationModelsTranslator -configuration Debug build
# Run tests
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS'
# Debug logs
log stream --predicate 'subsystem == "FoundationModelsTranslator"'
```

## Critical Architecture Patterns

### Structured Generation with Streaming States
- `@Generable` structs define LLM output structure, auto-generate `PartiallyGenerated` types
- UI handles dual states: `TranslationResult.PartiallyGenerated` → `TranslationResult`
- Property declaration order in `@Generable` matters - generated sequentially
- Stream updates via `currentTranslation`, completed results stored in `translations` array

### Transparent Adapter Fallback
- Attempts custom LoRA adapter load: `translation_en_zh_CN.fmadapter`
- Silent fallback to base `SystemLanguageModel` with identical instructions
- Both paths use same `LanguageModelSession` interface - transparent to UI
- Adapter metadata: LoRA rank 32, speculative decoding (5 draft tokens)

### Threading Constraints
- `TranslationManager` requires `@MainActor` - FoundationModels sessions are main-thread only
- Cannot pass sessions between actors or use in background contexts
- All streaming updates automatically main-thread safe

## Critical Integration Points

### Session Initialization Pattern
```swift
// ContentView.onAppear
translationManager.prewarm()  // Essential for first-translation performance
```

### Structured Prompt Engineering
Chinese instructions duplicated in both adapter/fallback paths ensure consistent behavior regardless of adapter availability.

### Cross-Platform Clipboard
```swift
#if canImport(UIKit)
UIPasteboard.general.string = result.translatedText
#elseif canImport(AppKit)
NSPasteboard.general.setString(result.translatedText, forType: .string)
#endif
```

## File Constraints

- `adapter_weights.bin` (133MB) excluded from git - GitHub 100MB limit
- Check adapter presence: `Bundle.main.url(forResource: "translation_en_zh_CN", withExtension: "fmadapter")`
- Production deployment: Use Asset Packs for runtime adapter download

## Testing Framework

Swift Testing (`@Test`) used instead of XCTest. Test single target:
```bash
xcodebuild test -scheme FoundationModelsTranslator -only-testing:FoundationModelsTranslatorTests
```
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

```bash
# Build and run
xcodebuild -scheme FoundationModelsTranslator -configuration Debug build
# Run specific tests
xcodebuild test -scheme FoundationModelsTranslator -only-testing:FoundationModelsTranslatorTests
# Debug logs with subsystem filtering
log stream --predicate 'subsystem == "FoundationModelsTranslator"' --level debug
# Check adapter presence
ls -la FoundationModelsTranslator/translation_en_zh_CN.fmadapter/
```

## Critical Architecture Constraints

### Dual-State Streaming Pattern
- **UI Identity Crisis**: `currentTranslation` (PartiallyGenerated) → `translations` array (completed) requires UUID-based identity preservation
- **Property Order Dependency**: `@Generable` struct property declaration order determines LLM generation sequence - place critical fields last
- **State Transition Logic**: `TranslationManager:96-118` handles partial→complete with array replacement using UUID matching

### FoundationModels Session Constraints
- **Main Thread Lock**: `@MainActor` required on `TranslationManager` - sessions cannot be passed between actors or used in background contexts
- **Session Lifecycle**: `prewarm()` must occur before first translation to avoid 3-5 second cold start delay
- **Memory Boundaries**: Each session maintains its own context - cannot share state across multiple managers

### Transparent Adapter Fallback Architecture
- **Silent Degradation**: Adapter loading failure at `TranslationManager:24-47` triggers transparent fallback with identical Chinese instructions
- **Bundle Resource Pattern**: `Bundle.main.url(forResource:withExtension:)` for `.fmadapter` detection - no filesystem checks needed
- **Instruction Duplication**: Chinese prompts duplicated in both adapter/fallback paths ensures behavior consistency regardless of adapter availability

## Critical Implementation Patterns

### Streaming State Management
```swift
// TranslationManager.swift:82-98 - Streaming with state preservation
let stream = session.streamResponse(generating: TranslationResult.self, includeSchemaInPrompt: false)
for try await partialResponse in stream {
    currentTranslation = partialResponse.content  // Real-time UI updates
}
// Completed translation replaces loading entry using UUID matching
```

### Cross-Platform Conditional Compilation
```swift
// Used in ContentView.swift:173-177 and TranslationHistoryView.swift:141-159
#if canImport(UIKit)
UIPasteboard.general.string = text
#elseif canImport(AppKit)
NSPasteboard.general.setString(text, forType: .string)
#endif
```

### Error Context Preservation
- **Async Error Propagation**: Errors set on `TranslationManager.error` property trigger SwiftUI alert binding
- **Silent Adapter Failures**: Adapter load failures logged but don't block session creation - app remains functional

## File System Constraints

- **Git Exclusion**: `adapter_weights.bin` (133MB) exceeds GitHub 100MB limit - excluded via .gitignore
- **Adapter Metadata**: LoRA rank 32, 5 draft tokens for speculative decoding in `metadata.json`
- **Bundle Resource Detection**: Use `Bundle.main.url()` not filesystem existence checks for adapter presence

## Testing Architecture

Swift Testing framework (`@Test`) replaces XCTest - parallel execution enabled by default. Test data models only - FoundationModels sessions cannot be mocked due to `@MainActor` requirements.
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

# Check adapter presence and file structure
ls -la FoundationModelsTranslator/translation_en_zh_CN.fmadapter/
file FoundationModelsTranslator/translation_en_zh_CN.fmadapter/adapter_weights.bin

# Run all tests via Xcode
⌘U

# Run tests from command line
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS'

# Open project in Xcode
open FoundationModelsTranslator.xcodeproj
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

### Key Testing Limitations
- **No Session Mocking**: FoundationModels sessions require main actor and real AI interactions
- **Model Validation Focus**: Tests validate `TranslationRequest`, `TranslationResult`, and `Translation` data structures
- **Error Handling Tests**: Localized error description validation via `TranslationError` enum

## Performance Optimization Patterns

### Session Management
```swift
// TranslationManager.swift:129-131 - Prewarming for performance
func prewarm() {
    session.prewarm()  // Reduces cold start delay from 3-5 seconds
}
```

### Memory Isolation
- Each `TranslationManager` instance maintains isolated session context
- No cross-manager state sharing prevents memory leaks and context contamination
- Async/await pattern ensures non-blocking UI operations

## Development Workflow Integration

### Debugging FoundationModels Integration
- Use OSLog with subsystem "FoundationModelsTranslator" for session lifecycle tracking
- Monitor adapter loading vs fallback behavior in console logs
- Stream partial responses for real-time debugging of translation flow

### Adapter Development Workflow
1. Train adapter using external ML pipeline
2. Generate `adapter_weights.bin` and `metadata.json`
3. Place in `FoundationModelsTranslator/translation_en_zh_CN.fmadapter/`
4. Test fallback behavior by temporarily removing adapter file
5. Verify bundle loading via `Bundle.main.url()` detection pattern

## Code Architecture Principles

### Clean Architecture Implementation
- **Data Layer**: `Translation.swift` - Request/Result models with `@Generable` annotations
- **Business Layer**: `TranslationManager.swift` - FoundationModels session management
- **Presentation Layer**: SwiftUI views with `@Observable` state management
- **Dependency Rule**: Source code dependencies point only inward (UI → Manager → Models)

### SwiftUI Integration Patterns
- **@Observable**: Reactive state management replacing `@StateObject`/`@ObservedObject`
- **@MainActor**: Ensures UI updates on main thread for FoundationModels compatibility
- **NavigationStack**: Modern navigation with toolbar integration
- **Conditional Compilation**: Cross-platform clipboard handling
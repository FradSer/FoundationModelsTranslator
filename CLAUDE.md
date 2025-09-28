# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FoundationModelsTranslator is a native macOS SwiftUI application that provides English-to-Chinese translation using Apple's FoundationModels framework. The app leverages a custom LoRA adapter (FradSer/DeepSeek-R1-Distilled-Translate-en-zh_CN-39k-Alpaca-GPT4) for enhanced translation quality with graceful fallback to system models.

## System Requirements

- **macOS 26+** (Tahoe) - Required for FoundationModels framework
- **Xcode 26.0.1+** - Latest development tools with AI integration
- **Swift 6.2+** - Modern Swift with enhanced concurrency support
- **Note**: macOS 26 Tahoe is the final version supporting Intel processors

## Development Commands

### Building
```bash
# Build the main app target
xcodebuild -scheme FoundationModelsTranslator -configuration Debug build

# Build for release
xcodebuild -scheme FoundationModelsTranslator -configuration Release build

# Clean build
xcodebuild -scheme FoundationModelsTranslator clean

# Build and run directly in Xcode: ⌘R
```

### Testing
```bash
# Run all tests in Xcode: ⌘U

# Run all tests from command line
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS'

# Run specific test targets
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS' -only-testing:FoundationModelsTranslatorTests
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS' -only-testing:FoundationModelsTranslatorUITests
```

## Architecture Overview

### Core Data Models (`Translation.swift`)
- **TranslationRequest**: Input data structure with source text and language metadata
- **TranslationResult**: Output structure using `@Generable` protocol with `@Guide` annotations for structured generation
- **Translation**: Complete translation record with timestamp and loading state

### Business Logic (`TranslationManager.swift`)
- **@Observable @MainActor**: Thread-safe reactive state management
- **LanguageModelSession**: Manages FoundationModels integration with custom adapter loading
- **Streaming Support**: Real-time translation updates via `streamResponse` API
- **Error Handling**: Comprehensive `TranslationError` enum with localized descriptions

### UI Components
- **ContentView.swift**: Main interface with real-time streaming display and clipboard integration
- **TranslationHistoryView.swift**: Search-enabled history browser with context menus

### Critical Implementation Details

#### Custom Adapter Integration
```swift
// Attempts to load: FoundationModelsTranslator/translation_en_zh_CN.fmadapter/
let adapter = try SystemLanguageModel.Adapter(fileURL: adapterURL)
let adaptedModel = SystemLanguageModel(adapter: adapter)
```

#### Structured Generation Pattern
```swift
@Generable
struct TranslationResult {
    @Guide(description: "The translated text in the target language")
    let translatedText: String

    @Guide(description: "A confidence score between 0.0 and 1.0")
    let confidence: Double

    @Guide(description: "Brief explanation of cultural adaptations")
    let notes: String?
}
```

#### Cross-Platform Clipboard Support
```swift
#if canImport(UIKit)
UIPasteboard.general.string = result.translatedText
#elseif canImport(AppKit)
NSPasteboard.general.setString(result.translatedText, forType: .string)
#endif
```

## Important Development Notes

### Adapter File Management
- The `adapter_weights.bin` file is excluded from git due to GitHub's 100MB limit
- App automatically detects adapter presence and falls back to base model if unavailable
- No manual intervention required - the fallback is transparent

### Testing Framework
- Uses Swift Testing (`@Test`) instead of XCTest
- Current test coverage focuses on data model validation
- Test expansion opportunities: Manager state testing, error scenarios, UI interactions

### Performance Optimizations
- Session prewarming with `prewarm()` for faster startup
- Async/await patterns for non-blocking operations
- Streaming results for immediate user feedback
- Background session initialization

### Platform Specifics
- Primarily optimized for macOS with responsive layout
- Cross-platform code supports iOS/visionOS but UI is macOS-focused
- Uses platform-specific clipboard and UI components where needed

## FoundationModels Best Practices (2024-2025)

### Session Management
```swift
// Store session as @State in SwiftUI views
@State var session = LanguageModelSession()

// Prewarm for immediate use
session.prewarm()

// Check session status before new requests
if !session.isResponding {
    // Safe to make new requests
}
```

### Streaming Response Patterns
```swift
// Use streamResponse for better UX instead of respond()
let stream = session.streamResponse(
    generating: TranslationResult.self,
    includeSchemaInPrompt: false,
    options: GenerationOptions(sampling: .greedy)
) { prompt }

for try await partialResponse in stream {
    // Update UI with partial results
    currentTranslation = partialResponse.content
}
```

### Property Declaration Order
- Properties in `@Generable` structs are generated in declaration order
- Place most important properties (like summaries) last for better model output quality
- Consider UI animation requirements when ordering properties

### SwiftUI Integration
- Use `.smooth()` animation curves for natural, Apple-like motion
- Think carefully about view identity when generating arrays in streaming contexts
- Leverage SwiftUI animations to hide latency and create delightful loading experiences

## Swift Testing Migration (Current Framework)

### Key Advantages Over XCTest
- **Parallel Execution**: Tests run in parallel by default for better performance
- **Better Error Messages**: More contextual failure information with suggestions
- **No Inheritance**: Use structs/actors instead of XCTestCase subclassing
- **Parameterized Tests**: Elegant testing of multiple inputs without loops

### Migration Strategy
```swift
// XCTest pattern (old)
import XCTest
class TranslationTests: XCTestCase {
    func testTranslationRequest() {
        XCTAssertEqual(request.sourceText, "test")
    }
}

// Swift Testing pattern (current)
import Testing
struct TranslationTests {
    @Test func translationRequest() {
        #expect(request.sourceText == "test")
    }
}
```

### Important Migration Notes
- Can mix XCTest and Swift Testing in same target during transition
- Do NOT mix frameworks within a single test
- Use `init`/`deinit` instead of `setUp`/`tearDown` methods
- Only import Testing library in test targets, never in app targets

## LoRA Adapter Architecture Details

### Adapter File Structure
The `.fmadapter` format is Apple's proprietary package containing:
- LoRA adapter weights (quantized to 2-4 bit mixed precision, ~3.7 bits-per-weight average)
- Configuration metadata for runtime loading
- Optional draft model checkpoints for speculative decoding

### Deployment Strategies
```swift
// Bundle with app (development/testing)
Bundle.main.url(forResource: "translation_en_zh_CN", withExtension: "fmadapter")

// Production recommendation: Use Asset Packs for runtime download
// - Keeps app size smaller
// - Allows easier adapter updates
// - Better for App Store distribution
```

### Adapter Optimization
- Apple uses mixed 2-bit/4-bit quantization averaging 3.7 bits-per-weight
- On-device adapters consume ~10MB memory footprint
- Training data filtered via rejection sampling for high-quality outputs
- Pluggable architecture allows runtime task-specific selection

## 2025 Apple Platform Updates

### Unified Version Numbering
Apple changed its version numbering convention in 2025 for consistency across all platforms:
- **Version 26** represents the 2025-2026 release cycle
- All platforms (iOS 26, macOS 26, watchOS 26, etc.) use the same number
- This replaced the previous sequential numbering (iOS 18, macOS 15, etc.)

### Liquid Glass Design Language
The new design language introduced in 2025 replaces the flat design from iOS 7:
- **Translucent Elements**: Glass-like materials with optical properties
- **Motion Response**: UI elements react to user interactions and device motion
- **Cross-Platform**: Unified design across iPhone, iPad, Mac, and Apple Watch
- **visionOS Influenced**: Brings spatial computing design principles to traditional platforms

### Development Tool Enhancements
- **Xcode 26**: AI integration with ChatGPT and Claude
- **Icon Composer**: New tool for creating layered Liquid Glass icons
- **SwiftUI Instruments**: Enhanced debugging for view updates and data flow

## Current Limitations & Considerations

### Swift Testing Limitations
- No performance testing support (XCTMetric not available)
- No UI automation testing support
- XCTest remains fully supported and not deprecated

### FoundationModels Framework
- Requires macOS 26+ / iOS 26+ minimum (unified version numbering)
- macOS 26 Tahoe is the final version supporting Intel processors
- On-device execution ensures privacy but limits model size
- Adapter training requires Apple's official toolkit for compatibility
- GitHub file size limits require careful adapter weight management
- Enhanced integration with Liquid Glass design language for improved UX
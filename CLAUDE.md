# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FoundationModelsTranslator is a SwiftUI application for iOS, macOS, and visionOS that provides English-to-Chinese translation using Apple's FoundationModels framework. The app leverages local ML adapter models for enhanced translation quality and can fall back to system models when adapters are unavailable.

## Development Commands

### Building
```bash
# Build the main app target
xcodebuild -scheme FoundationModelsTranslator -configuration Debug build

# Build for release
xcodebuild -scheme FoundationModelsTranslator -configuration Release build

# Clean build
xcodebuild -scheme FoundationModelsTranslator clean
```

### Testing
```bash
# Run unit tests
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS'

# Run unit tests only
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS' -only-testing:FoundationModelsTranslatorTests

# Run UI tests
xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS' -only-testing:FoundationModelsTranslatorUITests
```

### Running in Simulator
```bash
# Build and run on macOS
xcodebuild -scheme FoundationModelsTranslator -destination 'platform=macOS' run

# For iOS Simulator (replace with available simulator)
xcodebuild -scheme FoundationModelsTranslator -destination 'platform=iOS Simulator,name=iPhone 15' run
```

## Architecture Overview

### Core Components

- **FoundationModelsTranslatorApp.swift**: Main app entry point using SwiftUI App lifecycle
- **ContentView.swift**: Primary user interface with translation input/output and history access
- **TranslationManager.swift**: `@Observable` business logic layer handling FoundationModels integration
- **Translation.swift**: Data models including `TranslationRequest`, `TranslationResult`, and `Translation`
- **TranslationHistoryView.swift**: Secondary view for displaying translation history

### Key Dependencies

- **FoundationModels**: Apple's framework for local ML model execution and structured generation
- **SwiftUI**: UI framework with modern declarative patterns
- **Observation**: Modern Swift observation system for reactive updates

### Data Flow

1. User input captured in `ContentView`
2. `TranslationManager` processes requests using `LanguageModelSession`
3. Real-time streaming updates via `@Observable` state management
4. Results stored in local history and displayed with confidence scores

### ML Model Integration

- Attempts to load local `.fmadapter` file (`translation_en_zh_CN.fmadapter`)
- Falls back to system language model if adapter unavailable
- Uses structured generation with `@Generable` protocol for consistent output format
- Implements streaming responses for real-time translation updates

## Platform Support

- **iOS**: 26.0+
- **macOS**: 26.0+
- **visionOS**: 26.0+
- **Swift**: 5.0+ with modern concurrency and observation features
- **Xcode**: 26.0+ (uses latest project format with file system synchronization)

## Testing Strategy

- Unit tests focus on data model validation and error handling
- Uses Swift Testing framework (`@Test`) instead of XCTest
- Includes comprehensive error scenario testing for translation failures
- UI tests cover end-to-end translation workflows
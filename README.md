# FoundationModelsTranslator

A native macOS app for English to Chinese translation powered by Apple's FoundationModels framework with SwiftUI interface.

## Features

- **Real-time Translation**: Stream translation results as they're generated using FoundationModels
- **Custom Adapter Support**: Specialized English to Chinese translation adapter for enhanced quality
- **Translation History**: Track and search through previous translations
- **Confidence Scoring**: Get confidence ratings for translation quality
- **Cultural Notes**: Contextual explanations for cultural adaptations
- **Native SwiftUI Interface**: Modern macOS design with responsive layout

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15.0+
- Swift 5.9+
- FoundationModels framework

## Architecture

The app follows clean architecture principles with clear separation of concerns:

### Core Components

- **Translation Models** (`Translation.swift`)
  - `TranslationRequest`: Input data structure
  - `TranslationResult`: Output with confidence and notes
  - `Translation`: Complete translation record

- **Translation Manager** (`TranslationManager.swift`)
  - Manages FoundationModels session
  - Handles adapter loading and fallback
  - Provides streaming translation support
  - Error handling and state management

- **UI Components**
  - `ContentView`: Main translation interface
  - `TranslationHistoryView`: History browser with search
  - Real-time progress indication
  - Cross-platform clipboard support

### Custom Adapter

The app includes a specialized English to Chinese translation adapter (`translation_en_zh_CN.fmadapter`) for improved translation quality in specific domains.

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/FradSer/FoundationModelsTranslator.git
   cd FoundationModelsTranslator
   ```

2. **Open in Xcode**
   ```bash
   open FoundationModelsTranslator.xcodeproj
   ```

3. **Build and Run**
   - Select your target device
   - Press `⌘R` to build and run

## Testing

The project includes comprehensive test coverage:

### Unit Tests
- **Model Tests**: Data structure validation
- **Manager Tests**: Business logic and state management
- **Error Handling**: Comprehensive error scenarios
- **Integration Tests**: End-to-end workflow validation

### UI Tests
- **ContentView**: User interaction flows
- **History View**: Navigation and search functionality
- **Error States**: UI error handling

Run tests with:
```bash
⌘U in Xcode
# or
xcodebuild test -scheme FoundationModelsTranslator
```

## Project Structure

```
FoundationModelsTranslator/
├── FoundationModelsTranslator/
│   ├── FoundationModelsTranslatorApp.swift    # App entry point
│   ├── ContentView.swift                      # Main UI
│   ├── TranslationHistoryView.swift          # History interface
│   ├── Translation.swift                     # Data models
│   ├── TranslationManager.swift              # Business logic
│   ├── Assets.xcassets/                      # App resources
│   └── translation_en_zh_CN.fmadapter/      # Custom adapter
├── FoundationModelsTranslatorTests/          # Unit tests
├── FoundationModelsTranslatorUITests/        # UI tests
└── README.md
```

## Usage

1. **Enter English Text**: Type or paste English text in the input area
2. **Translate**: Click the translate button to start real-time translation
3. **View Results**: See streaming translation with confidence score
4. **Access History**: Browse previous translations with search functionality
5. **Copy Results**: Use context menus or copy buttons to export translations

## Technical Details

### FoundationModels Integration
- Uses `@Generable` protocol for structured output
- Implements streaming with `LanguageModelSession`
- Custom adapter integration with fallback support
- Confidence scoring and cultural adaptation notes

### Error Handling
- Adapter loading failures
- Network connectivity issues
- Translation service errors
- User-friendly error messages

### Performance
- Efficient streaming implementation
- Memory management for large histories
- Responsive UI during long translations

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Apple's FoundationModels framework
- SwiftUI for the native interface
- Chinese language processing community
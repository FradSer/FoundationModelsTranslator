# Repository Guidelines

## Project Structure & Module Organization
The SwiftUI interface lives in `FoundationModelsTranslator/ContentView.swift` and `TranslationHistoryView.swift`, the application orchestration sits in `TranslationManager.swift`, domain entities reside in `Translation.swift`, and the infrastructure layer is anchored by `translation_en_zh_CN.fmadapter` alongside `Assets.xcassets`.
Tests follow the same layering: unit cases under `FoundationModelsTranslatorTests` assert domain and manager behaviour, while launch and UI journeys sit in `FoundationModelsTranslatorUITests`, keeping clean boundaries between interface and core logic.

## Architecture & Layering
Treat the app as four concentric layers—Interface, Application, Domain, Infrastructure—and only allow dependencies to point inward; inject collaborators (e.g., pass `TranslationManager` into views) to preserve testability and swap strategies.
Model new data sources behind lightweight repository protocols so concurrency attributes like `@MainActor` stay intentional.

## Build, Test, and Development Commands
Run `xcodebuild build -scheme FoundationModelsTranslator -destination 'platform=macOS'` to validate the project compiles with the current SDK gate.
Execute `xcodebuild test -scheme FoundationModelsTranslator -destination 'platform=macOS'` before every push; this is the green stage of TDD and doubles as CI smoke coverage.
Open the workspace with `xed FoundationModelsTranslator.xcodeproj` for iterative development, then hit `⌘U` to rerun the same test plan quickly.

## Coding Style & Naming Conventions
Use Swift 6 defaults: four-space indentation, PascalCase for types, lowerCamelCase for properties and functions, and prefer protocol-oriented extensions to preserve composability.
Favour early returns, avoid magic numbers, omit emojis or secrets, and document intent with concise `///` comments where logic is non-obvious.

## Testing Guidelines
Write failing `XCTestCase` methods named `test_featureScenario_expectedOutcome` before implementing features, mirror UI contracts with UI flows using descriptive screen objects, and rerun `xcodebuild test` after each refactor.
Augment tests with dependency-injected fakes for streaming translations so history, error paths, and concurrency behaviours stay deterministic.

## Commit & Pull Request Guidelines
Format commits as lower-case Conventional Commits under 50 characters (e.g., `feat: add streaming retry guard`) and keep each change atomic to the behaviour under test.
Every pull request should summarise architecture impact, link tracking issues, include UI evidence when visuals change, and confirm build plus test commands were executed successfully.

## Security & Configuration Tips
Keep adapter weight files outside version control; place them under `FoundationModelsTranslator/translation_en_zh_CN.fmadapter/` locally and reference the path in documentation without uploading binaries.
Store API keys or model secrets in the system keychain or Xcode schemes, never in Swift sources, and review diffs for accidental credentials before pushing.

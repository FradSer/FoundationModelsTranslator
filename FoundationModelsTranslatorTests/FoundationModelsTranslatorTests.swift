//
//  FoundationModelsTranslatorTests.swift
//  FoundationModelsTranslatorTests
//
//  Created by Frad LEE on 9/27/25.
//

import Testing
import Foundation
@testable import FoundationModelsTranslator

struct TranslationModelTests {

    @Test func translationRequest_initialization() {
        let request = TranslationRequest(sourceText: "Hello, world!")

        #expect(request.sourceText == "Hello, world!")
        #expect(request.sourceLanguage == "en")
        #expect(request.targetLanguage == "zh-CN")
        #expect(request.id != UUID())
    }

    @Test func translationRequest_customLanguages() {
        let request = TranslationRequest(
            sourceText: "Bonjour",
            sourceLanguage: "fr",
            targetLanguage: "en"
        )

        #expect(request.sourceText == "Bonjour")
        #expect(request.sourceLanguage == "fr")
        #expect(request.targetLanguage == "en")
    }

    @Test func translationResult_initialization() {
        let result = TranslationResult(
            translatedText: "你好，世界！",
            confidence: 0.95,
            notes: "Standard greeting"
        )

        #expect(result.translatedText == "你好，世界！")
        #expect(result.confidence == 0.95)
        #expect(result.notes == "Standard greeting")
    }

    @Test func translationResult_defaultValues() {
        let result = TranslationResult(translatedText: "Test")

        #expect(result.translatedText == "Test")
        #expect(result.confidence == 1.0)
        #expect(result.notes == nil)
    }

    @Test func translation_initialization() {
        let request = TranslationRequest(sourceText: "Test")
        let result = TranslationResult(translatedText: "测试")
        let translation = Translation(request: request, result: result)

        #expect(translation.request.sourceText == "Test")
        #expect(translation.result?.translatedText == "测试")
        #expect(translation.isLoading == false)
        #expect(translation.timestamp <= Date())
    }

    @Test func translation_loadingState() {
        let request = TranslationRequest(sourceText: "Loading test")
        let translation = Translation(request: request, isLoading: true)

        #expect(translation.request.sourceText == "Loading test")
        #expect(translation.result == nil)
        #expect(translation.isLoading == true)
    }

    @Test func translationResult_example() {
        let example = TranslationResult.example

        #expect(example.translatedText == "你好，世界！")
        #expect(example.confidence == 0.95)
        #expect(example.notes == "Standard greeting translation")
    }
}

struct TranslationErrorTests {

    @Test func translationError_descriptions() {
        #expect(TranslationError.adapterNotFound.errorDescription == "Translation adapter not found in app bundle")
        #expect(TranslationError.adapterLoadFailed.errorDescription == "Failed to load translation adapter")
        #expect(TranslationError.sessionNotReady.errorDescription == "Translation session not ready")
        #expect(TranslationError.translationFailed.errorDescription == "Translation failed")
    }

    @Test func translationError_localizedError() {
        let error: LocalizedError = TranslationError.adapterNotFound
        #expect(error.errorDescription != nil)
    }
}

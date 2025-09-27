//
//  Translation.swift
//  FoundationModelsTranslator
//

import FoundationModels
import Foundation

struct TranslationRequest {
    let sourceText: String
    let sourceLanguage: String
    let targetLanguage: String
    let id: UUID = UUID()

    init(sourceText: String, sourceLanguage: String = "en", targetLanguage: String = "zh-CN") {
        self.sourceText = sourceText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
    }
}

@Generable
struct TranslationResult {
    @Guide(description: "The translated text in the target language")
    let translatedText: String

    @Guide(description: "A confidence score between 0.0 and 1.0 indicating translation quality")
    let confidence: Double

    @Guide(description: "Brief explanation of any cultural or contextual adaptations made")
    let notes: String?

    init(translatedText: String, confidence: Double = 1.0, notes: String? = nil) {
        self.translatedText = translatedText
        self.confidence = confidence
        self.notes = notes
    }
}

struct Translation {
    let id: UUID = UUID()
    let request: TranslationRequest
    let result: TranslationResult?
    let timestamp: Date
    let isLoading: Bool

    init(request: TranslationRequest, result: TranslationResult? = nil, isLoading: Bool = false) {
        self.request = request
        self.result = result
        self.timestamp = Date()
        self.isLoading = isLoading
    }
}

extension TranslationResult {
    static let example = TranslationResult(
        translatedText: "你好，世界！",
        confidence: 0.95,
        notes: "Standard greeting translation"
    )
}
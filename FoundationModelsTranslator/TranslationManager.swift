//
//  TranslationManager.swift
//  FoundationModelsTranslator
//

import FoundationModels
import Observation
import OSLog

@Observable
@MainActor
final class TranslationManager {
    private(set) var currentTranslation: TranslationResult.PartiallyGenerated?
    private var session: LanguageModelSession

    var error: Error?
    var isLoading = false

    private let logger = Logger(subsystem: "FoundationModelsTranslator", category: "TranslationManager")

    init() {
        do {
            if let adapterURL = Bundle.main.url(forResource: "translation_en_zh_CN", withExtension: "fmadapter") {
                let adapter = try SystemLanguageModel.Adapter(fileURL: adapterURL)
                let adaptedModel = SystemLanguageModel(adapter: adapter)

                session = LanguageModelSession(
                    model: adaptedModel,
                    instructions: Instructions {
                        """
                        你是一个翻译助手，你只会直接将用户的输入翻译成中文。

                        要求：
                        - 直接给出答案：只有翻译后的内容。
                        - 准确性：必须准确传达原文的意思，不遗漏或歪曲信息。
                        - 流畅性：在中文中应读起来自然，像本地人写的文本一样。
                        - 文化适应性：应考虑中国人的文化背景，使用合适的表达和格式。
                        - 主题专业性：判断原文的相关领域，根据相关领域有专业知识，确保术语使用正确。
                        """
                    }
                )

                logger.info("Translation session initialized with local adapter: \(adapterURL.path)")
            } else {
                throw TranslationError.adapterNotFound
            }
        } catch {
            logger.error("Failed to load local adapter: \(error.localizedDescription)")

            session = LanguageModelSession(
                instructions: Instructions {
                    """
                    你是一个翻译助手，你只会直接将用户的输入翻译成中文。

                    要求：
                    - 直接给出答案：只有翻译后的内容。
                    - 准确性：必须准确传达原文的意思，不遗漏或歪曲信息。
                    - 流畅性：在中文中应读起来自然，像本地人写的文本一样。
                    - 文化适应性：应考虑中国人的文化背景，使用合适的表达和格式。
                    - 主题专业性：判断原文的相关领域，根据相关领域有专业知识，确保术语使用正确。
                    """
                }
            )

            logger.info("Translation session initialized without adapter (fallback)")
        }
    }

    func translate(_ request: TranslationRequest) async throws {

        isLoading = true
        error = nil
        currentTranslation = nil

        logger.info("Starting translation for text: \(request.sourceText.prefix(50))...")

        do {
            let stream = session.streamResponse(
                generating: TranslationResult.self,
                includeSchemaInPrompt: false,
                options: GenerationOptions(sampling: .greedy)
            ) {
                """
                请将以下英文翻译成中文（简体）：

                "\(request.sourceText)"

                请提供翻译结果、置信度评分和相关的文化说明。
                """
            }

            for try await partialResponse in stream {
                currentTranslation = partialResponse.content
            }

            logger.info("Translation completed successfully")

        } catch {
            self.error = error
            logger.error("Translation failed: \(error.localizedDescription)")
            throw error
        }

        isLoading = false
    }

    func prewarm() {
        session.prewarm()
    }
}

enum TranslationError: LocalizedError {
    case adapterNotFound
    case adapterLoadFailed
    case sessionNotReady
    case translationFailed

    var errorDescription: String? {
        switch self {
        case .adapterNotFound:
            return "Translation adapter not found in app bundle"
        case .adapterLoadFailed:
            return "Failed to load translation adapter"
        case .sessionNotReady:
            return "Translation session not ready"
        case .translationFailed:
            return "Translation failed"
        }
    }
}
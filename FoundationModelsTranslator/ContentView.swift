//
//  ContentView.swift
//  FoundationModelsTranslator
//
//  Created by Frad LEE on 9/27/25.
//

import SwiftUI

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @State private var translationManager = TranslationManager()
    @State private var inputText = ""
    @State private var showingHistory = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                translationHeader

                inputSection

                if translationManager.isLoading {
                    loadingSection
                } else if let currentTranslation = translationManager.currentTranslation {
                    translationOutputSection(currentTranslation)
                }

                if !translationManager.translations.isEmpty {
                    historySection
                }

                Spacer()
            }
            .padding()
            .navigationTitle("翻译器 Translator")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("History") {
                        showingHistory = true
                    }
                    .disabled(translationManager.translations.isEmpty)
                }
            }
            .sheet(isPresented: $showingHistory) {
                TranslationHistoryView(translations: translationManager.translations)
            }
            .alert("Translation Error", isPresented: .constant(translationManager.error != nil)) {
                Button("OK") {
                    translationManager.error = nil
                }
            } message: {
                if let error = translationManager.error {
                    Text(error.localizedDescription)
                }
            }
        }
        .onAppear {
            translationManager.prewarm()
        }
    }

    private var translationHeader: some View {
        VStack(spacing: 8) {
            Text("English → 中文")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Enter English text to translate to Chinese")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("English Text")
                .font(.headline)
                .foregroundColor(.primary)

            TextEditor(text: $inputText)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )

            HStack {
                Button("Clear") {
                    inputText = ""
                }
                .disabled(inputText.isEmpty)

                Spacer()

                Button("Translate") {
                    Task {
                        await performTranslation()
                    }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || translationManager.isLoading)
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Translating...")
                .font(.headline)
                .foregroundColor(.secondary)

            if let partial = translationManager.currentTranslation {
                partialTranslationView(partial)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private func translationOutputSection(_ translation: TranslationResult.PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chinese Translation")
                .font(.headline)
                .foregroundColor(.primary)

            if let translatedText = translation.translatedText,
               let confidence = translation.confidence {
                let finalResult = TranslationResult(
                    translatedText: translatedText,
                    confidence: confidence,
                    notes: translation.notes
                )
                finalTranslationView(finalResult)
            } else {
                partialTranslationView(translation)
            }
        }
    }

    private func finalTranslationView(_ result: TranslationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(result.translatedText)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGreen).opacity(0.1))
                .cornerRadius(12)

            HStack {
                Label("Confidence: \(Int(result.confidence * 100))%", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = result.translatedText
                    #elseif canImport(AppKit)
                    NSPasteboard.general.setString(result.translatedText, forType: .string)
                    #endif
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.caption)
                }
            }

            if let notes = result.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(.systemBlue).opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }

    private func partialTranslationView(_ partial: TranslationResult.PartiallyGenerated) -> some View {
        Text(partial.translatedText ?? "")
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
            )
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Translation")
                .font(.subheadline)
                .fontWeight(.medium)

            if let lastTranslation = translationManager.translations.last,
               let result = lastTranslation.result {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lastTranslation.request.sourceText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(result.translatedText)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 120)
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .onTapGesture {
                    showingHistory = true
                }
            }
        }
    }

    private func performTranslation() async {
        let request = TranslationRequest(
            sourceText: inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        do {
            try await translationManager.translate(request)
        } catch {
        }
    }
}

#Preview {
    ContentView()
}

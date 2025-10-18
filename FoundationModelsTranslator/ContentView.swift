//
//  ContentView.swift
//  FoundationModelsTranslator
//
//  Created by Frad LEE on 9/27/25.
//

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
            Form {
                Section {
                    translationHeader
                }

                Section("English Text") {
                    inputSection
                }

                Section("Chinese Translation") {
                    translationSection
                }

                if !translationManager.translations.isEmpty {
                    Section("Recent Translation") {
                        historyPreview
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Translator")
            .toolbar {
                ToolbarItem(placement: .automatic) {
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
            Text("输入英文文本，翻译成中文 | Enter English text to translate to Chinese")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var inputSection: some View {
        return VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Material.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                TextEditor(text: $inputText)
                    .frame(minHeight: 160)
                    .font(.body)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }

            HStack(spacing: 12) {
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

    private var translationSection: some View {
        Group {
            if translationManager.isLoading {
                loadingView
            } else if let currentTranslation = translationManager.currentTranslation {
                translationOutputSection(currentTranslation)
            } else {
                Text("Translation will appear here after you translate.")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.regular)

            Text("Translating…")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let partial = translationManager.currentTranslation {
                partialTranslationView(partial)
            }
        }
        .transition(.opacity.combined(with: .scale))
    }

    private func translationOutputSection(_ translation: TranslationResult.PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
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
        let notesDescriptor = GlassDesign.descriptor(for: .listBackdrop)

        return VStack(alignment: .leading, spacing: 12) {
            Text(result.translatedText)
                .font(.title3)
                .fontWeight(.semibold)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .glassSurface(.outputAccent)

            HStack(spacing: 12) {
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
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: notesDescriptor.cornerRadius, style: .continuous)
                            .fill(notesDescriptor.material.material)
                            .overlay(
                                RoundedRectangle(cornerRadius: notesDescriptor.cornerRadius, style: .continuous)
                                    .stroke(Color.white.opacity(notesDescriptor.strokeOpacity))
                            )
                    )
            }
        }
    }

    private func partialTranslationView(_ partial: TranslationResult.PartiallyGenerated) -> some View {
        return Text(partial.translatedText ?? "")
            .font(.body)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .glassSurface(.outputAccent)
    }

    private var historyPreview: some View {
        Group {
            if let lastTranslation = translationManager.translations.last,
               let result = lastTranslation.result {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lastTranslation.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(lastTranslation.request.sourceText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(result.translatedText)
                        .font(.body)

                    Button {
                        showingHistory = true
                    } label: {
                        Label("Open full history", systemImage: "clock.arrow.circlepath")
                    }
                    .buttonStyle(.link)
                }
            } else {
                EmptyView()
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

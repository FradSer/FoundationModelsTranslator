//
//  TranslationHistoryView.swift
//  FoundationModelsTranslator
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct TranslationHistoryView: View {
    let translations: [Translation]
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredTranslations: [Translation] {
        if searchText.isEmpty {
            return translations.reversed()
        } else {
            return translations.reversed().filter { translation in
                translation.request.sourceText.localizedCaseInsensitiveContains(searchText) ||
                translation.result?.translatedText.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredTranslations.isEmpty {
                    Section {
                        emptyStateView
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    ForEach(filteredTranslations, id: \.id) { translation in
                        TranslationHistoryRowView(translation: translation)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Translation History")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search translations...")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No Translations Yet")
                .font(.title2)
                .fontWeight(.medium)

            Text("Your translation history will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

struct TranslationHistoryRowView: View {
    let translation: Translation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(translation.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let result = translation.result {
                    Label("\(Int(result.confidence * 100))%", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("English")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(translation.request.sourceText)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let result = translation.result {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("中文")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(result.translatedText)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let notes = result.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if translation.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)

                        Text("Translating...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contextMenu {
            if let result = translation.result {
                Button(action: {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = result.translatedText
                    #elseif canImport(AppKit)
                    NSPasteboard.general.setString(result.translatedText, forType: .string)
                    #endif
                }) {
                    Label("Copy Translation", systemImage: "doc.on.doc")
                }

                Button(action: {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = translation.request.sourceText
                    #elseif canImport(AppKit)
                    NSPasteboard.general.setString(translation.request.sourceText, forType: .string)
                    #endif
                }) {
                    Label("Copy Original", systemImage: "doc.on.doc")
                }
            }
        }
    }
}

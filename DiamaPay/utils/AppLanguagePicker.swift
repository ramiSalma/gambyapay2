import SwiftUI
import Translation

struct AppLanguagePicker: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @State private var showLanguages = false
    var settingsRowStyle = false

    var body: some View {
        Button { showLanguages = true } label: {
            if settingsRowStyle {
                HStack(spacing: 16) {
                    Image(systemName: "globe")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "174EA6"))
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.buttonTitle(AppStrings.language))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.black)
                        Text(localization.language.displayName)
                            .font(.footnote)
                            .foregroundColor(Color(hex: "475467"))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "475467"))
                }
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            } else {
                Label(AppStrings.buttonTitle("\(AppStrings.language): \(localization.language.displayName)"), systemImage: "globe")
            }
        }
        .accessibilityLabel(AppStrings.language)
        .sheet(isPresented: $showLanguages) {
            NavigationStack {
                List(AppLanguage.supported) { language in
                    Button {
                        localization.select(language)
                        showLanguages = false
                    } label: {
                        HStack {
                            Text(language.displayName)
                            Spacer()
                            if language == localization.language {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                .navigationTitle(AppStrings.language)
                .toolbar { Button(AppStrings.buttonTitle(AppStrings.close)) { showLanguages = false } }
            }
        }
    }
}

/// Runs once at the app root, keeping language work independent of forms and navigation.
struct AppTranslationModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.modifier(AutomaticTranslationModifier())
        } else {
            content
        }
    }
}

@available(iOS 18.0, *)
private struct AutomaticTranslationModifier: ViewModifier {
    @ObservedObject private var localization = AppLanguageStore.shared

    func body(content: Content) -> some View {
        content
            .disabled(localization.request != nil)
            .overlay {
                if let request = localization.request {
                    TranslationPreparationView(request: request)
                        .id(request.id)
                }
            }
            .alert(AppStrings.error, isPresented: Binding(
                get: { localization.translationError != nil },
                set: { if !$0 { localization.translationError = nil } }
            )) {
                Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { localization.translationError = nil }
            } message: {
                Text(localization.translationError ?? "")
            }
            .task {
                // Translate new catalog entries after an update; cached copy needs no download.
                localization.select(localization.language, persistPreference: false)
            }
    }
}

@available(iOS 18.0, *)
private struct TranslationPreparationView: View {
    let request: AppLanguageStore.Request
    @ObservedObject private var localization = AppLanguageStore.shared
    @State private var configuration: TranslationSession.Configuration?
    @State private var groups: [String] = []
    @State private var entries: [String: AppStrings.Entry] = [:]
    @State private var translations: [String: AppLanguageStore.CachedText] = [:]

    private enum PreparationError: Error { case incomplete, placeholdersChanged }

    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 18) {
                ProgressView(AppStrings.translatingApp)
                Text(request.language.displayName).font(.headline)
                Button(AppStrings.buttonTitle(AppStrings.cancelLanguage)) { localization.cancel() }
            }
            .padding(28)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        }
        .task {
            entries = localization.missingEntries(for: request.language, ignoringCache: request.refresh)
            groups = Array(Set(entries.values.map(\.language))).sorted()
            advance()
        }
        .translationTask(configuration) { session in
            await translate(using: session)
        }
    }

    @MainActor private func advance() {
        guard localization.request?.id == request.id else { return }
        guard let source = groups.first else {
            localization.finish(request, translations: translations)
            return
        }
        configuration = TranslationSession.Configuration(
            source: Locale.Language(identifier: source), target: Locale.Language(identifier: request.language.rawValue)
        )
    }

    @MainActor private func translate(using session: TranslationSession) async {
        guard let source = session.sourceLanguage?.languageCode?.identifier else { return }
        let batch = entries.filter { $0.value.language == source }.sorted { $0.key < $1.key }
        do {
            try await session.prepareTranslation()
            // Bounded batches keep large legal copy from becoming one oversized request.
            for start in stride(from: 0, to: batch.count, by: 30) {
                try Task.checkCancellation()
                guard localization.request?.id == request.id else { return }
                let chunk = Array(batch[start..<min(start + 30, batch.count)])
                let responses = try await session.translations(from: chunk.map {
                    TranslationSession.Request(sourceText: $0.value.source, clientIdentifier: $0.key)
                })
                guard responses.count == chunk.count else { throw PreparationError.incomplete }
                for response in responses {
                    guard let key = response.clientIdentifier, let entry = entries[key],
                          !response.targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        throw PreparationError.incomplete
                    }
                    guard placeholders(in: entry.source) == placeholders(in: response.targetText) else {
                        throw PreparationError.placeholdersChanged
                    }
                    translations[key] = .init(source: entry.source, translation: response.targetText)
                }
            }
            guard localization.request?.id == request.id else { return }
            groups.removeAll { $0 == source }
            advance()
        } catch {
            guard !Task.isCancelled else { return }
            localization.fail(request)
        }
    }

    private func placeholders(in text: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: "__ARG_[0-9]+__")
        return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }.sorted()
    }
}

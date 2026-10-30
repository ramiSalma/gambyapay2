import SwiftUI
import Combine

/// Only the two supported app languages may be selected or restored.
struct AppLanguage: RawRepresentable, Identifiable, Hashable, Codable {
    let rawValue: String
    init?(rawValue: String) {
        let code = Locale(identifier: rawValue).language.languageCode?.identifier
        guard let code, ["en", "fr"].contains(code) else { return nil }
        self.rawValue = code
    }
    static let english = AppLanguage(rawValue: "en")!
    static let french = AppLanguage(rawValue: "fr")!
    static let supported: [AppLanguage] = [.french, .english]
    var id: String { rawValue }
    var displayName: String { self == .french ? "Français" : "English" }
    var baseCode: String { rawValue }
    var layoutDirection: LayoutDirection { .leftToRight }
}

final class AppLanguageStore: ObservableObject {
    static let shared = AppLanguageStore()
    private static let preferenceKey = "app.preferredLanguage"
    private static let cacheKey = "app.translatedCopy.v1"

    struct CachedText: Codable {
        let source: String
        let translation: String
        var sourceLanguage: String? = nil
    }
    struct Request: Identifiable, Equatable {
        let id = UUID()
        let language: AppLanguage
        var refresh = false
        var persistPreference = true
    }

    @Published private(set) var language: AppLanguage
    @Published private(set) var request: Request?
    @Published var translationError: String?
    private let defaults: UserDefaults
    private var cache: [String: [String: CachedText]]

    init(defaults: UserDefaults = .standard, preferredLanguages: [String] = Locale.preferredLanguages) {
        self.defaults = defaults
        language = defaults.string(forKey: Self.preferenceKey)
            .flatMap(AppLanguage.init(rawValue:))
            ?? preferredLanguages.compactMap(AppLanguage.init(rawValue:)).first ?? .english
        cache = defaults.data(forKey: Self.cacheKey)
            .flatMap { try? JSONDecoder().decode([String: [String: CachedText]].self, from: $0) } ?? [:]
        // Migrate an unsupported saved choice to the supported device preference.
        if let saved = defaults.string(forKey: Self.preferenceKey), saved != language.rawValue {
            defaults.set(language.rawValue, forKey: Self.preferenceKey)
        }
    }

    private func builtin(_ entry: AppStrings.Entry, for language: AppLanguage) -> String? {
        if !entry.hasLinguisticContent { return entry.source }
        if language.baseCode == entry.language { return entry.source }
        if language.baseCode == "fr" { return entry.french }
        return nil
    }

    private func cachedText(for key: String, entry: AppStrings.Entry, target: AppLanguage) -> CachedText? {
        guard let cached = cache[target.rawValue]?[key], cached.source == entry.source,
              cached.sourceLanguage == entry.language else { return nil }
        return cached
    }

    func text(for key: String) -> String {
        guard let entry = AppStrings.catalog[key] else { return key }
        if let native = builtin(entry, for: language) { return native }
        if let cached = cachedText(for: key, entry: entry, target: language) { return cached.translation }
        return entry.source
    }

    func missingEntries(for target: AppLanguage, ignoringCache: Bool = false) -> [String: AppStrings.Entry] {
        AppStrings.catalog.filter { key, entry in
            builtin(entry, for: target) == nil && (ignoringCache || cachedText(for: key, entry: entry, target: target) == nil)
        }
    }

    func select(_ target: AppLanguage, refresh: Bool = false, persistPreference: Bool = true) {
        guard AppLanguage.supported.contains(target), request == nil else { return }
        translationError = nil
        if #unavailable(iOS 18.0) {
            // Preserve the original built-in choices on older supported iPhones.
            if target == .english || target == .french { commit(target, persistPreference: persistPreference) }
            return
        }
        if missingEntries(for: target, ignoringCache: refresh).isEmpty {
            commit(target, persistPreference: persistPreference)
        } else {
            request = Request(language: target, refresh: refresh, persistPreference: persistPreference)
        }
    }

    /// Commit only a complete catalog so a failed download keeps the previous selection.
    func finish(_ current: Request, translations: [String: CachedText]) {
        guard request?.id == current.id else { return }
        var merged = cache[current.language.rawValue] ?? [:]
        if current.refresh {
            let required = missingEntries(for: current.language, ignoringCache: true)
            guard required.keys.allSatisfy({ translations[$0] != nil }) else { fail(current); return }
        }
        for (key, translation) in translations {
            guard let entry = AppStrings.catalog[key], translation.source == entry.source,
                  !translation.translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            // Include source language in cache identity; older caches are regenerated.
            merged[key] = CachedText(source: entry.source, translation: translation.translation, sourceLanguage: entry.language)
        }
        cache[current.language.rawValue] = merged
        guard missingEntries(for: current.language).isEmpty else {
            fail(current)
            return
        }
        if let data = try? JSONEncoder().encode(cache) { defaults.set(data, forKey: Self.cacheKey) }
        request = nil
        commit(current.language, persistPreference: current.persistPreference)
    }

    func fail(_ current: Request) {
        guard request?.id == current.id else { return }
        request = nil
        translationError = AppStrings.translationFailed
    }

    func cancel() { request = nil }

    private func commit(_ target: AppLanguage, persistPreference: Bool) {
        language = target
        if persistPreference { defaults.set(target.rawValue, forKey: Self.preferenceKey) }
    }
}

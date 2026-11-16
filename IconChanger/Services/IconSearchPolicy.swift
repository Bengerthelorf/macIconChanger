import Foundation

struct IconSearchResult {
    let icons: [IconRes]
    let isComplete: Bool

    init(icons: [IconRes], isComplete: Bool = true) {
        self.icons = icons
        self.isComplete = isComplete
    }
}

enum IconSearchPolicy {
    private static let builtInAliases = [
        "discord ptb": "discord",
        "pycharm professional edition": "pycharm",
    ]
    private static let foldingLocale = Locale(identifier: "en_US_POSIX")

    static func normalizedQuery(_ query: String) -> String {
        let normalized = query
            .folding(options: [.caseInsensitive, .widthInsensitive], locale: foldingLocale)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
        return builtInAliases[normalized] ?? normalized
    }

    static func hasStrongMatch(_ icons: [IconRes], query: String) -> Bool {
        let query = SearchName(query)
        guard !query.text.isEmpty else { return false }
        return icons.contains { icon in
            switch SearchName(icon.appName).relevance(to: query) {
            case .exact, .words: return true
            default: return false
            }
        }
    }

    static func rankAndDeduplicate(_ icons: [IconRes], queries: [String]) -> [IconRes] {
        let queries = queries.map(SearchName.init).filter { !$0.text.isEmpty }
        let ranked = icons.compactMap { icon -> RankedIcon? in
            let name = SearchName(icon.appName)
            let matches = queries.enumerated().compactMap { index, query -> Match? in
                guard let relevance = name.relevance(to: query) else { return nil }
                return Match(relevance: relevance.rawValue, queryIndex: index)
            }
            guard let match = matches.min() else { return nil }
            return RankedIcon(icon: icon, match: match)
        }.sorted {
            if $0.match != $1.match { return $0.match < $1.match }
            if $0.icon.downloads != $1.icon.downloads { return $0.icon.downloads > $1.icon.downloads }
            if $0.icon.id != $1.icon.id { return $0.icon.id < $1.icon.id }
            if $0.icon.appName != $1.icon.appName { return $0.icon.appName < $1.icon.appName }
            return $0.icon.icnsUrl.absoluteString < $1.icon.icnsUrl.absoluteString
        }
        var seen = Set<String>()
        return ranked.map(\.icon).filter { seen.insert($0.id).inserted }
    }

    private enum Relevance: Int {
        case exact
        case words
        case prefix
        case typo
    }

    private struct Match: Comparable {
        let relevance: Int
        let queryIndex: Int

        static func < (lhs: Self, rhs: Self) -> Bool {
            (lhs.relevance, lhs.queryIndex) < (rhs.relevance, rhs.queryIndex)
        }
    }

    private struct RankedIcon {
        let icon: IconRes
        let match: Match
    }

    private struct SearchName {
        let text: String
        let words: [Substring]

        init(_ name: String) {
            text = IconSearchPolicy.normalizedQuery(name)
                .folding(options: .diacriticInsensitive, locale: IconSearchPolicy.foldingLocale)
            words = text.split { character in
                !character.isLetter && !character.isNumber && character != "+" && character != "#"
            }
        }

        func relevance(to query: SearchName) -> Relevance? {
            if text == query.text { return .exact }
            guard let finalWord = query.words.last else { return nil }
            if let remaining = remainingWords(afterMatching: query.words.dropLast()) {
                if remaining.contains(finalWord) { return .words }
                if finalWord.count >= 4, remaining.contains(where: { $0.hasPrefix(finalWord) }) {
                    return .prefix
                }
            }
            guard words.count == query.words.count else { return nil }
            let differences = zip(query.words, words).filter { $0.0 != $0.1 }
            guard differences.count == 1, let (expected, actual) = differences.first,
                  expected.count >= 4, Self.isSingleEdit(expected, actual) else { return nil }
            return .typo
        }

        private func remainingWords(afterMatching expectedWords: ArraySlice<Substring>) -> [Substring]? {
            var remaining = words
            for word in expectedWords {
                guard let index = remaining.firstIndex(of: word) else { return nil }
                remaining.remove(at: index)
            }
            return remaining
        }

        private static func isSingleEdit(_ expected: Substring, _ actual: Substring) -> Bool {
            let left = Array(expected)
            let right = Array(actual)
            guard abs(left.count - right.count) <= 1 else { return false }
            if left.count == right.count {
                let differences = left.indices.filter { left[$0] != right[$0] }
                if differences.count == 1 { return true }
                guard differences.count == 2, let first = differences.first,
                      let second = differences.last, first + 1 == second else { return false }
                return left[first] == right[second] && left[second] == right[first]
            }
            let shorter = left.count < right.count ? left : right
            let longer = left.count < right.count ? right : left
            let firstDifference = shorter.indices.first { shorter[$0] != longer[$0] } ?? shorter.count
            return shorter.dropFirst(firstDifference).elementsEqual(longer.dropFirst(firstDifference + 1))
        }
    }
}

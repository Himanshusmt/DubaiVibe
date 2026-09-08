

import UIKit

class TDCountry: NSObject {
    @objc let name: String
    let code: String
    var section: Int?
    let dialCode: String!
    
    init(name: String, code: String, dialCode: String = " - ") {
        self.name = name
        self.code = code
        self.dialCode = dialCode
    }

    var friendlyCountryCode: String {
        switch code.uppercased() {
        case "GB": return "UK"
        default: return code.uppercased()
        }
    }

    var displayTitle: String {
        "\(name) (\(friendlyCountryCode))"
    }

    func matches(searchText: String) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }

        let normalizedQuery = query.lowercased()
        let upperQuery = query.uppercased()
        let dialQuery = normalizedQuery.replacingOccurrences(of: "+", with: "")

        if name.lowercased().contains(normalizedQuery) {
            return true
        }

        if code.uppercased().contains(upperQuery) || friendlyCountryCode.contains(upperQuery) {
            return true
        }

        let normalizedDial = dialCode.lowercased().replacingOccurrences(of: "+", with: "")
        if dialCode.lowercased().contains(normalizedQuery) || normalizedDial.contains(dialQuery) {
            return true
        }

        if let isoCode = TDCountry.aliasSearchTerms[upperQuery], isoCode == code.uppercased() {
            return true
        }

        if normalizedQuery.count >= 2,
           let matchedISO = TDCountry.aliasSearchTerms.first(where: { $0.key.lowercased().hasPrefix(normalizedQuery) })?.value,
           matchedISO == code.uppercased() {
            return true
        }

        return false
    }

    private static let aliasSearchTerms: [String: String] = [
        "UK": "GB",
        "UAE": "AE",
        "USA": "US",
        "US": "US",
        "IN": "IN",
        "IND": "IN"
    ]
}

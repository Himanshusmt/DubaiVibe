import Foundation
import GoogleSignIn
import UIKit

/// Reads OAuth ids from `GoogleService-Info.plist` (add `CLIENT_ID` / `REVERSED_CLIENT_ID` when ready).
enum GoogleServiceConfig {
    static var values: [String: Any]? {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any]
        else { return nil }
        return dict
    }

    static var clientID: String? {
        nonEmpty(values?["CLIENT_ID"] as? String)
    }

    static var reversedClientID: String? {
        nonEmpty(values?["REVERSED_CLIENT_ID"] as? String)
    }

    static var isConfigured: Bool { clientID != nil }

    static func configureGIDSignInIfPossible() {
        guard let clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    /// URL scheme must match `REVERSED_CLIENT_ID` in Info.plist `CFBundleURLTypes`.
    static var hasMatchingURLScheme: Bool {
        guard let scheme = reversedClientID else { return false }
        guard let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
            return false
        }
        return types.contains { type in
            (type["CFBundleURLSchemes"] as? [String])?.contains(scheme) == true
        }
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

/// Native Google Sign-In via GoogleSignIn SDK. Backend API not wired yet.
final class GoogleSignInService {
    struct Credential {
        let userId: String
        let idToken: String
        let accessToken: String?
        let email: String?
        let fullName: String?
        let givenName: String?
        let familyName: String?
    }

    enum SignInError: LocalizedError {
        case missingClientID
        case missingURLScheme(String)
        case missingIDToken
        case canceled
        case underlying(Error)

        var errorDescription: String? {
            switch self {
            case .missingClientID:
                return "Google Sign-In is not configured yet. Add CLIENT_ID (and REVERSED_CLIENT_ID) to GoogleService-Info.plist, then set the same REVERSED_CLIENT_ID as a URL scheme in Info.plist."
            case .missingURLScheme(let scheme):
                return "Add URL scheme \"\(scheme)\" to Info.plist (CFBundleURLTypes). It must match REVERSED_CLIENT_ID from GoogleService-Info.plist."
            case .missingIDToken:
                return "Google Sign-In did not return an ID token. Please try again."
            case .canceled:
                return nil
            case .underlying(let error):
                return error.localizedDescription
            }
        }
    }

    func signIn(
        from viewController: UIViewController,
        completion: @escaping (Result<Credential, SignInError>) -> Void
    ) {
        guard let clientID = GoogleServiceConfig.clientID else {
            completion(.failure(.missingClientID))
            return
        }

        if let reversed = GoogleServiceConfig.reversedClientID,
           !GoogleServiceConfig.hasMatchingURLScheme {
            completion(.failure(.missingURLScheme(reversed)))
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error {
                let nsError = error as NSError
                if nsError.domain == "com.google.GIDSignIn", nsError.code == GIDSignInError.canceled.rawValue {
                    completion(.failure(.canceled))
                    return
                }
                completion(.failure(.underlying(error)))
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString,
                !idToken.isEmpty
            else {
                completion(.failure(.missingIDToken))
                return
            }

            let profile = user.profile
            let given = Self.trimmed(profile?.givenName)
            let family = Self.trimmed(profile?.familyName)
            let full = Self.trimmed(profile?.name)

            completion(.success(Credential(
                userId: user.userID ?? "",
                idToken: idToken,
                accessToken: user.accessToken.tokenString,
                email: profile?.email,
                fullName: full,
                givenName: given,
                familyName: family
            )))
        }
    }

    private static func trimmed(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

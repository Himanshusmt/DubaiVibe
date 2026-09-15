import FirebaseCore
import Foundation
import GoogleSignIn
import UIKit

/// Reads OAuth ids from `GoogleService-Info.plist` (or Firebase `clientID` fallback).
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
            ?? nonEmpty(FirebaseApp.app()?.options.clientID)
    }

    static var reversedClientID: String? {
        nonEmpty(values?["REVERSED_CLIENT_ID"] as? String)
            ?? reversedClientID(from: clientID)
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

    static func reversedClientID(from clientID: String?) -> String? {
        guard let clientID, clientID.hasSuffix(".apps.googleusercontent.com") else { return nil }
        let prefix = String(clientID.dropLast(".apps.googleusercontent.com".count))
        guard !prefix.isEmpty else { return nil }
        return "com.googleusercontent.apps.\(prefix)"
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

/// Native Google Sign-In via GoogleSignIn SDK.
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
                return L10n.googleNotConfigured
            case .missingURLScheme(let scheme):
                return L10n.googleMissingScheme(scheme)
            case .missingIDToken:
                return L10n.googleMissingToken
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
            finish(.failure(.missingClientID), completion)
            return
        }

        if let reversed = GoogleServiceConfig.reversedClientID,
           !GoogleServiceConfig.hasMatchingURLScheme {
            finish(.failure(.missingURLScheme(reversed)), completion)
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error {
                let nsError = error as NSError
                if nsError.domain == "com.google.GIDSignIn", nsError.code == GIDSignInError.canceled.rawValue {
                    self.finish(.failure(.canceled), completion)
                    return
                }
                self.finish(.failure(.underlying(error)), completion)
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString,
                !idToken.isEmpty
            else {
                self.finish(.failure(.missingIDToken), completion)
                return
            }

            let profile = user.profile
            let given = Self.trimmed(profile?.givenName)
            let family = Self.trimmed(profile?.familyName)
            let full = Self.trimmed(profile?.name)

            self.finish(.success(Credential(
                userId: user.userID ?? "",
                idToken: idToken,
                accessToken: user.accessToken.tokenString,
                email: profile?.email,
                fullName: full,
                givenName: given,
                familyName: family
            )), completion)
        }
    }

    static func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    private func finish(
        _ result: Result<Credential, SignInError>,
        _ completion: @escaping (Result<Credential, SignInError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }

    private static func trimmed(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

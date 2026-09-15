import AuthenticationServices
import CryptoKit
import Security
import UIKit

/// Native Sign in with Apple via AuthenticationServices.
final class AppleSignInService: NSObject {
    struct Credential {
        let userId: String
        let identityToken: String
        let authorizationCode: String?
        let nonce: String?
        let email: String?
        let fullName: String?
        let givenName: String?
        let familyName: String?
    }

    enum SignInError: LocalizedError {
        case canceled
        case missingToken
        case missingWindow
        case underlying(Error)

        var errorDescription: String? {
            switch self {
            case .canceled:
                return nil
            case .missingToken:
                return "Apple Sign-In did not return an identity token. Please try again."
            case .missingWindow:
                return "Unable to present Apple Sign-In. Please try again."
            case .underlying(let error):
                return error.localizedDescription
            }
        }
    }

    private var completion: ((Result<Credential, SignInError>) -> Void)?
    private weak var presentationAnchor: ASPresentationAnchor?
    /// Must be retained for the lifetime of the system sheet.
    private var authorizationController: ASAuthorizationController?
    private var currentRawNonce: String?

    func signIn(
        from viewController: UIViewController,
        completion: @escaping (Result<Credential, SignInError>) -> Void
    ) {
        let anchor = viewController.view.window
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first

        guard let anchor else {
            completion(.failure(.missingWindow))
            return
        }

        self.completion = completion
        presentationAnchor = anchor

        let rawNonce = Self.randomNonce()
        currentRawNonce = rawNonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(rawNonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        authorizationController = controller
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func finish(_ result: Result<Credential, SignInError>) {
        let callback = completion
        completion = nil
        authorizationController = nil
        currentRawNonce = nil
        DispatchQueue.main.async {
            callback?(result)
        }
    }

    private static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            return UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ value: String) -> String {
        let hash = SHA256.hash(data: Data(value.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleID = authorization.credential as? ASAuthorizationAppleIDCredential else {
            finish(.failure(.missingToken))
            return
        }

        guard
            let tokenData = appleID.identityToken,
            let identityToken = String(data: tokenData, encoding: .utf8),
            !identityToken.isEmpty
        else {
            finish(.failure(.missingToken))
            return
        }

        let code = appleID.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
        let given = appleID.fullName?.givenName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let family = appleID.fullName?.familyName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = [given, family].compactMap { name -> String? in
            guard let name, !name.isEmpty else { return nil }
            return name
        }
        let fullName = parts.isEmpty ? nil : parts.joined(separator: " ")

        finish(.success(Credential(
            userId: appleID.user,
            identityToken: identityToken,
            authorizationCode: code,
            nonce: currentRawNonce,
            email: appleID.email,
            fullName: fullName,
            givenName: given?.isEmpty == false ? given : nil,
            familyName: family?.isEmpty == false ? family : nil
        )))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            finish(.failure(.canceled))
            return
        }
        finish(.failure(.underlying(error)))
    }
}

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presentationAnchor ?? ASPresentationAnchor()
    }
}

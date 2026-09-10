import AuthenticationServices
import UIKit

/// Native Sign in with Apple via AuthenticationServices.
final class AppleSignInService: NSObject {
    struct Credential {
        let userId: String
        let identityToken: String
        let authorizationCode: String?
        let email: String?
        let fullName: String?
        let givenName: String?
        let familyName: String?
    }

    enum SignInError: LocalizedError {
        case canceled
        case missingToken
        case underlying(Error)

        var errorDescription: String? {
            switch self {
            case .canceled:
                return nil
            case .missingToken:
                return "Apple Sign-In did not return an identity token. Please try again."
            case .underlying(let error):
                return error.localizedDescription
            }
        }
    }

    private var completion: ((Result<Credential, SignInError>) -> Void)?
    private weak var presentationAnchor: ASPresentationAnchor?

    func signIn(
        from viewController: UIViewController,
        completion: @escaping (Result<Credential, SignInError>) -> Void
    ) {
        self.completion = completion
        presentationAnchor = viewController.view.window
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func finish(_ result: Result<Credential, SignInError>) {
        let callback = completion
        completion = nil
        DispatchQueue.main.async {
            callback?(result)
        }
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

import Combine
import Foundation

//new POST /api/mobile/v1/auth/apple
enum AppleAuthAPI {
    static func requestBody(for credential: AppleSignInService.Credential) -> [String: Any] {
        var parameters: [String: Any] = [
            "idToken": credential.identityToken
        ]
        if let givenName = credential.givenName, !givenName.isEmpty {
            parameters["firstName"] = givenName
        }
        if let familyName = credential.familyName, !familyName.isEmpty {
            parameters["lastName"] = familyName
        }
        if let email = credential.email, !email.isEmpty {
            parameters["email"] = email
        }
        return parameters
    }

    static func login(
        credential: AppleSignInService.Credential,
        showLoader: Bool = true
    ) -> AnyPublisher<AuthLoginResponse, APIError> {
        NetworkManager.shared.request(
            endpoint: .appleLogin,
            method: .POST,
            parameters: requestBody(for: credential),
            showLoader: showLoader
        )
    }
}

import Combine
import Foundation

//new POST /api/mobile/v1/auth/google
enum GoogleAuthAPI {
    static func requestBody(for credential: GoogleSignInService.Credential) -> [String: Any] {
        var parameters: [String: Any] = [
            "idToken": credential.idToken
        ]
        if let accessToken = credential.accessToken, !accessToken.isEmpty {
            parameters["accessToken"] = accessToken
        }
        return parameters
    }

    static func login(
        credential: GoogleSignInService.Credential,
        showLoader: Bool = true
    ) -> AnyPublisher<AuthLoginResponse, APIError> {
        NetworkManager.shared.request(
            endpoint: .googleLogin,
            method: .POST,
            parameters: requestBody(for: credential),
            showLoader: showLoader
        )
    }
}

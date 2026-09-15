import Combine
import Foundation

/// Response shape for DubaiVibe Apple login.
struct AppleLoginResponse: Codable {
    let success: Bool?
    let message: String?
    let accessToken: String?
    let token: String?
    let isOnboardingCompleted: Bool?
    let isProfileCompleted: Bool?
    let data: Payload?

    struct Payload: Codable {
        let accessToken: String?
        let token: String?
        let isOnboardingCompleted: Bool?
        let isProfileCompleted: Bool?
    }

    var resolvedAccessToken: String? {
        let candidates = [
            accessToken,
            token,
            data?.accessToken,
            data?.token
        ]
        return candidates
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    var resolvedOnboardingCompleted: Bool {
        isOnboardingCompleted
            ?? data?.isOnboardingCompleted
            ?? isProfileCompleted
            ?? data?.isProfileCompleted
            ?? false
    }
}

enum AppleAuthAPI {
    static func requestBody(for credential: AppleSignInService.Credential) -> [String: Any] {
        var parameters: [String: Any] = [
            "device": FCMNotificationManager.devicePayload(),
            "identityToken": credential.identityToken,
            "user": credential.userId,
            "appleUserId": credential.userId
        ]

        if let code = credential.authorizationCode, !code.isEmpty {
            parameters["authorizationCode"] = code
        }
        if let nonce = credential.nonce, !nonce.isEmpty {
            parameters["nonce"] = nonce
        }
        if let email = credential.email, !email.isEmpty {
            parameters["email"] = email
        }
        if let fullName = credential.fullName, !fullName.isEmpty {
            parameters["fullName"] = fullName
        }
        if let givenName = credential.givenName, !givenName.isEmpty {
            parameters["givenName"] = givenName
        }
        if let familyName = credential.familyName, !familyName.isEmpty {
            parameters["familyName"] = familyName
        }
        return parameters
    }

    static func login(
        credential: AppleSignInService.Credential,
        showLoader: Bool = true
    ) -> AnyPublisher<AppleLoginResponse, APIError> {
        NetworkManager.shared.request(
            endpoint: .appleLogin,
            method: .POST,
            parameters: requestBody(for: credential),
            showLoader: showLoader,
            showErrorAlert: false,
            retryCount: 0
        )
    }
}

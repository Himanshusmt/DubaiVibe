import Combine
import Foundation

/// Response shape for DubaiVibe Apple login — wire when backend is ready.
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

/// Apple backend login. Intentionally not calling MyGuardianLink — DubaiVibe API TBD.
enum AppleAuthAPI {
    /// Builds the request body we will send once `APIEndpoint.baseURL` points at DubaiVibe.
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

    /// Call only after DubaiVibe `/apple` exists. Do not hit MyGuardianLink.
    static func login(
        credential: AppleSignInService.Credential,
        showLoader: Bool = true
    ) -> AnyPublisher<AppleLoginResponse, APIError> {
        // Backend not ready — keep helper ready without network call.
        Fail(error: APIError.custom(
            message: "DubaiVibe Apple login API is not configured yet.",
            code: "APPLE_API_PENDING",
            currentGroupName: nil,
            newGroupName: nil
        ))
        .eraseToAnyPublisher()
    }
}

import Combine
import Foundation

/// Response shape for DubaiVibe Google login — wire when backend is ready.
struct GoogleLoginResponse: Codable {
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
        let candidates = [accessToken, token, data?.accessToken, data?.token]
        return candidates
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }
}

/// Google backend login. Do not call MyGuardianLink — DubaiVibe API TBD.
enum GoogleAuthAPI {
    static func requestBody(for credential: GoogleSignInService.Credential) -> [String: Any] {
        var parameters: [String: Any] = [
            "device": FCMNotificationManager.devicePayload(),
            "idToken": credential.idToken,
            "user": credential.userId,
            "googleUserId": credential.userId
        ]
        if let accessToken = credential.accessToken, !accessToken.isEmpty {
            parameters["accessToken"] = accessToken
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
        credential: GoogleSignInService.Credential,
        showLoader: Bool = true
    ) -> AnyPublisher<GoogleLoginResponse, APIError> {
        Fail(error: APIError.custom(
            message: "DubaiVibe Google login API is not configured yet.",
            code: "GOOGLE_API_PENDING",
            currentGroupName: nil,
            newGroupName: nil
        ))
        .eraseToAnyPublisher()
    }
}

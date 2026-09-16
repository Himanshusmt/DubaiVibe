import Combine
import Foundation

//new DubaiVibe Mobile Auth APIs (`/api/mobile/v1/auth/...`)
final class AuthViewModel {
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Phone OTP 

    func requestPhoneOTP(
        phoneCode: String,
        phone: String,
        completion: @escaping (Result<PhoneOTPResponse, APIError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "phone_code": phoneCode,
            "phone": Self.sanitizedNationalNumber(phone)
        ]
        perform(
            endpoint: .sendOTP,
            method: .POST,
            parameters: parameters,
            completion: completion
        )
    }

    func resendPhoneOTP(
        phoneCode: String,
        phone: String,
        completion: @escaping (Result<PhoneOTPResponse, APIError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "phone_code": phoneCode,
            "phone": Self.sanitizedNationalNumber(phone)
        ]
        perform(
            endpoint: .resendOTP,
            method: .POST,
            parameters: parameters,
            completion: completion
        )
    }

    func verifyPhoneOTP( //new
        phoneCode: String,
        phone: String,
        code: String,
        completion: @escaping (Result<AuthLoginResponse, APIError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "phone_code": phoneCode,
            "phone": Self.sanitizedNationalNumber(phone),
            "code": code.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        perform(
            endpoint: .verifyOTP,
            method: .POST,
            parameters: parameters
        ) { [weak self] (result: Result<AuthLoginResponse, APIError>) in
            if case .success(let response) = result {
                self?.persistLogin(response)
            }
            completion(result)
        }
    }

    // MARK: - Google / Apple //new

    func loginWithGoogle( //new
        credential: GoogleSignInService.Credential,
        completion: @escaping (Result<AuthLoginResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .googleLogin,
            method: .POST,
            parameters: GoogleAuthAPI.requestBody(for: credential)
        ) { [weak self] (result: Result<AuthLoginResponse, APIError>) in
            if case .success(let response) = result {
                self?.persistLogin(response)
            }
            completion(result)
        }
    }

    func loginWithApple( //new
        credential: AppleSignInService.Credential,
        completion: @escaping (Result<AuthLoginResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .appleLogin,
            method: .POST,
            parameters: AppleAuthAPI.requestBody(for: credential)
        ) { [weak self] (result: Result<AuthLoginResponse, APIError>) in
            if case .success(let response) = result {
                self?.persistLogin(response)
            }
            completion(result)
        }
    }

    func googleAuthURL( //new
        callbackURL: String? = nil,
        completion: @escaping (Result<AuthOAuthURLResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .googleAuthURL(callbackURL),
            method: .GET,
            completion: completion
        )
    }

    func appleAuthURL( //new
        callbackURL: String? = nil,
        completion: @escaping (Result<AuthOAuthURLResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .appleAuthURL(callbackURL),
            method: .GET,
            completion: completion
        )
    }

    // MARK: - Session / logout //new

    func fetchSession( //new
        completion: @escaping (Result<AuthSessionResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .authSession,
            method: .GET,
            completion: completion
        )
    }

    /// `GET /users/me` — source of truth for `isOnboardingComplete` after launch.
    func fetchCurrentUser(
        showLoader: Bool = false,
        completion: @escaping (Result<CurrentUserResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .currentUser,
            method: .GET,
            showLoader: showLoader
        ) { (result: Result<CurrentUserResponse, APIError>) in
            if case .success(let response) = result {
                TokenManager.shared.persistAuthSession(
                    token: nil,
                    user: response.resolvedUser,
                    isOnboardingComplete: response.resolvedOnboardingComplete
                )
            }
            completion(result)
        }
    }

    func logout( //new
        completion: @escaping (Result<AuthLogoutResponse, APIError>) -> Void
    ) {
        var headers: [String: String] = [:]
        if let bearer = TokenManager.shared.bearerAuthorizationHeader {
            headers["Authorization"] = bearer
        }
        perform(
            endpoint: .logout,
            method: .POST,
            parameters: [:],
            headers: headers
        ) { (result: Result<AuthLogoutResponse, APIError>) in
            TokenManager.shared.clearUnauthorizedSession()
            UserDefaults.standard.setLoggedIn(value: false)
            completion(result)
        }
    }

    func logoutAll( //new
        completion: @escaping (Result<AuthLogoutResponse, APIError>) -> Void
    ) {
        var headers: [String: String] = [:]
        if let bearer = TokenManager.shared.bearerAuthorizationHeader {
            headers["Authorization"] = bearer
        }
        perform(
            endpoint: .logoutAll,
            method: .POST,
            parameters: [:],
            headers: headers
        ) { (result: Result<AuthLogoutResponse, APIError>) in
            TokenManager.shared.clearUnauthorizedSession()
            UserDefaults.standard.setLoggedIn(value: false)
            completion(result)
        }
    }

    /// `DELETE /api/mobile/v1/users/me` — deactivate account and revoke sessions.
    func deleteAccount(
        completion: @escaping (Result<DeleteAccountResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .deleteAccount,
            method: .DELETE
        ) { (result: Result<DeleteAccountResponse, APIError>) in
            if case .success = result {
                TokenManager.shared.clearUnauthorizedSession()
                UserDefaults.standard.setLoggedIn(value: false)
            }
            completion(result)
        }
    }

    // MARK: - Helpers

    static func sanitizedNationalNumber(_ raw: String) -> String {
        var digits = raw.filter(\.isNumber)
        while digits.hasPrefix("0") {
            digits.removeFirst()
        }
        return digits
    }

    static func isValidNationalNumber(_ raw: String) -> Bool {
        let digits = sanitizedNationalNumber(raw)
        return (8...10).contains(digits.count)
    }

    private func persistLogin(_ response: AuthLoginResponse) {
        TokenManager.shared.persistAuthSession(
            token: response.resolvedToken,
            user: response.resolvedUser,
            isOnboardingComplete: response.resolvedOnboardingComplete
        )
    }

    // MARK: - Mobile Profile //new

    func updateProfile( //new
        notificationsEnabled: Bool? = nil,
        name: String? = nil,
        avatarMediaId: String? = nil,
        avatarUploadUuid: String? = nil,
        clearAvatar: Bool = false,
        includeNullFields: Bool = false,
        completion: @escaping (Result<ProfileResponse, APIError>) -> Void
    ) {
        var parameters: [String: Any] = [:]
        if let notificationsEnabled {
            parameters["notificationsEnabled"] = notificationsEnabled
        }
        if let name {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                parameters["name"] = trimmed
            }
        }
        if clearAvatar {
            parameters["avatarMediaId"] = ""
            parameters["avatarUploadUuid"] = ""
        } else {
            if let avatarMediaId {
                let trimmed = avatarMediaId.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    parameters["avatarMediaId"] = trimmed
                }
            }
            if let avatarUploadUuid {
                let trimmed = avatarUploadUuid.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    parameters["avatarUploadUuid"] = trimmed
                }
            }
        }
        if includeNullFields {
            parameters["gender"] = "male"
            parameters["state"] = "Madhya pradesh"
            parameters["city"] = "Indore"
            parameters["latitude"] = 0.00
            parameters["longitude"] = 0.00
            if parameters["avatarMediaId"] == nil {
                parameters["avatarMediaId"] = ""
            }
            if parameters["avatarUploadUuid"] == nil {
                parameters["avatarUploadUuid"] = ""
            }
        }
        perform(
            endpoint: .updateProfile,
            method: .PATCH,
            parameters: parameters
        ) { (result: Result<ProfileResponse, APIError>) in
            if case .success(let response) = result, let flag = response.resolvedOnboardingFlag {
                TokenManager.shared.isOnboardingCompleted = flag
            }
            completion(result)
        }
    }

    func updateProfileName( //new
        _ name: String,
        completion: @escaping (Result<ProfileResponse, APIError>) -> Void
    ) {
        updateProfile(
            name: name,
            includeNullFields: true,
            completion: completion
        )
    }

    private func perform<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        headers: [String: String] = [:],
        showLoader: Bool = true,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = ""

        NetworkManager.shared.request(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            headers: headers,
            showLoader: showLoader,
            showErrorAlert: false
        )
        .sink { [weak self] completionResult in
            self?.isLoading = false
            if case .failure(let error) = completionResult {
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: T) in
            self?.isLoading = false
            completion(.success(response))
        }
        .store(in: &cancellables)
    }
}

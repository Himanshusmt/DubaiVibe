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

    func logout( //new
        completion: @escaping (Result<AuthLogoutResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .logout,
            method: .POST
        ) { (result: Result<AuthLogoutResponse, APIError>) in
            TokenManager.shared.clearUnauthorizedSession()
            UserDefaults.standard.setLoggedIn(value: false)
            completion(result)
        }
    }

    func logoutAll( //new
        completion: @escaping (Result<AuthLogoutResponse, APIError>) -> Void
    ) {
        perform(
            endpoint: .logoutAll,
            method: .POST
        ) { (result: Result<AuthLogoutResponse, APIError>) in
            TokenManager.shared.clearUnauthorizedSession()
            UserDefaults.standard.setLoggedIn(value: false)
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
        if includeNullFields {
            parameters["gender"] = "male"
            parameters["state"] = "Madhya pradesh"
            parameters["city"] = "Indore"
            parameters["latitude"] = 0.00
            parameters["longitude"] = 0.00
            parameters["avatarMediaId"] = ""
            parameters["avatarUploadUuid"] = ""
        }
        perform(
            endpoint: .updateProfile,
            method: .PATCH,
            parameters: parameters,
            completion: completion
        )
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
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = ""

        NetworkManager.shared.request(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            showLoader: true,
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

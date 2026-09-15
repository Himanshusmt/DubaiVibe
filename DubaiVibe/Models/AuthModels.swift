import Foundation

// MARK: - Mobile Auth //new

struct AuthUser: Codable {
    let id: String?
    let name: String?
    let firstName: String?
    let lastName: String?
    let role: String?
    let email: String?
    let phone: String?
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, firstName, lastName, role, email, phone
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
        name = values.decodeFlexibleIfPresent(forKey: .name)
        firstName = values.decodeFlexibleIfPresent(forKey: .firstName)
        lastName = values.decodeFlexibleIfPresent(forKey: .lastName)
        role = values.decodeFlexibleIfPresent(forKey: .role)
        email = values.decodeFlexibleIfPresent(forKey: .email)
        phone = values.decodeFlexibleIfPresent(forKey: .phone)
        isOnboardingComplete = values.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
            ?? values.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(isOnboardingComplete, forKey: .isOnboardingComplete)
    }

    var resolvedFullName: String? {
        let joined = [resolvedFirstName, resolvedLastName]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !joined.isEmpty { return joined }
        let fallback = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return fallback.isEmpty ? nil : fallback
    }

    var resolvedFirstName: String? {
        let direct = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !direct.isEmpty { return direct }
        return splitName().first
    }

    var resolvedLastName: String? {
        let direct = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !direct.isEmpty { return direct }
        return splitName().last
    }

    private func splitName() -> (first: String?, last: String?) {
        let parts = (name ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }
        guard !parts.isEmpty else { return (nil, nil) }
        if parts.count == 1 { return (parts[0], nil) }
        return (parts[0], parts.dropFirst().joined(separator: " "))
    }
}

// MARK: - Login / verify session (`{ token, user }`) //new

struct AuthLoginData: Decodable {
    let token: String?
    let user: AuthUser?
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case token, user
        case accessToken
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let primary: String? = values.decodeFlexibleIfPresent(forKey: .token)
        let fallback: String? = values.decodeFlexibleIfPresent(forKey: .accessToken)
        token = [primary, fallback]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
        user = try? values.decode(AuthUser.self, forKey: .user)
        isOnboardingComplete = values.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
            ?? values.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
            ?? user?.isOnboardingComplete
    }
}

struct AuthLoginResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: AuthLoginData?
    let token: String?
    let user: AuthUser?

    enum CodingKeys: String, CodingKey {
        case success, message, data, token, user
        case accessToken
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(AuthLoginData.self, forKey: .data)
        let topToken: String? = values.decodeFlexibleIfPresent(forKey: .token)
        let topAccess: String? = values.decodeFlexibleIfPresent(forKey: .accessToken)
        token = [topToken, topAccess]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
        user = try? values.decode(AuthUser.self, forKey: .user)
    }

    var resolvedToken: String? {
        let candidates = [data?.token, token]
        return candidates
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    var resolvedUser: AuthUser? {
        data?.user ?? user
    }

    /// Defaults to `false` until the API (or local onboarding) sets it true.
    var resolvedOnboardingComplete: Bool {
        data?.isOnboardingComplete
            ?? resolvedUser?.isOnboardingComplete
            ?? false
    }
}

// MARK: - Phone OTP request / resend

struct PhoneOTPData: Decodable {
    let requested: Bool?
    let debugCode: String?

    enum CodingKeys: String, CodingKey {
        case requested, debugCode
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        requested = values.decodeFlexibleIfPresent(forKey: .requested)
        debugCode = values.decodeFlexibleIfPresent(forKey: .debugCode)
    }
}

struct PhoneOTPResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: PhoneOTPData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(PhoneOTPData.self, forKey: .data)
    }
}

// MARK: - OAuth URL (Google / Apple web) //new

struct AuthOAuthURLData: Decodable {
    let url: String?

    enum CodingKeys: String, CodingKey {
        case url
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = values.decodeFlexibleIfPresent(forKey: .url)
    }
}

struct AuthOAuthURLResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: AuthOAuthURLData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(AuthOAuthURLData.self, forKey: .data)
    }

    var resolvedURL: String? {
        data?.url?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Session //new

struct AuthSessionResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: AuthUser?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(AuthUser.self, forKey: .data)
    }
}

// MARK: - Logout

struct AuthLogoutData: Decodable {
    let loggedOut: Bool?

    enum CodingKeys: String, CodingKey {
        case loggedOut
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        loggedOut = values.decodeFlexibleIfPresent(forKey: .loggedOut)
    }
}

struct AuthLogoutResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: AuthLogoutData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(AuthLogoutData.self, forKey: .data)
    }
}

// MARK: - Mobile Profile 

struct ProfileData: Decodable {
    let id: String?
    let name: String?
    let notificationsEnabled: Bool?
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, notificationsEnabled
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
        name = values.decodeFlexibleIfPresent(forKey: .name)
        notificationsEnabled = values.decodeFlexibleIfPresent(forKey: .notificationsEnabled)
        isOnboardingComplete = values.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
            ?? values.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
    }
}

struct ProfileResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: ProfileData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(ProfileData.self, forKey: .data)
    }
}

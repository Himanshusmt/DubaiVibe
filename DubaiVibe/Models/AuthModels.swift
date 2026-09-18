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
    let phoneCode: String?
    let notificationsEnabled: Bool?
    let avatarURL: String?
    let avatarMediaId: String?
    let avatarUploadUuid: String?
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, role, email, phone
        case firstName, lastName
        case first_name, last_name
        case phoneCode
        case phone_code
        case notificationsEnabled
        case notifications_enabled
        case avatar
        case avatarURL
        case avatarUrl
        case avatar_url
        case avatarMediaId, avatar_media_id
        case avatarUploadUuid, avatar_upload_uuid
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
        name = values.decodeFlexibleIfPresent(forKey: .name)
        firstName = values.decodeFlexibleIfPresent(forKey: .firstName)
            ?? values.decodeFlexibleIfPresent(forKey: .first_name)
        lastName = values.decodeFlexibleIfPresent(forKey: .lastName)
            ?? values.decodeFlexibleIfPresent(forKey: .last_name)
        role = values.decodeFlexibleIfPresent(forKey: .role)
        email = values.decodeFlexibleIfPresent(forKey: .email)
        phone = values.decodeFlexibleIfPresent(forKey: .phone)
        phoneCode = values.decodeFlexibleIfPresent(forKey: .phoneCode)
            ?? values.decodeFlexibleIfPresent(forKey: .phone_code)
        notificationsEnabled = values.decodeFlexibleIfPresent(forKey: .notificationsEnabled)
            ?? values.decodeFlexibleIfPresent(forKey: .notifications_enabled)
        let nestedAvatar = try? values.decode(AuthAvatarMedia.self, forKey: .avatar)
        avatarURL = values.decodeFlexibleIfPresent(forKey: .avatarURL)
            ?? values.decodeFlexibleIfPresent(forKey: .avatarUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .avatar_url)
            ?? values.decodeFlexibleIfPresent(forKey: .avatar)
            ?? nestedAvatar?.resolvedURL
        avatarMediaId = values.decodeFlexibleIfPresent(forKey: .avatarMediaId)
            ?? values.decodeFlexibleIfPresent(forKey: .avatar_media_id)
            ?? nestedAvatar?.resolvedMediaId
        avatarUploadUuid = values.decodeFlexibleIfPresent(forKey: .avatarUploadUuid)
            ?? values.decodeFlexibleIfPresent(forKey: .avatar_upload_uuid)
            ?? nestedAvatar?.resolvedUploadUuid
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
        try container.encodeIfPresent(phoneCode, forKey: .phoneCode)
        try container.encodeIfPresent(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encodeIfPresent(avatarURL, forKey: .avatarURL)
        try container.encodeIfPresent(avatarMediaId, forKey: .avatarMediaId)
        try container.encodeIfPresent(avatarUploadUuid, forKey: .avatarUploadUuid)
        try container.encodeIfPresent(isOnboardingComplete, forKey: .isOnboardingComplete)
    }

    var resolvedAvatarUploadUuid: String? {
        [avatarUploadUuid, avatarMediaId]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    var hasUploadedAvatar: Bool {
        let remote = resolvedAvatarURL ?? ""
        return !remote.isEmpty || resolvedAvatarUploadUuid != nil
    }

    /// Absolute URL suitable for `setBusinessImage` (handles relative paths + media UUIDs).
    var resolvedAvatarURL: String? {
        Self.sanitizedMediaURL(avatarURL)
            ?? Self.sanitizedMediaURL(resolvedAvatarUploadUuid)
    }

    private static func sanitizedMediaURL(_ raw: String?) -> String? {
        var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !value.isEmpty else { return nil }
        value = value.replacingOccurrences(of: "\\/", with: "/")
        if value.hasPrefix("http://") || value.hasPrefix("https://") {
            return value
        }
        if value.hasPrefix("/"), let origin = Self.apiOrigin {
            return origin + value
        }
        if UUID(uuidString: value) != nil {
            return APIEndpoint.baseURL + "media/\(value)/download"
        }
        return value
    }

    private static var apiOrigin: String? {
        guard let url = URL(string: APIEndpoint.baseURL), let host = url.host else { return nil }
        let scheme = url.scheme ?? "http"
        if let port = url.port {
            return "\(scheme)://\(host):\(port)"
        }
        return "\(scheme)://\(host)"
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

    /// Prefer `phone_code` + national number when both are present, formatted for display.
    var resolvedPhoneDisplay: String? {
        let national = phone?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rawCode = phoneCode?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !national.isEmpty || !rawCode.isEmpty else { return nil }

        let normalizedCode: String
        if rawCode.isEmpty {
            normalizedCode = national.digitsOnly.hasPrefix("1") && !national.digitsOnly.hasPrefix("971")
                ? "+1"
                : "+971"
        } else {
            normalizedCode = rawCode.hasPrefix("+") ? rawCode : "+\(rawCode)"
        }

        let iso = normalizedCode.digitsOnly == "1" ? "US" : "AE"
        let source = national.isEmpty ? rawCode : national
        let formatted = source.phoneDisplay(dialCode: normalizedCode, countryISO: iso)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return formatted.isEmpty ? nil : formatted
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

/// Nested `avatar` object from `/users/me` when the API returns media metadata instead of a bare URL.
private struct AuthAvatarMedia: Decodable {
    let id: String?
    let uuid: String?
    let mediaId: String?
    let uploadUuid: String?
    let sourceURL: String?
    let url: String?
    let src: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, url, src
        case mediaId, media_id
        case uploadUuid, upload_uuid
        case sourceURL, sourceUrl, source_url
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
        uuid = values.decodeFlexibleIfPresent(forKey: .uuid)
        mediaId = values.decodeFlexibleIfPresent(forKey: .mediaId)
            ?? values.decodeFlexibleIfPresent(forKey: .media_id)
        uploadUuid = values.decodeFlexibleIfPresent(forKey: .uploadUuid)
            ?? values.decodeFlexibleIfPresent(forKey: .upload_uuid)
        sourceURL = values.decodeFlexibleIfPresent(forKey: .sourceURL)
            ?? values.decodeFlexibleIfPresent(forKey: .sourceUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .source_url)
        url = values.decodeFlexibleIfPresent(forKey: .url)
        src = values.decodeFlexibleIfPresent(forKey: .src)
    }

    var resolvedURL: String? {
        [sourceURL, url, src]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    var resolvedMediaId: String? {
        [mediaId, id, uuid]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    var resolvedUploadUuid: String? {
        [uploadUuid, uuid, id]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
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
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case success, message, data, token, user
        case accessToken
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
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
        isOnboardingComplete = values.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
            ?? values.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
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

    /// Raw flag from verify-OTP / social login. `nil` and `false` both mean onboarding is incomplete.
    var resolvedOnboardingFlag: Bool? {
        isOnboardingComplete
            ?? data?.isOnboardingComplete
            ?? resolvedUser?.isOnboardingComplete
    }

    /// Defaults to `false` until the API (or local onboarding) sets it true.
    var resolvedOnboardingComplete: Bool {
        resolvedOnboardingFlag == true
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
    let avatarURL: String?
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, notificationsEnabled
        case avatar
        case avatarURL, avatarUrl, avatar_url
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
        name = values.decodeFlexibleIfPresent(forKey: .name)
        notificationsEnabled = values.decodeFlexibleIfPresent(forKey: .notificationsEnabled)
        let nestedAvatar = try? values.decode(AuthAvatarMedia.self, forKey: .avatar)
        avatarURL = values.decodeFlexibleIfPresent(forKey: .avatarURL)
            ?? values.decodeFlexibleIfPresent(forKey: .avatarUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .avatar_url)
            ?? values.decodeFlexibleIfPresent(forKey: .avatar)
            ?? nestedAvatar?.resolvedURL
        isOnboardingComplete = values.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
            ?? values.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
    }
}

struct ProfileResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: ProfileData?
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(ProfileData.self, forKey: .data)
        isOnboardingComplete = values.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
            ?? values.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
    }

    var resolvedOnboardingFlag: Bool? {
        isOnboardingComplete ?? data?.isOnboardingComplete
    }
}

// MARK: - Current user (`GET /users/me`)

struct CurrentUserResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: AuthUser?
    let user: AuthUser?
    let isOnboardingComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case success, message, data, user
        case isOnboardingComplete = "is_onboarding_complete"
        case isOnboardingCompleteCamel = "isOnboardingComplete"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        let nestedUser: AuthUser?
        let nestedFlag: Bool?
        if let nested = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data) {
            nestedUser = try? nested.decode(AuthUser.self, forKey: .user)
            nestedFlag = nested.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
                ?? nested.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
        } else {
            nestedUser = nil
            nestedFlag = nil
        }
        let dataUser = try? values.decode(AuthUser.self, forKey: .data)
        user = nestedUser ?? (try? values.decode(AuthUser.self, forKey: .user))
        data = dataUser
        isOnboardingComplete = values.decodeFlexibleIfPresent(forKey: .isOnboardingComplete)
            ?? values.decodeFlexibleIfPresent(forKey: .isOnboardingCompleteCamel)
            ?? nestedFlag
    }

    var resolvedUser: AuthUser? { user ?? data }

    var resolvedOnboardingFlag: Bool? {
        isOnboardingComplete
            ?? resolvedUser?.isOnboardingComplete
    }

    var resolvedOnboardingComplete: Bool {
        resolvedOnboardingFlag == true
    }
}

// MARK: - Upload (`POST /upload?kind=profile`)

struct MediaUploadData: Decodable {
    let id: String?
    let uuid: String?
    let mediaId: String?
    let uploadUuid: String?
    let sourceURL: String?
    let url: String?
    let src: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, url, src
        case mediaId, media_id
        case uploadUuid, upload_uuid
        case sourceURL, sourceUrl, source_url
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
        uuid = values.decodeFlexibleIfPresent(forKey: .uuid)
        mediaId = values.decodeFlexibleIfPresent(forKey: .mediaId)
            ?? values.decodeFlexibleIfPresent(forKey: .media_id)
        uploadUuid = values.decodeFlexibleIfPresent(forKey: .uploadUuid)
            ?? values.decodeFlexibleIfPresent(forKey: .upload_uuid)
        sourceURL = values.decodeFlexibleIfPresent(forKey: .sourceURL)
            ?? values.decodeFlexibleIfPresent(forKey: .sourceUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .source_url)
        url = values.decodeFlexibleIfPresent(forKey: .url)
        src = values.decodeFlexibleIfPresent(forKey: .src)
    }

    /// Prefer explicit media id, then public id/uuid.
    var resolvedMediaId: String? {
        [mediaId, id, uuid]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    /// Prefer upload uuid fields, then public uuid/id.
    var resolvedUploadUuid: String? {
        [uploadUuid, uuid, id]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    var resolvedSourceURL: String? {
        [sourceURL, url, src]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }
}

struct MediaUploadResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: MediaUploadData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(MediaUploadData.self, forKey: .data)
    }
}

// MARK: - Delete profile picture (`DELETE /users/profile-picture/{id}`)

struct MediaDeleteResponse: Decodable {
    let success: Bool?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case success, message
    }

    init(success: Bool?, message: String?) {
        self.success = success
        self.message = message
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
    }

    /// Treat missing/empty DELETE bodies and `success: true` as deleted.
    var isDeleted: Bool {
        success != false
    }

    static var emptySuccess: MediaDeleteResponse {
        MediaDeleteResponse(success: true, message: nil)
    }
}

// MARK: - Delete account (`DELETE /users/me`)

struct DeleteAccountResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: DeleteAccountData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(DeleteAccountData.self, forKey: .data)
    }

    var isDeleted: Bool {
        if let deleted = data?.deleted { return deleted }
        return success == true
    }
}

struct DeleteAccountData: Decodable {
    let deleted: Bool?

    enum CodingKeys: String, CodingKey {
        case deleted
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        deleted = values.decodeFlexibleIfPresent(forKey: .deleted)
    }
}

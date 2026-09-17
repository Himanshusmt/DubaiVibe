import Combine
import Foundation
import SDWebImage
import UIKit

/// Profile tab view model — `/users/me`, `/upload`, `/auth/logout`, and delete account.
final class ProfileViewModel {
    @Published private(set) var user: AuthUser?
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""
    private(set) var isUpdatingNotifications = false

    private var cancellables = Set<AnyCancellable>()
    private let auth = AuthViewModel()

    /// Cached user from the last login / previous `/users/me` response.
    var cachedUser: AuthUser? {
        let data = UserDefaults.standard.getUserData()
        guard !data.isEmpty else { return nil }
        return try? JSONDecoder().decode(AuthUser.self, from: data)
    }

    /// Shows cache immediately, then refreshes from the network.
    func loadUser(
        showLoader: Bool = false,
        completion: ((Result<AuthUser, APIError>) -> Void)? = nil
    ) {
        if user == nil {
            user = cachedUser
        }

        isLoading = true
        errorMessage = ""

        NetworkManager.shared.request(
            endpoint: .currentUser,
            method: .GET,
            showLoader: showLoader,
            showErrorAlert: false
        )
        .sink { [weak self] completionResult in
            self?.isLoading = false
            if case .failure(let error) = completionResult {
                self?.errorMessage = error.localizedDescription
                completion?(.failure(error))
            }
        } receiveValue: { [weak self] (response: CurrentUserResponse) in
            guard let self else { return }
            self.isLoading = false

            guard let resolved = response.resolvedUser else {
                let error = APIError.serverError(response.message ?? "Unable to load profile.")
                self.errorMessage = error.localizedDescription
                completion?(.failure(error))
                return
            }

            self.applyResolvedUser(resolved)
            completion?(.success(resolved))
        }
        .store(in: &cancellables)
    }

    /// `PATCH /users/me` with `{ "notificationsEnabled": true|false }`.
    func updateNotificationsEnabled(
        _ enabled: Bool,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        guard !isUpdatingNotifications else { return }
        isUpdatingNotifications = true

        auth.updateProfile(
            notificationsEnabled: enabled,
            showLoader: false
        ) { [weak self] result in
            switch result {
            case .success:
                // Keep local flag until profile refresh finishes so UI isn't reset mid-toggle.
                self?.loadUser(showLoader: false) { _ in
                    self?.isUpdatingNotifications = false
                    completion(.success(()))
                }
            case .failure(let error):
                self?.isUpdatingNotifications = false
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }

    /// Edit Profile save:
    /// 1) `POST /upload?kind=profile` when a new photo is chosen — take `mediaId` from the response
    /// 2) `PATCH /users/me` with `name` and that `avatarMediaId`
    /// See http://18.194.78.138:5000/docs#/Mobile%20Upload/post_api_mobile_v1_upload
    func saveEditedProfile(
        firstName: String,
        lastName: String,
        avatarImage: UIImage?,
        showLoader: Bool = true,
        completion: @escaping (Result<ProfileResponse, APIError>) -> Void
    ) {
        let fullName = [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        guard let avatarImage else {
            patchCurrentUser(name: fullName, avatarMediaId: nil, completion: completion)
            return
        }

        isLoading = true
        errorMessage = ""

        NetworkManager.shared.uploadImage(
            endpoint: .upload(kind: "profile"),
            image: avatarImage,
            imageKey: "file",
            method: .POST,
            showLoader: showLoader,
            showErrorAlert: false
        )
        .sink { [weak self] completionResult in
            if case .failure(let error) = completionResult {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: MediaUploadResponse) in
            guard let self else { return }
            let mediaId = response.data?.resolvedMediaId?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let mediaId, !mediaId.isEmpty else {
                self.isLoading = false
                let error = APIError.serverError(response.message ?? "Upload did not return a media id.")
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
                return
            }

            self.persistAvatarUploadIds(
                mediaId: mediaId,
                uploadUuid: response.data?.resolvedUploadUuid
            )
            self.patchCurrentUser(
                name: fullName,
                avatarMediaId: mediaId,
                completion: completion
            )
        }
        .store(in: &cancellables)
    }

    /// 1) `POST /upload?kind=profile` (multipart `file`)
    /// 2) `PATCH /users/me` with `avatarMediaId` / `avatarUploadUuid`
    func uploadAndUpdateAvatar(
        _ image: UIImage,
        showLoader: Bool = true,
        completion: @escaping (Result<(upload: MediaUploadData, profile: ProfileResponse), APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = ""

        NetworkManager.shared.uploadImage(
            endpoint: .upload(kind: "profile"),
            image: image,
            imageKey: "file",
            method: .POST,
            showLoader: showLoader,
            showErrorAlert: false
        )
        .sink { [weak self] completionResult in
            if case .failure(let error) = completionResult {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: MediaUploadResponse) in
            guard let self else { return }
            guard let upload = response.data,
                  upload.resolvedMediaId != nil || upload.resolvedUploadUuid != nil
            else {
                self.isLoading = false
                let error = APIError.serverError(response.message ?? "Upload did not return a media id.")
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
                return
            }

            self.persistAvatarUploadIds(
                mediaId: upload.resolvedMediaId,
                uploadUuid: upload.resolvedUploadUuid
            )

            self.auth.updateProfile(
                avatarMediaId: upload.resolvedMediaId,
                avatarUploadUuid: upload.resolvedUploadUuid
            ) { [weak self] result in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.loadUser(showLoader: false)
                    completion(.success((upload, profile)))
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
        .store(in: &cancellables)
    }

    /// `DELETE /api/mobile/v1/upload/{uuid}` then clears avatar on `PATCH /users/me`.
    func deleteAvatar(
        showLoader: Bool = true,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = ""

        guard let uuid = resolvedAvatarUploadUuid, !uuid.isEmpty else {
            let error = APIError.serverError("Missing upload uuid for delete.")
            isLoading = false
            errorMessage = error.localizedDescription
            completion(.failure(error))
            return
        }

        // Always call DELETE /upload/{uuid} first.
        NetworkManager.shared.request(
            endpoint: .deleteUpload(uuid: uuid),
            method: .DELETE,
            showLoader: showLoader,
            showErrorAlert: false
        )
        .sink { [weak self] completionResult in
            if case .failure(let error) = completionResult {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: MediaDeleteResponse) in
            guard let self else { return }
            guard response.isDeleted else {
                self.isLoading = false
                let error = APIError.serverError(response.message ?? "Unable to delete photo.")
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
                return
            }
            // Drop local image immediately so UI cannot reload the old file/URL.
            self.clearLocalAvatarState()
            self.clearAvatarOnProfile(showLoader: false, completion: completion)
        }
        .store(in: &cancellables)
    }

    /// Whether the profile currently has an uploaded avatar (remote or locally tracked).
    var canDeleteAvatar: Bool {
        resolvedAvatarUploadUuid != nil
            || user?.hasUploadedAvatar == true
            || cachedUser?.hasUploadedAvatar == true
    }

    private var storedAvatarUploadUuid: String? {
        let value = UserDefaults.standard.string(forKey: Self.avatarUploadUuidKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (value?.isEmpty == false) ? value : nil
    }

    private var storedAvatarMediaId: String? {
        let value = UserDefaults.standard.string(forKey: Self.avatarMediaIdKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (value?.isEmpty == false) ? value : nil
    }

    /// UUID used by `DELETE /upload/{uuid}` — stored ids, user payload, or extracted from avatar URL.
    private var resolvedAvatarUploadUuid: String? {
        let candidates: [String?] = [
            storedAvatarUploadUuid,
            storedAvatarMediaId,
            user?.avatarUploadUuid,
            user?.avatarMediaId,
            cachedUser?.avatarUploadUuid,
            cachedUser?.avatarMediaId,
            user?.resolvedAvatarUploadUuid,
            cachedUser?.resolvedAvatarUploadUuid,
            Self.mediaUUID(from: user?.avatarURL),
            Self.mediaUUID(from: cachedUser?.avatarURL),
            Self.mediaUUID(from: user?.resolvedAvatarURL),
            Self.mediaUUID(from: cachedUser?.resolvedAvatarURL)
        ]
        return candidates
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    /// Pulls a media/upload UUID out of absolute or relative avatar URLs.
    private static func mediaUUID(from rawURL: String?) -> String? {
        let raw = rawURL?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !raw.isEmpty else { return nil }
        if UUID(uuidString: raw) != nil { return raw }

        let parts = raw
            .split(separator: "/")
            .map { $0.split(separator: "?").first.map(String.init) ?? String($0) }

        for (index, part) in parts.enumerated() where part == "media" || part == "upload" {
            guard index + 1 < parts.count else { continue }
            let candidate = parts[index + 1]
            if UUID(uuidString: candidate) != nil { return candidate }
        }

        return parts.reversed().first { UUID(uuidString: $0) != nil }
    }

    private func clearAvatarOnProfile(
        showLoader: Bool,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        auth.updateProfile(clearAvatar: true, showLoader: showLoader) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.clearLocalAvatarState()
                self.loadUser(showLoader: false) { _ in
                    self.isLoading = false
                    completion(.success(()))
                }
            case .failure(let error):
                // Upload already deleted — still clear local so the UI recovers.
                self.clearLocalAvatarState()
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }

    private func patchCurrentUser(
        name: String,
        avatarMediaId: String?,
        completion: @escaping (Result<ProfileResponse, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = ""
        auth.updateProfile(
            name: name.isEmpty ? nil : name,
            avatarMediaId: avatarMediaId
        ) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let profile):
                self.loadUser(showLoader: false)
                completion(.success(profile))
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }

    private func persistAvatarUploadIds(mediaId: String?, uploadUuid: String?) {
        let defaults = UserDefaults.standard
        if let uploadUuid, !uploadUuid.isEmpty {
            defaults.set(uploadUuid, forKey: Self.avatarUploadUuidKey)
        }
        if let mediaId, !mediaId.isEmpty {
            defaults.set(mediaId, forKey: Self.avatarMediaIdKey)
        }
    }

    private func clearLocalAvatarState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Self.avatarUploadUuidKey)
        defaults.removeObject(forKey: Self.avatarMediaIdKey)
        Self.removeLocalAvatarFile()
    }

    private static func removeLocalAvatarFile() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profile_avatar.jpg")
        try? FileManager.default.removeItem(at: url)
    }

    private static let avatarUploadUuidKey = "profile.avatarUploadUuid"
    private static let avatarMediaIdKey = "profile.avatarMediaId"

    /// `POST /auth/logout` then clears tokens, user cache, and local profile data.
    func logout(
        showLoader: Bool = true,
        completion: @escaping (Result<AuthLogoutResponse, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = ""

        // Capture token up front and pass it explicitly — logout requires bearer auth.
        var headers: [String: String] = [:]
        if let bearer = TokenManager.shared.bearerAuthorizationHeader {
            headers["Authorization"] = bearer
        }

        NetworkManager.shared.request(
            endpoint: .logout,
            method: .POST,
            parameters: [:],
            headers: headers,
            showLoader: showLoader,
            showErrorAlert: false
        )
        .sink { [weak self] completionResult in
            if case .failure(let error) = completionResult {
                self?.errorMessage = error.localizedDescription
                self?.finishLocalLogout()
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: AuthLogoutResponse) in
            self?.finishLocalLogout()
            completion(.success(response))
        }
        .store(in: &cancellables)
    }

    /// `DELETE /api/mobile/v1/users/me` — soft-deletes account and revokes sessions.
    /// Clears local tokens/cache only after a successful API response.
    func deleteAccount(
        showLoader: Bool = true,
        completion: @escaping (Result<DeleteAccountResponse, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = ""

        NetworkManager.shared.request(
            endpoint: .deleteAccount,
            method: .DELETE,
            showLoader: showLoader,
            showErrorAlert: false
        )
        .sink { [weak self] completionResult in
            self?.isLoading = false
            if case .failure(let error) = completionResult {
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: DeleteAccountResponse) in
            guard let self else { return }
            if response.isDeleted || response.success != false {
                self.finishLocalLogout()
                completion(.success(response))
            } else {
                self.isLoading = false
                let error = APIError.serverError(response.message ?? "Unable to delete account.")
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
        .store(in: &cancellables)
    }

    private func applyResolvedUser(_ resolved: AuthUser) {
        user = resolved
        TokenManager.shared.persistAuthSession(
            token: nil,
            user: resolved
        )
        syncLocalNameCache(from: resolved)

        let uploadUuid = resolved.avatarUploadUuid?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mediaId = resolved.avatarMediaId?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let defaults = UserDefaults.standard

        if resolved.hasUploadedAvatar {
            if !uploadUuid.isEmpty {
                defaults.set(uploadUuid, forKey: Self.avatarUploadUuidKey)
            } else if let extracted = Self.mediaUUID(from: resolved.resolvedAvatarURL) {
                defaults.set(extracted, forKey: Self.avatarUploadUuidKey)
            }
            if !mediaId.isEmpty {
                defaults.set(mediaId, forKey: Self.avatarMediaIdKey)
            }
        } else {
            defaults.removeObject(forKey: Self.avatarUploadUuidKey)
            defaults.removeObject(forKey: Self.avatarMediaIdKey)
            Self.removeLocalAvatarFile()
        }
    }

    private func finishLocalLogout() {
        isLoading = false
        user = nil
        cancellables.removeAll()
        TokenManager.shared.clearUnauthorizedSession()
        UserDefaults.standard.setLoggedIn(value: false)
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clear(with: .disk, completion: nil)
    }

    private func syncLocalNameCache(from user: AuthUser) {
        LocalUserStore.persistName(
            first: user.resolvedFirstName ?? "",
            last: user.resolvedLastName ?? ""
        )
        if let full = user.resolvedFullName, !full.isEmpty {
            TokenManager.shared.saveSocialFullName(full)
        }
    }
}

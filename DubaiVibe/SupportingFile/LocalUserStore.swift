import Foundation
import UIKit

/// Fast local reads for profile data already persisted at login / profile sync.
/// Prefer this over re-decoding or network calls on hot UI paths.
enum LocalUserStore {
    private static let firstNameKey = "profile.firstName"
    private static let lastNameKey = "profile.lastName"
    private static let avatarFileName = "profile_avatar.jpg"

    /// Cached `AuthUser` from the last successful auth / `/users/me` response.
    static var cachedUser: AuthUser? {
        let data = UserDefaults.standard.getUserData()
        guard !data.isEmpty else { return nil }
        return try? JSONDecoder().decode(AuthUser.self, from: data)
    }

    static var firstName: String {
        let stored = UserDefaults.standard.string(forKey: firstNameKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !stored.isEmpty { return stored }
        return cachedUser?.resolvedFirstName ?? ""
    }

    static var lastName: String {
        let stored = UserDefaults.standard.string(forKey: lastNameKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !stored.isEmpty { return stored }
        return cachedUser?.resolvedLastName ?? ""
    }

    /// Full display name from local cache (profile keys → AuthUser → social name).
    static var displayName: String {
        let joined = [firstName, lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if !joined.isEmpty { return joined }

        if let api = cachedUser?.resolvedFullName, !api.isEmpty {
            return api
        }

        let social = TokenManager.shared.socialFullName?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return social.isEmpty ? "Guest" : social
    }

    /// Membership card style: `"Alex R."` when a last name exists.
    static var membershipDisplayName: String {
        let first = firstName
        let last = lastName
        if !first.isEmpty, let initial = last.first {
            return "\(first) \(String(initial).uppercased())."
        }
        let full = displayName
        let parts = full.split(separator: " ").map(String.init)
        if parts.count >= 2, let initial = parts.last?.first {
            return "\(parts[0]) \(String(initial).uppercased())."
        }
        return full
    }

    /// Local avatar file written by Edit Profile / Profile photo picker.
    static var localAvatarImage: UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(avatarFileName)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    /// Remote avatar URL from the last `/users/me` / auth payload.
    static var avatarURL: String? {
        cachedUser?.resolvedAvatarURL
    }

    static func persistName(first: String, last: String) {
        let defaults = UserDefaults.standard
        let trimmedFirst = first.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = last.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedFirst.isEmpty {
            defaults.set(trimmedFirst, forKey: firstNameKey)
        }
        if !trimmedLast.isEmpty {
            defaults.set(trimmedLast, forKey: lastNameKey)
        }
    }

    static func persistAvatar(_ image: UIImage) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(avatarFileName)
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

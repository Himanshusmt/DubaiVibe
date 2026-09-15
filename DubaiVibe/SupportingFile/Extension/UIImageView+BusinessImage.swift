import SDWebImage
import UIKit

enum BusinessImageLoader {
    private static let apiHost = URL(string: APIEndpoint.baseURL)?.host?.lowercased()

    private static let modifier = SDWebImageDownloaderRequestModifier { request in
        guard let url = request.url, shouldAttachAuth(to: url) else { return request }
        var request = request
        if let token = TokenManager.shared.accessToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// S3/CDN public files reject a Bearer token (400). Only the API host needs auth.
    private static func shouldAttachAuth(to url: URL) -> Bool {
        guard let host = url.host?.lowercased(), let apiHost, !apiHost.isEmpty else { return false }
        return host == apiHost
    }

    static func normalizedURL(from raw: String?) -> URL? {
        var trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }
        trimmed = trimmed.replacingOccurrences(of: "\\/", with: "/")
        return URL(string: trimmed)
    }

    static func setImage(
        on imageView: UIImageView,
        urlString: String?,
        placeholder: UIImage? = nil,
        completion: ((UIImage?) -> Void)? = nil
    ) {
        imageView.sd_cancelCurrentImageLoad()
        guard let url = normalizedURL(from: urlString) else {
            imageView.image = placeholder
            completion?(placeholder)
            return
        }
        imageView.sd_setImage(
            with: url,
            placeholderImage: placeholder,
            options: [.retryFailed, .scaleDownLargeImages, .continueInBackground],
            context: [.downloadRequestModifier: modifier],
            progress: nil
        ) { image, _, _, _ in
            completion?(image ?? placeholder)
        }
    }

    static func prefetch(_ urlStrings: [String]) {
        let urls = urlStrings.compactMap { normalizedURL(from: $0) }
        guard !urls.isEmpty else { return }
        SDWebImagePrefetcher.shared.prefetchURLs(
            urls,
            options: [.retryFailed, .scaleDownLargeImages],
            context: [.downloadRequestModifier: modifier],
            progress: nil,
            completed: nil
        )
    }
}

extension UIImageView {
    func setBusinessImage(urlString: String?, placeholder: UIImage? = nil) {
        BusinessImageLoader.setImage(on: self, urlString: urlString, placeholder: placeholder)
    }
}

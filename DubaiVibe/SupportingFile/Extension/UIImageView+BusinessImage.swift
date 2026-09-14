import SDWebImage
import UIKit

enum BusinessImageLoader {
    private static let modifier = SDWebImageDownloaderRequestModifier { request in
        var request = request
        if let token = TokenManager.shared.accessToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    static func setImage(on imageView: UIImageView, urlString: String?, placeholder: UIImage? = nil) {
        imageView.sd_cancelCurrentImageLoad()
        let trimmed = urlString?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let url = URL(string: trimmed), !trimmed.isEmpty else {
            imageView.image = placeholder
            return
        }
        imageView.sd_setImage(
            with: url,
            placeholderImage: placeholder,
            options: [.retryFailed, .scaleDownLargeImages],
            context: [.downloadRequestModifier: modifier]
        )
    }

    static func prefetch(_ urlStrings: [String]) {
        let urls = urlStrings.compactMap { raw -> URL? in
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return URL(string: trimmed)
        }
        guard !urls.isEmpty else { return }
        SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
}

extension UIImageView {
    func setBusinessImage(urlString: String?, placeholder: UIImage? = nil) {
        BusinessImageLoader.setImage(on: self, urlString: urlString, placeholder: placeholder)
    }
}

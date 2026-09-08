//
//  ImageCache.swift
//  MyGuardianLink
//

import UIKit

final class ImageCache: NSCache<AnyObject, AnyObject> {
    static let shared = ImageCache()

    private var memoryWarningObserver: NSObjectProtocol?

    private override init() {
        super.init()
        countLimit = 100
        totalCostLimit = 60 * 1024 * 1024

        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.removeAllObjects()
        }
    }

    subscript(key: AnyObject) -> UIImage? {
        get { object(forKey: key) as? UIImage }
        set {
            if let image = newValue {
                setObject(image, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }
}

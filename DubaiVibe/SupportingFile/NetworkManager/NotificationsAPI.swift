import Combine
import Foundation

/// Mobile notifications — see http://18.194.78.138:5000/docs#/Mobile%20Notifications
enum NotificationsAPI {
    static func list(
        cursor: String? = nil,
        limit: Int = 20,
        showLoader: Bool = true
    ) -> AnyPublisher<NotificationListResponse, APIError> {
        NetworkManager.shared.request(
            endpoint: .listNotifications(cursor: cursor, limit: limit),
            method: .GET,
            showLoader: showLoader,
            showErrorAlert: false
        )
    }

    static func markRead(
        uuid: String,
        showLoader: Bool = false
    ) -> AnyPublisher<NotificationReadResponse, APIError> {
        NetworkManager.shared.request(
            endpoint: .markNotificationRead(uuid: uuid),
            method: .POST,
            showLoader: showLoader,
            showErrorAlert: false
        )
    }
}

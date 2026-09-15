import Combine
import Foundation

/// Typed mobile business APIs. ViewModels call this instead of NetworkManager directly.
enum BusinessAPI {
    static func listCategories(
        showLoader: Bool = false
    ) -> AnyPublisher<CategoryListResponse, APIError> {
        get(.listCategories, showLoader: showLoader)
    }

    static func listBusinesses(
        cursor: String? = nil,
        limit: Int = 20,
        query: String? = nil,
        categoryId: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        showLoader: Bool = true
    ) -> AnyPublisher<BusinessListResponse, APIError> {
        get(
            .listBusinesses(
                cursor: cursor,
                limit: limit,
                name: query,
                categoryId: categoryId,
                lat: latitude,
                lng: longitude
            ),
            showLoader: showLoader
        )
    }

    static func businessDetail(
        uuid: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        showLoader: Bool = true
    ) -> AnyPublisher<BusinessDetailResponse, APIError> {
        get(
            .businessDetail(uuid: uuid, lat: latitude, lng: longitude),
            showLoader: showLoader
        )
    }

    private static func get<T: Decodable>(
        _ endpoint: APIEndpoint,
        showLoader: Bool
    ) -> AnyPublisher<T, APIError> {
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .GET,
            showLoader: showLoader,
            showErrorAlert: false
        )
    }
}

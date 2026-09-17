import Combine
import CoreLocation
import Foundation

final class VenueDetailViewModel {
    @Published private(set) var detail: VenueDetail?
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    private var cancellables = Set<AnyCancellable>()
    private var favoriteCancellables = Set<AnyCancellable>()
    private(set) var isFavoriteRequestInFlight = false

    func load(
        businessID: String,
        showLoader: Bool = true,
        completion: @escaping (Result<VenueDetail, APIError>) -> Void
    ) {
        let uuid = businessID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !uuid.isEmpty else {
            completion(.failure(.invalidURL))
            return
        }

        cancellables.removeAll()
        isLoading = true
        errorMessage = ""

        LocationManager.shared.resolveCurrentCoordinate { [weak self] coordinate in
            guard let self else { return }
            BusinessAPI.businessDetail(
                uuid: uuid,
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude,
                showLoader: showLoader
            )
            .sink { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] (response: BusinessDetailResponse) in
                self?.isLoading = false
                guard let detail = response.business?.asVenueDetail() else {
                    let error = APIError.serverError(response.message ?? "Business not found")
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                self?.detail = detail
                completion(.success(detail))
            }
            .store(in: &self.cancellables)
        }
    }

    /// Optimistic favorite toggle: POST to add, DELETE to remove. Caller rolls UI back on failure.
    func setFavorite(
        businessID: String,
        isFavorite: Bool,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        let uuid = businessID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !uuid.isEmpty else {
            completion(.failure(.invalidURL))
            return
        }
        guard !isFavoriteRequestInFlight else { return }

        isFavoriteRequestInFlight = true
        favoriteCancellables.removeAll()

        BusinessAPI.setFavorite(uuid: uuid, isFavorite: isFavorite, showLoader: false)
            .sink { [weak self] completionResult in
                self?.isFavoriteRequestInFlight = false
                if case .failure(let error) = completionResult {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] (response: FavoriteToggleResponse) in
                self?.isFavoriteRequestInFlight = false
                guard response.isSuccessful else {
                    let error = APIError.serverError(response.message ?? "Unable to update favorite.")
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            .store(in: &favoriteCancellables)
    }
}

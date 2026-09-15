import Combine
import CoreLocation
import Foundation

final class ExploreViewModel {
    @Published private(set) var venues: [Venue] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    private var cancellables = Set<AnyCancellable>()
    private var nextCursor: String?
    private var isPaging = false
    private var pagingFailed = false
    private var activeQuery = ""
    private let pageSize = 20

    var hasMore: Bool { nextCursor != nil && !(nextCursor ?? "").isEmpty }

    func venue(with id: UUID) -> Venue? {
        venues.first { $0.id == id }
    }

    func toggleFavorite(id: UUID) {
        guard let index = venues.firstIndex(where: { $0.id == id }) else { return }
        venues[index].isFavorite.toggle()
    }

    func toggleBookmark(id: UUID) {
        guard let index = venues.firstIndex(where: { $0.id == id }) else { return }
        venues[index].isBookmarked.toggle()
    }

    func loadFeed(
        showLoader: Bool = true,
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        activeQuery = ""
        fetch(reset: true, showLoader: showLoader, completion: completion)
    }

    func search(
        _ query: String,
        showLoader: Bool = true,
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        activeQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        fetch(reset: true, showLoader: showLoader, completion: completion)
    }

    func loadMoreIfNeeded( 
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        guard hasMore, !isLoading, !isPaging, !pagingFailed else { return }
        fetch(reset: false, showLoader: false, completion: completion)
    }

    private func fetch(
        reset: Bool,
        showLoader: Bool,
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        if reset {
            nextCursor = nil
            isPaging = false
            pagingFailed = false
            cancellables.removeAll()
        } else {
            guard let cursor = nextCursor, !cursor.isEmpty else { return }
            isPaging = true
        }

        isLoading = reset
        errorMessage = ""

        let location = LocationManager.shared.lastKnownLocation?.coordinate
        let hasLocation = location != nil

        BusinessAPI.listBusinesses(
            cursor: reset ? nil : nextCursor,
            limit: pageSize,
            query: activeQuery.isEmpty ? nil : activeQuery,
            latitude: hasLocation ? location?.latitude : nil,
            longitude: hasLocation ? location?.longitude : nil,
            showLoader: showLoader
        )
        .sink { [weak self] completionResult in
            self?.isLoading = false
            self?.isPaging = false
            if case .failure(let error) = completionResult {
                if !reset { self?.pagingFailed = true }
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: BusinessListResponse) in
            guard let self else { return }
            self.isLoading = false
            self.isPaging = false
            let incoming = response.items.compactMap { $0.asVenue() }
            self.merge(incoming, reset: reset)
            let cursor = response.nextCursor?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.nextCursor = cursor.isEmpty ? nil : cursor
            self.pagingFailed = false
            completion(.success(response))
        }
        .store(in: &cancellables)
    }

    private func merge(_ incoming: [Venue], reset: Bool) {
        if reset {
            venues = incoming
            return
        }
        var seen = Set(venues.map(\.id))
        var extra: [Venue] = []
        extra.reserveCapacity(incoming.count)
        for venue in incoming where !seen.contains(venue.id) {
            seen.insert(venue.id)
            extra.append(venue)
        }
        venues.append(contentsOf: extra)
    }
}

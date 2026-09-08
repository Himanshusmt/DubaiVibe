import UIKit

final class ExploreViewController: UIViewController {

    @IBOutlet private weak var brandImageView: UIImageView!
    @IBOutlet private weak var taglineLabel: UILabel!
    @IBOutlet private weak var notificationButton: UIButton!
    @IBOutlet private weak var bellDotView: UIView!
    @IBOutlet private weak var locationPillView: UIView!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var searchContainerView: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var venueTableView: UITableView!

    private let repository: ExploreRepositorying
    private let categories = VenueCategory.allCases

    private var venues: [Venue] = []
    private var venueIndex: [UUID: Int] = [:]
    private var selectedCategory: VenueCategory = .all
    private var searchQuery = ""
    private var chipSizeCache: [VenueCategory: CGSize] = [:]

    private var dataSource: UITableViewDiffableDataSource<Int, UUID>!

    init?(coder: NSCoder, repository: ExploreRepositorying) {
        self.repository = repository
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        self.repository = ExploreRepository()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureHeader()
        configureSearch()
        configureCategories()
        configureTable()
        loadFeed()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prefetchArtwork()
    }
}

// MARK: - Setup

private extension ExploreViewController {
    func configureHeader() {
        brandImageView.layer.cornerRadius = 14
        brandImageView.layer.cornerCurve = .continuous
        brandImageView.clipsToBounds = true
        brandImageView.layer.borderWidth = 1
        brandImageView.layer.borderColor = AppPalette.gold.withAlphaComponent(0.55).cgColor
        brandImageView.accessibilityLabel = "Dubai Vibe"

        taglineLabel.attributedText = NSAttributedString(
            string: "DUBAI • EAT • DRINK • EXPLORE",
            attributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                .foregroundColor: AppPalette.secondaryText,
                .kern: 1.6
            ]
        )

        notificationButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        notificationButton.tintColor = AppPalette.gold
        notificationButton.accessibilityLabel = "Notifications"
        notificationButton.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)

        bellDotView.backgroundColor = AppPalette.badgeRed
        bellDotView.layer.cornerRadius = 4.5
        bellDotView.layer.borderWidth = 1.5
        bellDotView.layer.borderColor = AppPalette.background.cgColor
        bellDotView.isUserInteractionEnabled = false

        locationPillView.backgroundColor = AppPalette.surface
        locationPillView.layer.cornerRadius = 18
        locationPillView.layer.cornerCurve = .continuous
        locationPillView.layer.borderWidth = 1
        locationPillView.layer.borderColor = AppPalette.chipBorder.cgColor

        locationButton.accessibilityLabel = "City: Dubai"
        locationButton.menu = UIMenu(children: [
            UIAction(title: "Dubai", state: .on) { _ in },
            UIAction(title: "Abu Dhabi") { [weak self] _ in
                self?.presentSoon(title: "Abu Dhabi")
            }
        ])
        locationButton.showsMenuAsPrimaryAction = true
    }

    func configureSearch() {
        searchContainerView.backgroundColor = AppPalette.searchFill
        searchContainerView.layer.cornerRadius = AppMetrics.searchHeight / 2
        searchContainerView.layer.cornerCurve = .continuous
        searchContainerView.layer.borderWidth = 1
        searchContainerView.layer.borderColor = AppPalette.searchBorder.cgColor

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = AppPalette.secondaryText
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 22, height: 22)

        let left = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 22))
        icon.center = left.center
        left.addSubview(icon)

        searchTextField.leftView = left
        searchTextField.leftViewMode = .always
        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = .clear
        searchTextField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        searchTextField.textColor = AppPalette.primaryText
        searchTextField.tintColor = AppPalette.gold
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search restaurants, bars, nightlife, beaches...",
            attributes: [.foregroundColor: AppPalette.secondaryText]
        )
        searchTextField.returnKeyType = .search
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.autocorrectionType = .no
        searchTextField.spellCheckingType = .no
        searchTextField.inputAccessoryView = makeKeyboardToolbar()
        searchTextField.addTarget(self, action: #selector(handleSearchChanged), for: .editingChanged)
        searchTextField.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func makeKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.barTintColor = AppPalette.surface
        toolbar.tintColor = AppPalette.gold

        let clear = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearSearch))
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        done.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16, weight: .semibold)], for: .normal)

        toolbar.items = [clear, UIBarButtonItem(systemItem: .flexibleSpace), done]
        toolbar.sizeToFit()
        return toolbar
    }

    func configureCategories() {
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        categoryCollectionView.backgroundColor = AppPalette.background
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.contentInsetAdjustmentBehavior = .never
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.decelerationRate = .fast
    }

    func configureTable() {
        venueTableView.separatorStyle = .none
        venueTableView.backgroundColor = AppPalette.background
        venueTableView.showsVerticalScrollIndicator = false
        venueTableView.keyboardDismissMode = .onDrag
        venueTableView.delaysContentTouches = false
        venueTableView.contentInsetAdjustmentBehavior = .never
        venueTableView.estimatedRowHeight = 400
        venueTableView.rowHeight = UITableView.automaticDimension
        venueTableView.prefetchDataSource = self
        venueTableView.contentInset.bottom = 12

        dataSource = UITableViewDiffableDataSource<Int, UUID>(tableView: venueTableView) { [weak self] tableView, indexPath, id in
            guard
                let self,
                let cell = tableView.dequeueReusableCell(withIdentifier: VenueCardCell.reuseIdentifier, for: indexPath) as? VenueCardCell,
                let venue = self.venue(with: id)
            else {
                return UITableViewCell()
            }
            cell.configure(with: venue)
            cell.onFavorite = { [weak self] in self?.toggleFavorite(id: id) }
            cell.onBookmark = { [weak self] in self?.toggleBookmark(id: id) }
            cell.onViewDeal = { [weak self] in self?.presentDeal(id: id) }
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        venueTableView.dataSource = dataSource
        venueTableView.delegate = self
    }

    func loadFeed() {
        venues = repository.venues()
        rebuildIndex()
        applySnapshot(animated: false)
        categoryCollectionView.reloadData()
    }

    func prefetchArtwork() {
        let size = CGSize(width: view.bounds.width - 32, height: AppMetrics.heroHeight)
        ArtworkCache.prefetch(venues, size: size)
    }
}

// MARK: - Filtering

private extension ExploreViewController {
    func venue(with id: UUID) -> Venue? {
        guard let index = venueIndex[id] else { return nil }
        return venues[index]
    }

    func rebuildIndex() {
        var map: [UUID: Int] = [:]
        map.reserveCapacity(venues.count)
        for (index, venue) in venues.enumerated() {
            map[venue.id] = index
        }
        venueIndex = map
    }

    var filteredIDs: [UUID] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return venues.compactMap { venue in
            if selectedCategory != .all, venue.category != selectedCategory {
                return nil
            }
            if query.isEmpty {
                return venue.id
            }
            let haystack = "\(venue.name) \(venue.cuisine) \(venue.neighborhood)"
            return haystack.localizedCaseInsensitiveContains(query) ? venue.id : nil
        }
    }

    func applySnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredIDs, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func reloadVenue(_ id: UUID) {
        var snapshot = dataSource.snapshot()
        guard snapshot.indexOfItem(id) != nil else { return }
        snapshot.reloadItems([id])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func toggleFavorite(id: UUID) {
        guard let index = venueIndex[id] else { return }
        venues[index].isFavorite.toggle()
        reloadVenue(id)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func toggleBookmark(id: UUID) {
        guard let index = venueIndex[id] else { return }
        venues[index].isBookmarked.toggle()
        reloadVenue(id)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func presentDeal(id: UUID) {
        guard let venue = venue(with: id), let deal = venue.deal else { return }
        let alert = UIAlertController(
            title: venue.name,
            message: "\(deal.discount)\n\(deal.detail)\n\(deal.validity)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func handleSearchChanged() {
        searchQuery = searchTextField.text ?? ""
        applySnapshot(animated: true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func clearSearch() {
        searchTextField.text = nil
        handleSearchChanged()
        dismissKeyboard()
    }

    @objc func handleNotifications() {
        bellDotView.isHidden = true
        presentSoon(title: "Notifications")
    }

    func presentSoon(title: String) {
        let alert = UIAlertController(title: title, message: "Coming soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ExploreViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryChipCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryChipCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.item]
        cell.configure(with: category, selected: category == selectedCategory)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categories[indexPath.item]
        if let cached = chipSizeCache[category] {
            return cached
        }
        let size = CategoryChipCell.size(for: category)
        chipSizeCache[category] = size
        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        applySnapshot(animated: true)
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

extension ExploreViewController: UITableViewDelegate, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
        openVenueDetail(id: id)
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let size = CGSize(width: view.bounds.width - 32, height: AppMetrics.heroHeight)
        let ids = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        let upcoming = ids.compactMap(venue(with:))
        ArtworkCache.prefetch(upcoming, size: size)
    }
}

private extension ExploreViewController {
    func openVenueDetail(id: UUID) {
        let storyboard = UIStoryboard(name: "VenueDetail", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? VenueDetailViewController else {
            return
        }
        controller.configure(venueID: id)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

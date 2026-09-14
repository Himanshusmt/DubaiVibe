import UIKit

final class ExploreViewController: UIViewController {

    @IBOutlet private weak var brandImageView: UIImageView!
    @IBOutlet private weak var taglineLabel: UILabel!
    @IBOutlet private weak var notificationButton: UIButton!
    @IBOutlet private weak var bellDotView: UIView!
    @IBOutlet private weak var locationPillView: UIView!
    @IBOutlet private weak var locationPinImageView: UIImageView!
    @IBOutlet private weak var locationChevronImageView: UIImageView!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var locationTitleLabel: UILabel!
    @IBOutlet private weak var searchContainerView: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var venueTableView: UITableView!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!

    private let viewModel: ExploreViewModel
    private let categories = VenueCategory.allCases

    private var selectedCategory: VenueCategory = .all
    private var searchQuery = ""
    private var chipSizeCache: [VenueCategory: CGSize] = [:]
    private var searchWorkItem: DispatchWorkItem?

    private var dataSource: UITableViewDiffableDataSource<Int, UUID>!

    private var lastContentOffset: CGFloat = 0
    private var headerShift: CGFloat = 0
    private var headerCollapseDistance: CGFloat = 0
    private var isAdjustingHeader = false

    required init?(coder: NSCoder) {
        self.viewModel = ExploreViewModel()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottom = AppMetrics.floatingTabPillSize.height
            + AppMetrics.floatingTabBottomInset(for: view)
            + 8
        if venueTableView.contentInset.bottom != bottom {
            venueTableView.contentInset.bottom = bottom
            venueTableView.verticalScrollIndicatorInsets.bottom = bottom
        }
        if headerShift == 0 {
            let distance = searchContainerView.frame.minY - view.safeAreaInsets.top
            if distance > 0 {
                headerCollapseDistance = distance
            }
        }
        guard !isAdjustingHeader else { return }
        if !canCollapseHeader(in: venueTableView), headerShift != 0 {
            applyHeaderShift(0, adjustsContentOffset: false)
        }
    }
}

// MARK: - Setup

private extension ExploreViewController {
    func configureHeader() {
        brandImageView.image = UIImage(named: "ExploreBrandLogo") ?? UIImage(named: "dubai vibe logo") ?? UIImage(named: "LaunchLogo")
        brandImageView.contentMode = .scaleAspectFit
        brandImageView.layer.cornerRadius = 14
        brandImageView.layer.cornerCurve = .continuous
        brandImageView.clipsToBounds = true
        brandImageView.accessibilityLabel = "Dubai Vibe"

        taglineLabel.attributedText = NSAttributedString(
            string: "DUBAI • EAT • DRINK • EXPLORE",
            attributes: [
                .font: AppTypography.font(.medium, size: 9.5),
                .foregroundColor: AppPalette.tagline,
                .kern: 1.9
            ]
        )

        notificationButton.setImage(UIImage(named: "ExploreBell"), for: .normal)
        notificationButton.tintColor = nil
        notificationButton.accessibilityLabel = "Notifications"
        notificationButton.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)

        bellDotView.backgroundColor = AppPalette.badgeRed
        bellDotView.layer.cornerRadius = 4.5
        bellDotView.layer.borderWidth = 1.5
        bellDotView.layer.borderColor = AppPalette.background.cgColor
        bellDotView.isUserInteractionEnabled = false

        locationPinImageView.image = UIImage(named: "ExplorePin")
        locationPinImageView.tintColor = nil
        locationPinImageView.contentMode = .scaleAspectFit

        locationChevronImageView.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        )
        locationChevronImageView.tintColor = AppPalette.primaryText

        locationTitleLabel.attributedText = NSAttributedString(
            string: "Dubai",
            attributes: [
                .font: AppTypography.font(.semibold, size: 14),
                .foregroundColor: AppPalette.primaryText,
                .kern: 0.35
            ]
        )

        locationPillView.backgroundColor = AppPalette.locationFill
        locationPillView.layer.cornerRadius = 15
        locationPillView.layer.cornerCurve = .continuous
        locationPillView.layer.borderWidth = 1
        locationPillView.layer.borderColor = AppPalette.locationBorder.cgColor

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

        let glass = UIImage(
            systemName: "magnifyingglass",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        )
        let icon = UIImageView(image: glass)
        icon.tintColor = AppPalette.searchPlaceholder
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 22, height: 22)

        let left = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 22))
        icon.center = left.center
        left.addSubview(icon)

        searchTextField.leftView = left
        searchTextField.leftViewMode = .always
        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = .clear
        searchTextField.font = AppTypography.font(.regular, size: 12)
        searchTextField.textColor = AppPalette.primaryText
        searchTextField.tintColor = AppPalette.gold
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search restaurants, bars, nightlife, beaches...",
            attributes: [
                .font: AppTypography.font(.regular, size: 12),
                .foregroundColor: AppPalette.searchPlaceholder
            ]
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
        done.setTitleTextAttributes([.font: AppTypography.font(.semibold, size: 16)], for: .normal)

        toolbar.items = [clear, UIBarButtonItem(systemItem: .flexibleSpace), done]
        toolbar.sizeToFit()
        return toolbar
    }

    func configureCategories() {
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = AppMetrics.chipGap
            layout.minimumLineSpacing = AppMetrics.chipGap
            layout.estimatedItemSize = .zero
            layout.sectionInset = UIEdgeInsets(top: 0, left: AppMetrics.screenGutter, bottom: 0, right: AppMetrics.screenGutter)
        }
        chipSizeCache.removeAll()
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
        let refresh = UIRefreshControl()
        refresh.tintColor = AppPalette.gold
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        venueTableView.refreshControl = refresh
        venueTableView.contentInset.bottom = AppMetrics.floatingTabPillSize.height
            + AppMetrics.floatingTabBottomInset(for: view)
            + 8
        venueTableView.verticalScrollIndicatorInsets.bottom = venueTableView.contentInset.bottom

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
            cell.onViewDeal = { [weak self] in self?.openVenueDetail(id: id) }
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        venueTableView.dataSource = dataSource
        venueTableView.delegate = self
    }

    func loadFeed() {
        viewModel.loadFeed { [weak self] result in
            self?.handleBusinessesResult(result, animated: false)
        }
    }

    func prefetchArtwork() {
        let size = CGSize(width: view.bounds.width - AppMetrics.cardGutter * 2, height: AppMetrics.heroHeight)
        ArtworkCache.prefetch(viewModel.venues, size: size)
        BusinessImageLoader.prefetch(viewModel.venues.compactMap(\.imageURL))
    }
}

// MARK: - Filtering

private extension ExploreViewController {
    func venue(with id: UUID) -> Venue? {
        viewModel.venue(with: id)
    }

    var filteredIDs: [UUID] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return viewModel.venues.compactMap { venue in
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

    func handleBusinessesResult(_ result: Result<BusinessListResponse, APIError>, animated: Bool) {
        venueTableView.refreshControl?.endRefreshing()
        switch result {
        case .success:
            applySnapshot(animated: animated)
            updateEmptyState()
            prefetchArtwork()
        case .failure(let error):
            applySnapshot(animated: false)
            updateEmptyState()
            showErrorPopup(error)
        }
    }

    func updateEmptyState() {
        if filteredIDs.isEmpty {
            let label = UILabel()
            label.text = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "No businesses yet"
                : "No matching businesses"
            label.font = AppTypography.font(.medium, size: 14)
            label.textColor = AppPalette.secondaryText
            label.textAlignment = .center
            venueTableView.backgroundView = label
        } else {
            venueTableView.backgroundView = nil
        }
    }

    func applySnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredIDs, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animated)
        updateEmptyState()
    }

    func reloadVenue(_ id: UUID) {
        var snapshot = dataSource.snapshot()
        guard snapshot.indexOfItem(id) != nil else { return }
        snapshot.reloadItems([id])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func toggleFavorite(id: UUID) {
        viewModel.toggleFavorite(id: id)
        reloadVenue(id)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func toggleBookmark(id: UUID) {
        viewModel.toggleBookmark(id: id)
        reloadVenue(id)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc func handleSearchChanged() {
        searchQuery = searchTextField.text ?? ""
        applySnapshot(animated: true)
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchWorkItem?.cancel()
            viewModel.loadFeed { [weak self] result in
                self?.handleBusinessesResult(result, animated: true)
            }
            return
        }
        scheduleSearch()
    }

    @objc func handleRefresh() {
        searchWorkItem?.cancel()
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            viewModel.loadFeed(showLoader: false) { [weak self] result in
                self?.handleBusinessesResult(result, animated: true)
            }
        } else {
            viewModel.search(trimmed, showLoader: false) { [weak self] result in
                self?.handleBusinessesResult(result, animated: true)
            }
        }
    }

    func scheduleSearch() {
        searchWorkItem?.cancel()
        let query = searchQuery
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.viewModel.search(query) { [weak self] result in
                self?.handleBusinessesResult(result, animated: true)
            }
        }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
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
        searchWorkItem?.cancel()
        viewModel.search(searchQuery) { [weak self] result in
            self?.handleBusinessesResult(result, animated: true)
        }
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = dataSource.snapshot().numberOfItems
        guard count > 0, indexPath.row >= count - 3 else { return }
        viewModel.loadMoreIfNeeded { [weak self] result in
            self?.handleBusinessesResult(result, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let size = CGSize(width: view.bounds.width - AppMetrics.cardGutter * 2, height: AppMetrics.heroHeight)
        let ids = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        let upcoming = ids.compactMap(venue(with:))
        ArtworkCache.prefetch(upcoming, size: size)
        BusinessImageLoader.prefetch(upcoming.compactMap(\.imageURL))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === venueTableView, !isAdjustingHeader else { return }

        let offset = scrollView.contentOffset.y
        let minOffset = -scrollView.adjustedContentInset.top
        let maxOffset = max(minOffset, maxContentOffset(in: scrollView))

        guard canCollapseHeader(in: scrollView) else {
            lastContentOffset = minOffset
            applyHeaderShift(0, adjustsContentOffset: false)
            return
        }

        if offset < minOffset || offset > maxOffset {
            lastContentOffset = min(max(offset, minOffset), maxOffset)
            if offset < minOffset {
                applyHeaderShift(0, adjustsContentOffset: false)
            }
            return
        }

        let delta = offset - lastContentOffset
        lastContentOffset = offset

        if offset <= minOffset {
            applyHeaderShift(0, adjustsContentOffset: false)
            return
        }

        guard headerCollapseDistance > 0, abs(delta) > 0.5 else { return }
        applyHeaderShift(min(max(headerShift + delta, 0), headerCollapseDistance))
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        guard scrollView === venueTableView else { return }
        applyHeaderShift(0, adjustsContentOffset: false)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === venueTableView, !decelerate else { return }
        settleHeaderIfNeeded(in: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === venueTableView else { return }
        settleHeaderIfNeeded(in: scrollView)
    }
}

private extension ExploreViewController {
    func maxContentOffset(in scrollView: UIScrollView) -> CGFloat {
        scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
    }

    func canCollapseHeader(in scrollView: UIScrollView) -> Bool {
        guard headerCollapseDistance > 0, scrollView.bounds.height > 0 else { return false }
        let expandedTableHeight = scrollView.bounds.height - headerShift
        let contentHeight = scrollView.contentSize.height
            + scrollView.adjustedContentInset.top
            + scrollView.adjustedContentInset.bottom
        return contentHeight > expandedTableHeight + headerCollapseDistance + 1
    }

    func settleHeaderIfNeeded(in scrollView: UIScrollView) {
        guard !isAdjustingHeader else { return }
        if !canCollapseHeader(in: scrollView) {
            applyHeaderShift(0, adjustsContentOffset: false)
            return
        }
        if scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top {
            applyHeaderShift(0, adjustsContentOffset: false)
        }
    }

    func applyHeaderShift(_ newShift: CGFloat, adjustsContentOffset: Bool = true) {
        let diff = newShift - headerShift
        guard abs(diff) > 0.01 else { return }

        headerShift = newShift
        isAdjustingHeader = true
        headerTopConstraint.constant = -headerShift
        view.layoutIfNeeded()
        if adjustsContentOffset {
            venueTableView.contentOffset.y -= diff
        }
        lastContentOffset = venueTableView.contentOffset.y
        isAdjustingHeader = false

        let progress = headerCollapseDistance == 0 ? 0 : headerShift / headerCollapseDistance
        let alpha = max(0, 1 - progress * 2)
        brandImageView.superview?.alpha = alpha
        locationPillView.alpha = alpha
        brandImageView.superview?.isUserInteractionEnabled = alpha > 0.05
        locationPillView.isUserInteractionEnabled = alpha > 0.05
    }

    func openVenueDetail(id: UUID) {
        guard let venue = venue(with: id) else { return }
        let storyboard = UIStoryboard(name: "VenueDetail", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? VenueDetailViewController else {
            return
        }
        controller.configure(businessID: venue.resolvedBusinessID)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

import SDWebImage
import UIKit

final class VenuePhotosViewController: UIViewController {
    private enum Metric {
        static let columns: CGFloat = 3
        static let spacing: CGFloat = 2
        static let headerHeight: CGFloat = 52
    }

    private let venueName: String
    private let imageURLs: [URL]

    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Metric.spacing
        layout.minimumLineSpacing = Metric.spacing
        layout.sectionInset = .zero
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = AppPalette.background
        view.alwaysBounceVertical = true
        view.contentInsetAdjustmentBehavior = .never
        view.register(VenuePhotoCell.self, forCellWithReuseIdentifier: VenuePhotoCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    init(venueName: String, imageURLs: [URL] = VenueDemoPhotos.demoURLs) {
        self.venueName = venueName
        self.imageURLs = imageURLs
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureHeader()
        configureCollection()
        prefetchVisible()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottom = view.safeAreaInsets.bottom + 8
        if collectionView.contentInset.bottom != bottom {
            collectionView.contentInset.bottom = bottom
            collectionView.verticalScrollIndicatorInsets.bottom = bottom
        }
    }
}

private extension VenuePhotosViewController {
    func configureHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = AppPalette.background
        view.addSubview(headerView)

        let chevron = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevron), for: .normal)
        backButton.tintColor = AppPalette.gold
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        backButton.accessibilityLabel = L10n.back
        headerView.addSubview(backButton)

        titleLabel.text = L10n.photosCount(imageURLs.count)
        titleLabel.font = AppTypography.font(.semibold, size: 17)
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        let subtitle = UILabel()
        subtitle.text = venueName
        subtitle.font = AppTypography.font(.regular, size: 12)
        subtitle.textColor = AppPalette.secondaryText
        subtitle.textAlignment = .center
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(subtitle)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Metric.headerHeight + 18),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -52),

            subtitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subtitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 52),
            subtitle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -52)
        ])
    }

    func configureCollection() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func prefetchVisible() {
        SDWebImagePrefetcher.shared.prefetchURLs(imageURLs)
    }

    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    func openPreview(at index: Int) {
        let preview = VenuePhotoPreviewViewController(imageURLs: imageURLs, startIndex: index)
        preview.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(preview, animated: true)
    }
}

extension VenuePhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VenuePhotoCell.reuseIdentifier,
            for: indexPath
        ) as? VenuePhotoCell else {
            return UICollectionViewCell()
        }
        cell.configure(url: imageURLs[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = Metric.spacing * (Metric.columns - 1)
        let side = floor((collectionView.bounds.width - totalSpacing) / Metric.columns)
        return CGSize(width: max(side, 1), height: max(side, 1))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openPreview(at: indexPath.item)
    }
}

private final class VenuePhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "VenuePhotoCell"

    private let imageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = AppPalette.surface
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        spinner.color = AppPalette.gold
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        spinner.stopAnimating()
    }

    func configure(url: URL) {
        spinner.startAnimating()
        imageView.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: [.retryFailed, .highPriority, .scaleDownLargeImages]
        ) { [weak self] _, _, _, _ in
            self?.spinner.stopAnimating()
        }
    }
}

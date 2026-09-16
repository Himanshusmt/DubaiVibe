import Combine
import UIKit

/// Thin chrome helper so cards can be featured from the list.
@IBDesignable
final class NotificationCardView: UIView {
    @IBInspectable var isFeatured: Bool = false {
        didSet { applyChrome() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyChrome()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyChrome()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyChrome()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyChrome()
    }

    private func applyChrome() {
        backgroundColor = AppPalette.surface
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = true
        if isFeatured {
            layer.borderWidth = 1
            layer.borderColor = AppPalette.gold.withAlphaComponent(0.55).cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
}

final class NotificationsViewController: UIViewController {
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var brandImageView: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!

    private let viewModel = NotificationsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppPalette.secondaryText
        label.font = AppTypography.font(.medium, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyChrome()
        configureTable()
        bindViewModel()
        applyLocalizedStoryboardCopy()
        viewModel.load()
    }

    private func applyChrome() {
        view.backgroundColor = AppPalette.background

        backButton.backgroundColor = AppPalette.surfaceRaised
        backButton.tintColor = .white
        backButton.layer.cornerRadius = 18
        backButton.clipsToBounds = true

        brandImageView.image = UIImage(named: "ExploreBrandLogo")
            ?? UIImage(named: "dubai vibe logo")
            ?? UIImage(named: "LaunchLogo")
        brandImageView.layer.cornerRadius = 10
        brandImageView.layer.cornerCurve = .continuous
        brandImageView.clipsToBounds = true
        brandImageView.layer.borderWidth = 1
        brandImageView.layer.borderColor = AppPalette.gold.withAlphaComponent(0.7).cgColor

        titleLabel?.text = L10n.notifications
        titleLabel?.textColor = AppPalette.primaryText
    }

    private func configureTable() {
        tableView.backgroundColor = AppPalette.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.sectionHeaderTopPadding = 8
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)

        refreshControl.tintColor = AppPalette.gold
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        tableView.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.frameLayoutGuide.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.frameLayoutGuide.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tableView.frameLayoutGuide.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: tableView.frameLayoutGuide.trailingAnchor, constant: -32)
        ])
        emptyLabel.isHidden = true
    }

    private func bindViewModel() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if !loading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self, !message.isEmpty, self.viewModel.isEmpty else { return }
                self.emptyLabel.text = message
                self.emptyLabel.isHidden = false
            }
            .store(in: &cancellables)
    }

    private func updateEmptyState() {
        let showEmpty = viewModel.isEmpty && !viewModel.isLoading
        emptyLabel.isHidden = !showEmpty
        if showEmpty {
            emptyLabel.text = viewModel.errorMessage.isEmpty
                ? L10n.notificationsEmpty
                : viewModel.errorMessage
        }
    }

    @objc private func handleRefresh() {
        viewModel.load(showLoader: false)
    }

    @IBAction private func handleBack() {
        if let nav = navigationController, nav.viewControllers.first !== self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    static func open(from presenter: UIViewController) {
        let storyboard = UIStoryboard(name: "Notifications", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? NotificationsViewController else {
            return
        }
        controller.hidesBottomBarWhenPushed = true
        if let nav = presenter.navigationController {
            nav.pushViewController(controller, animated: true)
        } else {
            controller.modalPresentationStyle = .fullScreen
            presenter.present(controller, animated: true)
        }
    }
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let entry = viewModel.sections[section]
        let container = UIView()
        container.backgroundColor = AppPalette.background

        let title = UILabel()
        title.text = entry.section.title
        title.font = AppTypography.font(.semibold, size: 12)
        title.textColor = AppPalette.gold
        title.translatesAutoresizingMaskIntoConstraints = false

        let badge = UILabel()
        badge.font = AppTypography.font(.medium, size: 12)
        badge.textColor = AppPalette.secondaryText
        badge.translatesAutoresizingMaskIntoConstraints = false
        if case .today = entry.section {
            let unread = entry.items.filter(\.isUnread).count
            badge.text = unread > 0 ? L10n.notificationsNewCountFormat(unread) : nil
        }
        badge.isHidden = (badge.text ?? "").isEmpty

        container.addSubview(title)
        container.addSubview(badge)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            badge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            badge.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            title.trailingAnchor.constraint(lessThanOrEqualTo: badge.leadingAnchor, constant: -8)
        ])
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseID, for: indexPath) as! NotificationCell
        if let item = viewModel.item(at: indexPath) {
            cell.configure(item)
            cell.onCTA = { [weak self] in
                self?.handleSelect(at: indexPath)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelect(at: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSection = viewModel.sections.count - 1
        guard lastSection >= 0,
              indexPath.section == lastSection,
              indexPath.row >= viewModel.sections[lastSection].items.count - 3 else {
            return
        }
        viewModel.loadMoreIfNeeded()
    }

    private func handleSelect(at indexPath: IndexPath) {
        guard let item = viewModel.item(at: indexPath) else { return }
        viewModel.markRead(id: item.id)
        if let raw = item.actionURL?.trimmingCharacters(in: .whitespacesAndNewlines),
           let url = URL(string: raw),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

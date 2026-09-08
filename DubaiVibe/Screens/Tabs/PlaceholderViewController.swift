import UIKit

final class PlaceholderViewController: UIViewController {
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel?.textColor = AppPalette.primaryText
        titleLabel?.text = tabBarItem.title ?? ""
        iconView?.tintColor = AppPalette.gold
        iconView?.contentMode = .scaleAspectFit
        iconView?.image = tabBarItem.image?.withRenderingMode(.alwaysTemplate)
    }
}

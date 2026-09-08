import UIKit

final class VenueDetailSegmentCell: UICollectionViewCell {
    static let reuseIdentifier = "VenueDetailSegmentCell"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var underline: UIView!
    @IBOutlet private weak var underlineWidth: NSLayoutConstraint!

    func configure(title: String, selected: Bool) {
        titleLabel.text = title
        titleLabel.textColor = selected ? AppPalette.gold : AppPalette.primaryText
        underline.isHidden = !selected
        let textWidth = (title as NSString).size(withAttributes: [.font: titleLabel.font as Any]).width
        underlineWidth.constant = ceil(textWidth) + 6
    }
}

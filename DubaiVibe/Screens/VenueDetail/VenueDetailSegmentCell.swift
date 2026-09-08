import UIKit

final class VenueDetailSegmentCell: UICollectionViewCell {
    static let reuseIdentifier = "VenueDetailSegmentCell"

    private let titleLabel = UILabel()
    private let underline = UIView()
    private lazy var underlineWidth = underline.widthAnchor.constraint(equalToConstant: 0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        underline.backgroundColor = AppPalette.gold
        underline.layer.cornerRadius = 1.25
        underline.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(underline)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),

            underline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 9),
            underline.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            underlineWidth,
            underline.heightAnchor.constraint(equalToConstant: 2.5)
        ])
    }

    func configure(title: String, selected: Bool) {
        titleLabel.text = title
        titleLabel.textColor = selected ? AppPalette.gold : AppPalette.primaryText
        underline.isHidden = !selected
        // The rule tracks the word, not the equal-width cell.
        let textWidth = (title as NSString).size(withAttributes: [.font: titleLabel.font as Any]).width
        underlineWidth.constant = ceil(textWidth) + 6
    }
}

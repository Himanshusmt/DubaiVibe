import UIKit

enum AuthMetrics {
    static let gutter: CGFloat = 24
    static let fieldHeight: CGFloat = 56
    static let buttonHeight: CGFloat = 54
    static let corner: CGFloat = 14
    static let logoSize: CGFloat = 72
    static let compactLogoSize: CGFloat = 44
}

// MARK: - Logo

final class AuthLogoView: UIView {
    private let imageView = UIImageView()
    private let borderView = UIView()

    init(compact: Bool = false) {
        super.init(frame: .zero)
        let size = compact ? AuthMetrics.compactLogoSize : AuthMetrics.logoSize
        translatesAutoresizingMaskIntoConstraints = false

        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.layer.cornerRadius = 10
        borderView.layer.borderWidth = 1.5
        borderView.layer.borderColor = AppPalette.gold.cgColor
        borderView.backgroundColor = UIColor(hex: 0x0A0A0A)
        borderView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "LaunchLogo")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        addSubview(borderView)
        borderView.addSubview(imageView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            borderView.topAnchor.constraint(equalTo: topAnchor),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 6),
            imageView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 6),
            imageView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -6),
            imageView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Top bar

final class AuthTopBar: UIView {
    let backButton = UIButton(type: .system)
    let helpButton = UIButton(type: .system)
    private let logo = AuthLogoView(compact: true)

    var showsHelp: Bool = false {
        didSet { helpButton.isHidden = !showsHelp }
    }

    var showsBack: Bool = true {
        didSet { backButton.isHidden = !showsBack }
    }

    var showsLogo: Bool = true {
        didSet { logo.isHidden = !showsLogo }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        let chevron = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        backButton.setImage(chevron, for: .normal)
        backButton.tintColor = AppPalette.primaryText

        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.setTitle("Help", for: .normal)
        helpButton.setTitleColor(AppPalette.gold, for: .normal)
        helpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        helpButton.isHidden = true

        addSubview(backButton)
        addSubview(logo)
        addSubview(helpButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: centerYAnchor),

            helpButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            helpButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Dark field

final class AuthDarkField: UIView, UITextFieldDelegate {
    let textField = UITextField()

    var placeholder: String? {
        get { textField.placeholder }
        set {
            textField.attributedPlaceholder = NSAttributedString(
                string: newValue ?? "",
                attributes: [.foregroundColor: AppPalette.secondaryText]
            )
        }
    }

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: AuthMetrics.fieldHeight)
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppPalette.surface
        layer.cornerRadius = AuthMetrics.corner
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppPalette.separator.cgColor

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = AppPalette.primaryText
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = AppPalette.gold
        textField.delegate = self
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        addSubview(textField)
        var constraints: [NSLayoutConstraint] = [
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        let hasHeight = self.constraints.contains {
            $0.firstAttribute == .height && $0.secondItem == nil
        }
        if !hasHeight {
            constraints.append(heightAnchor.constraint(equalToConstant: AuthMetrics.fieldHeight))
        }
        NSLayoutConstraint.activate(constraints)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderColor = AppPalette.gold.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = AppPalette.separator.cgColor
    }
}

// MARK: - Outlined button

final class AuthOutlinedButton: UIButton {
    init(title: String, systemImage: String?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = AppPalette.primaryText
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 16, weight: .medium)
            return out
        }
        if let systemImage {
            config.image = UIImage(systemName: systemImage)
            config.imagePadding = 10
            config.imagePlacement = .leading
        }
        configuration = config
        backgroundColor = .clear
        layer.cornerRadius = AuthMetrics.corner
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppPalette.separator.cgColor
        heightAnchor.constraint(equalToConstant: AuthMetrics.buttonHeight).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Phone row

final class AuthPhoneInputView: UIView {
    let countryButton = UIButton(type: .system)
    let flagImageView = UIImageView()
    let dialCodeLabel = UILabel()
    let phoneField = UITextField()

    var dialCode: String = "+971" {
        didSet { dialCodeLabel.text = dialCode }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppPalette.surface
        layer.cornerRadius = AuthMetrics.corner
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppPalette.separator.cgColor

        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        flagImageView.contentMode = .scaleAspectFit
        flagImageView.image = UIImage(
            named: "assets.bundle/AE.png",
            in: Bundle(for: TDCountryPicker.self),
            compatibleWith: nil
        )

        dialCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        dialCodeLabel.text = dialCode
        dialCodeLabel.textColor = AppPalette.primaryText
        dialCodeLabel.font = .systemFont(ofSize: 16, weight: .medium)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = AppPalette.secondaryText
        chevron.contentMode = .scaleAspectFit

        countryButton.translatesAutoresizingMaskIntoConstraints = false

        phoneField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.keyboardType = .phonePad
        phoneField.textColor = AppPalette.primaryText
        phoneField.tintColor = AppPalette.gold
        phoneField.font = .systemFont(ofSize: 16, weight: .regular)
        phoneField.attributedPlaceholder = NSAttributedString(
            string: "50 123 4567",
            attributes: [.foregroundColor: AppPalette.secondaryText]
        )

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = AppPalette.separator

        addSubview(flagImageView)
        addSubview(dialCodeLabel)
        addSubview(chevron)
        addSubview(countryButton)
        addSubview(divider)
        addSubview(phoneField)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: AuthMetrics.fieldHeight),

            flagImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            flagImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 22),
            flagImageView.heightAnchor.constraint(equalToConstant: 16),

            dialCodeLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 8),
            dialCodeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevron.leadingAnchor.constraint(equalTo: dialCodeLabel.trailingAnchor, constant: 4),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12),

            countryButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            countryButton.topAnchor.constraint(equalTo: topAnchor),
            countryButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            countryButton.trailingAnchor.constraint(equalTo: chevron.trailingAnchor, constant: 8),

            divider.leadingAnchor.constraint(equalTo: countryButton.trailingAnchor),
            divider.centerYAnchor.constraint(equalTo: centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 28),

            phoneField.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 12),
            phoneField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            phoneField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Success rays

final class AuthRaysView: UIView {
    override class var layerClass: AnyClass { CAShapeLayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let shape = layer as? CAShapeLayer else { return }
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let inner: CGFloat = 70
        let outer: CGFloat = 100
        let count = 16
        for i in 0..<count {
            let angle = (CGFloat(i) / CGFloat(count)) * (.pi * 2)
            path.move(to: CGPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner))
            path.addLine(to: CGPoint(x: center.x + cos(angle) * outer, y: center.y + sin(angle) * outer))
        }
        shape.path = path.cgPath
        shape.strokeColor = AppPalette.gold.cgColor
        shape.lineWidth = 3
        shape.lineCap = .round
        shape.fillColor = UIColor.clear.cgColor
    }
}

// MARK: - OTP

protocol AuthOTPViewDelegate: AnyObject {
    func authOTPViewDidComplete(_ code: String)
}

final class AuthOTPView: UIView, UITextFieldDelegate {
    weak var delegate: AuthOTPViewDelegate?
    private let count = 6
    private var boxes: [UILabel] = []
    private let hiddenField = UITextField()
    private let caretView = UIView()
    private var caretBlinkTimer: Timer?

    var code: String {
        hiddenField.text ?? ""
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        caretBlinkTimer?.invalidate()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        boxes = (0..<count).map { _ in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 22, weight: .semibold)
            label.textColor = AppPalette.primaryText
            label.backgroundColor = AppPalette.surface
            label.layer.cornerRadius = 12
            label.layer.cornerCurve = .continuous
            label.layer.borderWidth = 1
            label.layer.borderColor = AppPalette.separator.cgColor
            label.clipsToBounds = true
            return label
        }

        let stack = UIStackView(arrangedSubviews: boxes)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10

        hiddenField.translatesAutoresizingMaskIntoConstraints = false
        hiddenField.keyboardType = .numberPad
        hiddenField.textContentType = .oneTimeCode
        hiddenField.tintColor = .clear
        hiddenField.textColor = .clear
        hiddenField.delegate = self
        hiddenField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        caretView.backgroundColor = AppPalette.gold
        caretView.isHidden = true
        caretView.isUserInteractionEnabled = false

        addSubview(stack)
        addSubview(caretView)
        addSubview(hiddenField)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            hiddenField.topAnchor.constraint(equalTo: topAnchor),
            hiddenField.leadingAnchor.constraint(equalTo: leadingAnchor),
            hiddenField.trailingAnchor.constraint(equalTo: trailingAnchor),
            hiddenField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(focus))
        addGestureRecognizer(tap)
        updateBorders()
        updateCaret()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCaret()
    }

    @objc func focus() {
        hiddenField.becomeFirstResponder()
        updateBorders()
        updateCaret()
    }

    @objc private func textChanged() {
        let filtered = String((hiddenField.text ?? "").filter(\.isNumber).prefix(count))
        hiddenField.text = filtered
        for (index, box) in boxes.enumerated() {
            if index < filtered.count {
                let i = filtered.index(filtered.startIndex, offsetBy: index)
                box.text = String(filtered[i])
            } else {
                box.text = ""
            }
        }
        updateBorders()
        updateCaret()
        if filtered.count == count {
            delegate?.authOTPViewDidComplete(filtered)
        }
    }

    private func updateBorders() {
        let length = (hiddenField.text ?? "").count
        for (index, box) in boxes.enumerated() {
            let active = index == length || (length == count && index == count - 1)
            box.layer.borderColor = active && hiddenField.isFirstResponder
                ? AppPalette.gold.cgColor
                : AppPalette.separator.cgColor
        }
    }

    private func updateCaret() {
        let length = (hiddenField.text ?? "").count
        let shouldShow = hiddenField.isFirstResponder && length < count && length < boxes.count
        caretView.isHidden = !shouldShow
        guard shouldShow else {
            stopCaretBlink()
            return
        }

        let box = boxes[length]
        let boxFrame = box.convert(box.bounds, to: self)
        let caretWidth: CGFloat = 2
        let caretHeight: CGFloat = 22
        caretView.frame = CGRect(
            x: boxFrame.midX - caretWidth / 2,
            y: boxFrame.midY - caretHeight / 2,
            width: caretWidth,
            height: caretHeight
        )
        caretView.alpha = 1
        startCaretBlink()
    }

    private func startCaretBlink() {
        guard caretBlinkTimer == nil else { return }
        caretView.alpha = 1
        caretBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, !self.caretView.isHidden else { return }
            self.caretView.alpha = self.caretView.alpha > 0.5 ? 0 : 1
        }
    }

    private func stopCaretBlink() {
        caretBlinkTimer?.invalidate()
        caretBlinkTimer = nil
        caretView.alpha = 1
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateBorders()
        updateCaret()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateBorders()
        updateCaret()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        guard let range = Range(range, in: current) else { return false }
        let next = current.replacingCharacters(in: range, with: string)
        let digits = next.filter(\.isNumber)
        return digits.count <= count
    }
}

// MARK: - Helpers

extension UIViewController {
    func authDismissKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func makeAuthTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = AppPalette.primaryText
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        return label
    }

    func makeAuthSubtitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = AppPalette.secondaryText
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }
}

extension GoldGradientButton {
    static func authPrimary(title: String, showsChevron: Bool = false) -> GoldGradientButton {
        let button = GoldGradientButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(AppPalette.onGold, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        if showsChevron {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
            let image = UIImage(systemName: "chevron.right", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = AppPalette.onGold
            button.semanticContentAttribute = .forceRightToLeft
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
        button.setTitle(title, for: .normal)
        button.heightAnchor.constraint(equalToConstant: AuthMetrics.buttonHeight).isActive = true
        return button
    }
}

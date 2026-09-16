import Combine
import UIKit

final class EnterVenueCodeViewController: UIViewController {
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var crownBoxView: UIView!
    @IBOutlet private weak var passcodePanelView: UIView!
    @IBOutlet private weak var codeFieldContainer: UIView!
    @IBOutlet private weak var codeTextField: UITextField!
    @IBOutlet private weak var vipBadgeView: UIView!
    @IBOutlet private weak var vipBadgeLabel: UILabel!
    @IBOutlet private weak var doneButton: GoldGradientButton!

    /// Coupon / offer id from `business.coupons[].id`.
    var offerId: String = ""
    var onUnlocked: ((UnlockOfferData) -> Void)?

    private var isSubmitting = false
    private let vipGradient = CAGradientLayer()
    private let keyboardGap: CGFloat = 16
    private var unlockCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyChrome()
        applyLocalizedStoryboardCopy()
        observeKeyboard()
    }

    deinit {
        unlockCancellable?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vipGradient.frame = vipBadgeView.bounds
        vipGradient.cornerRadius = vipBadgeView.bounds.height / 2
        applyDoneCapsuleRadius()
    }

    private func applyChrome() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.62)

        styleBordered(cardView, radius: 22, border: AppPalette.gold.withAlphaComponent(0.55), clips: false)
        styleBordered(crownBoxView, radius: 18, border: AppPalette.gold.withAlphaComponent(0.75), clips: true)
        styleBordered(passcodePanelView, radius: 14, border: AppPalette.gold.withAlphaComponent(0.45), clips: true)
        styleBordered(codeFieldContainer, radius: 12, border: AppPalette.gold.withAlphaComponent(0.55), clips: true)

        styleVIPBadge()
        applyDoneCapsuleRadius()
        doneButton.setTitle(L10n.done, for: .normal)
        doneButton.setTitleColor(AppPalette.onGold, for: .normal)

        codeTextField.attributedPlaceholder = NSAttributedString(
            string: L10n.enterVenueCodePlaceholder,
            attributes: [.foregroundColor: AppPalette.searchPlaceholder]
        )
        codeTextField.textColor = AppPalette.primaryText
        codeTextField.tintColor = AppPalette.gold
        codeTextField.autocapitalizationType = .allCharacters
        codeTextField.returnKeyType = .done
        codeTextField.delegate = self
    }

    private func styleVIPBadge() {
        vipBadgeLabel.text = "VIP"
        vipBadgeLabel.font = UIFont.systemFont(ofSize: 9, weight: .heavy)
        vipBadgeLabel.textColor = .black
        vipBadgeLabel.backgroundColor = .clear

        vipBadgeView.backgroundColor = .clear
        vipBadgeView.layer.cornerRadius = 9
        vipBadgeView.layer.cornerCurve = .continuous
        vipBadgeView.clipsToBounds = true
        vipBadgeView.layer.borderWidth = 0.8
        vipBadgeView.layer.borderColor = UIColor(hex: 0xFCE19B).withAlphaComponent(0.9).cgColor

        vipGradient.colors = [
            UIColor(hex: 0xFFC857).cgColor,
            UIColor(hex: 0xF0A12B).cgColor,
            UIColor(hex: 0xD4850F).cgColor
        ]
        vipGradient.locations = [0, 0.55, 1]
        vipGradient.startPoint = CGPoint(x: 0, y: 0.5)
        vipGradient.endPoint = CGPoint(x: 1, y: 0.5)
        if vipGradient.superlayer == nil {
            vipBadgeView.layer.insertSublayer(vipGradient, at: 0)
        }
    }

    private func applyDoneCapsuleRadius() {
        let radius = 14.0
        guard radius > 0 else { return }
        doneButton.layer.cornerRadius = radius
        doneButton.layer.cornerCurve = .continuous
        doneButton.clipsToBounds = true
    }

    private func styleBordered(_ view: UIView, radius: CGFloat, border: UIColor, clips: Bool) {
        view.layer.cornerRadius = radius
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.layer.borderColor = border.cgColor
        view.clipsToBounds = clips
    }

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChange(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleKeyboardFrameChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        let keyboardInView = view.convert(endFrame, from: nil)
        let isHiding = notification.name == UIResponder.keyboardWillHideNotification
            || keyboardInView.minY >= view.bounds.maxY - 1

        let offset: CGFloat
        if isHiding {
            offset = 0
        } else {
            // Measure from the resting card position so repeated keyboard updates don't stack.
            let currentLift = cardView.transform.ty
            let doneBottom = doneButton.convert(doneButton.bounds, to: view).maxY - currentLift
            let overlap = doneBottom + keyboardGap - keyboardInView.minY
            let restingTop = cardView.frame.minY - currentLift
            let maxLift = max(0, restingTop - view.safeAreaInsets.top - 12)
            offset = min(max(0, overlap), maxLift)
        }

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.cardView.transform = offset > 0
                ? CGAffineTransform(translationX: 0, y: -offset)
                : .identity
        }
    }

    @IBAction private func handleClose() {
        guard !isSubmitting else { return }
        unlockCancellable?.cancel()
        dismiss(animated: true)
    }

    @IBAction private func handleDone() {
        guard !isSubmitting else { return }
        let unlockKey = (codeTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !unlockKey.isEmpty else {
            codeFieldContainer.shakeForValidation()
            return
        }

        let offerId = self.offerId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !offerId.isEmpty else {
            showAnimatedAlert(
                title: L10n.unlockDeal,
                message: L10n.unlockOfferMissing,
                style: .warning
            )
            return
        }

        isSubmitting = true
        doneButton.isEnabled = false
        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        unlockCancellable?.cancel()
        unlockCancellable = BusinessAPI.unlockOffer(
            offerId: offerId,
            unlockKey: unlockKey,
            showLoader: true
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            if case .failure(let error) = completion {
                self.resetSubmittingState()
                self.codeFieldContainer.shakeForValidation()
                self.showAnimatedAlert(
                    title: L10n.unlockDeal,
                    message: error.localizedDescription,
                    style: .warning
                )
            }
        } receiveValue: { [weak self] (response: UnlockOfferResponse) in
            guard let self else { return }
            guard let data = response.resolvedData, !data.resolvedCode.isEmpty else {
                self.resetSubmittingState()
                self.codeFieldContainer.shakeForValidation()
                self.showAnimatedAlert(
                    title: L10n.unlockDeal,
                    message: response.message ?? L10n.unlockOfferFailed,
                    style: .warning
                )
                return
            }

            self.doneButton.setTitle(L10n.enterCodeDone, for: .normal)
            UIView.animate(withDuration: 0.18) {
                self.doneButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            } completion: { _ in
                UIView.animate(withDuration: 0.18) {
                    self.doneButton.transform = .identity
                }
            }

            let onUnlocked = self.onUnlocked
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.dismiss(animated: true) {
                    onUnlocked?(data)
                }
            }
        }
    }

    private func resetSubmittingState() {
        isSubmitting = false
        doneButton.isEnabled = true
        doneButton.setTitle(L10n.done, for: .normal)
    }
}

extension EnterVenueCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleDone()
        return true
    }
}

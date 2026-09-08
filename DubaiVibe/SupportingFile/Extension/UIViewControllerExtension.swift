////
////  UIViewControllerExtension.swift
////  MyGuardianLink
////
////  Created by Aasif on 11/06/26.
////
//
//import Foundation
//import UIKit
//
//
//extension Locale {
//
//    static var currentCountryISO: String {
//        return (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
//    }
//
//}
//
//enum CountryHelper {
//
//    private static let picker = TDCountryPicker()
//    
//    static let currentISO = "US"
//    
////    static var currentISO: String {
////        Locale.currentCountryISO
////    }
//
//    static var currentDialCode: String {
//        picker.getDialCode(countryCode: currentISO) ?? "+1"
//    }
//
//    static var currentFlag: UIImage? {
//        picker.getFlag(countryCode: currentISO)
//    }
//}
//
//extension UIViewController {
//    
//    func formatUSPhone(_ number: String) -> String {
//        
//        let digits = number.filter(\.isNumber)
//        
//        guard digits.count == 10 else {
//            return number
//        }
//        
//        let areaCode = digits.prefix(3)
//        let prefix = digits.dropFirst(3).prefix(3)
//        let lineNumber = digits.suffix(4)
//        
//        return "(\(areaCode)) \(prefix)-\(lineNumber)"
//    }
//    
//    func showToast(message: String,
//                   duration: TimeInterval = 2.0) {
//        
//        let toastLabel = UILabel()
//        
//        toastLabel.text = message
//        toastLabel.textColor = .white
//        toastLabel.textAlignment = .center
//        toastLabel.font = UIFont.systemFont(ofSize: 14)
//        toastLabel.numberOfLines = 0
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        toastLabel.layer.cornerRadius = 10
//        toastLabel.clipsToBounds = true
//        
//        let maxWidth = view.frame.width * 0.8
//        let textSize = toastLabel.sizeThatFits(
//            CGSize(width: maxWidth - 20,
//                   height: CGFloat.greatestFiniteMagnitude)
//        )
//        
//        toastLabel.frame = CGRect(
//            x: (view.frame.width - (textSize.width + 20)) / 2,
//            y: view.frame.height - 120,
//            width: textSize.width + 20,
//            height: textSize.height + 16
//        )
//        
//        toastLabel.alpha = 0
//        view.addSubview(toastLabel)
//        
//        UIView.animate(withDuration: 0.3) {
//            toastLabel.alpha = 1
//        } completion: { _ in
//            UIView.animate(withDuration: 0.3,
//                           delay: duration,
//                           options: .curveEaseOut) {
//                toastLabel.alpha = 0
//            } completion: { _ in
//                toastLabel.removeFromSuperview()
//            }
//        }
//    }
//
//    /// Dark pill toast with app logo — matches logout success design.
//    func showBrandedBottomToast(message: String,
//                                iconName: String = "Welcome_logo",
//                                duration: TimeInterval = 2.8) {
//        let toastTag = 9_919_191
//        view.viewWithTag(toastTag)?.removeFromSuperview()
//
//        let container = UIView()
//        container.tag = toastTag
//        container.backgroundColor = UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1)
//        container.layer.cornerRadius = 12
//        container.clipsToBounds = false
//        container.layer.shadowColor = UIColor.black.cgColor
//        container.layer.shadowOpacity = 0.22
//        container.layer.shadowOffset = CGSize(width: 0, height: 4)
//        container.layer.shadowRadius = 10
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.alpha = 0
//        container.transform = CGAffineTransform(translationX: 0, y: 12)
//
//        let iconView = UIImageView(image: UIImage(named: iconName))
//        iconView.contentMode = .scaleAspectFill
//        iconView.clipsToBounds = true
//        iconView.layer.cornerRadius = 8
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//
//        let label = UILabel()
//        label.text = message
//        label.textColor = UIColor(white: 0.6, alpha: 1)
//        label.font = .systemFont(ofSize: 15, weight: .medium)
//        label.numberOfLines = 1
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        let stack = UIStackView(arrangedSubviews: [iconView, label])
//        stack.axis = .horizontal
//        stack.alignment = .center
//        stack.spacing = 12
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        container.addSubview(stack)
//        view.addSubview(container)
//
//        NSLayoutConstraint.activate([
//            iconView.widthAnchor.constraint(equalToConstant: 32),
//            iconView.heightAnchor.constraint(equalToConstant: 32),
//
//            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
//            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
//            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
//            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
//
//            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            container.bottomAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
//                constant: -20
//            ),
//            container.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.92)
//        ])
//
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
//            container.alpha = 1
//            container.transform = .identity
//        } completion: { _ in
//            UIView.animate(
//                withDuration: 0.3,
//                delay: duration,
//                options: .curveEaseIn
//            ) {
//                container.alpha = 0
//                container.transform = CGAffineTransform(translationX: 0, y: 8)
//            } completion: { _ in
//                container.removeFromSuperview()
//            }
//        }
//    }
//    
//    func setupView(_ view: UIView) {
//        view.layer.cornerRadius = 16
//        view.layer.borderWidth = 1
//        view.backgroundColor = .white
//    }
//    
//    func setCornerRadius(_ view: UIView, ontyTop: Bool = false, onlyBottum: Bool = false) {
//        view.layer.cornerRadius = 16
//        if ontyTop == true {
//            view.layer.maskedCorners = [
//                .layerMinXMinYCorner,
//                .layerMaxXMinYCorner
//            ]
//        }
//        if onlyBottum == true {
//            view.layer.maskedCorners = [
//                .layerMinXMaxYCorner, // Bottom Left
//                .layerMaxXMaxYCorner  // Bottom Right
//            ]
//        }
//        view.layer.borderColor = UIColor.mgLightGray.cgColor
//        view.layer.borderWidth = 0
//        view.layer.shadowOpacity = 0.17
//        view.layer.shadowOffset = .zero
//        view.layer.shadowRadius = 6
//        
//        //        view.clipsToBounds = true
//    }
//    
//    func applySelectedStyle(to view: UIView) {
//        
//        view.layer.borderColor = UIColor.primaryBlue.cgColor
//        view.layer.borderWidth = 1.5
//        
//        view.layer.shadowColor = UIColor.shadowBlue.cgColor
//        view.layer.shadowOpacity = 0.17
//        view.layer.shadowOffset = .zero
//        view.layer.shadowRadius = 6
//        
//        view.layer.masksToBounds = false
//    }
//    
//    func applyBottomSideShadow(to view: UIView, onlyBottum: Bool = false) {
//        
//        view.layer.cornerRadius = 16
//        view.layer.borderColor = UIColor.mgLightGray.cgColor
//        view.layer.borderWidth = 0
//        
//        view.layer.shadowColor = UIColor.mgLightGray.cgColor
//        view.layer.shadowOpacity = 0.17
//        view.layer.shadowOffset = CGSize(width: 0, height: 2)
//        view.layer.shadowRadius = 6
//        
//        if onlyBottum == true {
//            view.layer.maskedCorners = [
//                .layerMinXMaxYCorner, // Bottom Left
//                .layerMaxXMaxYCorner  // Bottom Right
//            ]
//        }
//        
//        
//        let shadowRect = CGRect(
//            x: -4,
//            y: 0, // Start from top edge
//            width: view.bounds.width + 8,
//            height: view.bounds.height + 8
//        )
//        
//        view.layer.shadowPath = UIBezierPath(
//            roundedRect: shadowRect,
//            cornerRadius: 16
//        ).cgPath
//    }
//    
//    func showDeleteConfirmation(completion: @escaping () -> Void) {
//        let alert = UIAlertController(
//            title: "Delete Trusted Contact",
//            message: "Are you sure you want to delete this trusted contact?",
//            preferredStyle: .alert
//        )
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
//            completion()
//        }
//        
//        alert.addAction(cancelAction)
//        alert.addAction(deleteAction)
//        
//        present(alert, animated: true)
//    }
//    
//    func setKeyboardObserver() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil
//        )
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil
//        )
//    }
//        
//    @objc func keyboardWillShow(_ notification: Notification) {
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height + 40
//            
//            for subView in self.view.subviews {
//                (subView as? UIScrollView)?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
//                (subView as? UITableView)?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
//            }
//        }
//    }
//        
//    @objc func keyboardWillHide(notification:NSNotification) {
//        
//        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//        for subView in self.view.subviews {
//            (subView as? UIScrollView)?.contentInset = contentInset
//            (subView as? UITableView)?.contentInset = contentInset
//        }
//    }
//    
//    
//    
//}
//
//extension UIViewController {
//    
//    private func presentCountryPicker(_ picker: CountryPickerViewController) {
//        if let navigationController {
//            navigationController.present(picker, animated: true)
//        } else {
//            present(picker, animated: true)
//        }
//    }
//    
//    func showCountryPicker(
//        countryCodeLabel: UILabel,
//        countryImageView: UIImageView,
//        completion: @escaping (String) -> Void
//    ) {
//        let picker = CountryPickerViewController.fetchInstance()
//        
//        picker.selectedCountry = { country in
//            countryCodeLabel.text = country.dialling_code
//            completion(country.code ?? "US")
//            
//            let url = URL(string: "https://flagcdn.com/w160/\(country.code?.lowercased() ?? "").png")
//            countryImageView.loadImage(with: url)
//        }
//        
//        presentCountryPicker(picker)
//    }
//
//    func showCountryPicker(completion: @escaping (CountryData) -> Void) {
//        let picker = CountryPickerViewController.fetchInstance()
//        picker.selectedCountry = completion
//        presentCountryPicker(picker)
//    }
//    
//    func setDefaultCountryCode(countryCodeLabel: UILabel,
//                               countryImageView: UIImageView, completion: @escaping ((String)?) -> Void) {
//        
////        let isoCode = CountryHelper.currentISO.uppercased()
//        let isoCode = "US"//CountryHelper.currentISO.uppercased()
//        
//        let picker = TDCountryPicker()
//        let dialCode = picker.CallingCodes.first(where: {
//            $0["code"] == isoCode
//        })?["dial_code"]
//        
//        print(dialCode ?? "")
//        completion(isoCode)
//        countryCodeLabel.text = dialCode ?? ""
//        let url = URL(string: "https://flagcdn.com/w160/\(isoCode.lowercased()).png")
//        countryImageView.loadImage(with: url)
//    }
//    
//    
//    func makeFieldTitle(_ title: String,
//                        isRequired: Bool = false,
//                        isOptional: Bool = false) -> NSAttributedString {
//        
//        let attributed = NSMutableAttributedString(
//            string: title,
//            attributes: [
//                .foregroundColor: UIColor(hex: "#475569"), //UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1), // Title color
//                .font: UIFont(name: "PTSans-Regular", size: 14) ?? .systemFont(ofSize: 14)
//            ]
//        )
//        
//        if isRequired {
//            attributed.append(
//                NSAttributedString(
//                    string: " *",
//                    attributes: [
//                        .foregroundColor: UIColor.systemRed,
//                        .font: UIFont(name: "PTSans-Regular", size: 14) ?? .systemFont(ofSize: 14)
//                    ]
//                )
//            )
//        }
//        
//        if isOptional {
//            attributed.append(
//                NSAttributedString(
//                    string: "(Optional)",
//                    attributes: [
//                        .foregroundColor: UIColor(hex: "#C3C6CE"),
//                        .font: UIFont(name: "PTSans-Regular", size: 12) ?? .systemFont(ofSize: 12)
//                    ]
//                )
//            )
//        }
//        
//        return attributed
//    }
//    
//    
//    func heightStringToCentimeters(_ height: String) -> Double? {
//        let cleaned = height.replacingOccurrences(of: "\"", with: "")
//        let parts = cleaned.split(separator: "'")
//        
//        guard parts.count == 2,
//              let feet = Int(parts[0]),
//              let inches = Int(parts[1]) else {
//            return nil
//        }
//        
//        let totalInches = feet * 12 + inches
//        return Double(totalInches) * 2.54
//    }
//    
//}

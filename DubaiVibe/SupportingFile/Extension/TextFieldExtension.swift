//
//  TextFieldExtension.swift
//  Auction
//
//  Created by mac on 10/12/20.
//

import Foundation
import UIKit

private var __maxLengths = [UITextField: Int]()

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = String(t!.prefix(maxLength))
        
    }
    
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setPadding(left: CGFloat = 0, right: CGFloat = 0) {
        
        if left > 0 {
            let leftView = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: left,
                    height: frame.height
                )
            )
            self.leftView = leftView
            self.leftViewMode = .always
        }
        
        if right > 0 {
            let rightView = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: right,
                    height: frame.height
                )
            )
            self.rightView = rightView
            self.rightViewMode = .always
        }
    }
    
    func updateEditableState(isEditing: Bool, cornerRadius: CGFloat = 8, padding: CGFloat = 8) {
        
        backgroundColor = isEditing ? UIColor(named: "mgSoftGrey") : .clear
        
        layer.cornerRadius = cornerRadius
        isEnabled = isEditing
        
        setPadding(left: padding, right: padding)
    }
    
    
}


import UIKit
import ObjectiveC

private var phoneFormattingCountryCodeKey: UInt8 = 0

// TITLE CASE FOR TEXT FIELDS

extension UITextField {

    var phoneFormattingCountryCode: String {
        get {
            objc_getAssociatedObject(self, &phoneFormattingCountryCodeKey) as? String ?? "US"
        }
        set {
            objc_setAssociatedObject(
                self,
                &phoneFormattingCountryCodeKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func enableTitleCase() {
        addTarget(self, action: #selector(convertToTitleCase), for: .editingChanged)
    }
    
    @objc private func convertToTitleCase() {
        guard let text = self.text else { return }
        
        let cursorPosition = selectedTextRange
        self.text = text.lowercased().capitalized
        selectedTextRange = cursorPosition
    }
    
    func enablePhoneNumberFormattingFortextField(countryCode: String = "US") {
        phoneFormattingCountryCode = countryCode
        keyboardType = .phonePad
        removeTarget(self, action: #selector(formatPhoneNumber1), for: .editingChanged)
        addTarget(self, action: #selector(formatPhoneNumber1), for: .editingChanged)
    }

    func disablePhoneNumberFormatting() {
        removeTarget(self, action: #selector(formatPhoneNumber1), for: .editingChanged)
    }

    func applyCurrentPhoneNumberFormatting() {
        let digits = String((text ?? "").filter { $0.isNumber }.prefix(15))

        guard phoneFormattingCountryCode.uppercased() == "US" else {
            text = digits
            return
        }

        text = Self.usFormattedPhoneNumber(from: digits)
    }
    
    @objc func formatPhoneNumber1() {
        applyCurrentPhoneNumberFormatting()
    }

    private static func usFormattedPhoneNumber(from digits: String) -> String {
        var formatted = ""

        for (index, digit) in digits.enumerated() {
            switch index {
            case 0:
                formatted += "("
                formatted.append(digit)
            case 1...2:
                formatted.append(digit)
            case 3:
                formatted += ") "
                formatted.append(digit)
            case 4...5:
                formatted.append(digit)
            case 6:
                formatted += "-"
                formatted.append(digit)
            case 7...15:
                formatted.append(digit)
            default:
                break
            }
        }

        return formatted
    }
    
    
    
}


class PhoneTextField: UITextField {

    var selectedCountryCode: String = ""

    func enablePhoneNumberFormatting() {
        keyboardType = .numberPad
        addTarget(self, action: #selector(formatPhoneNumber), for: .editingChanged)
    }

    @objc func formatPhoneNumber() {

        let digits = String((text ?? "")
            .filter { $0.isNumber }
            .prefix(15))

        guard selectedCountryCode.uppercased() == "US" else {
            text = digits
            return
        }

        var formatted = ""

        for (index, digit) in digits.enumerated() {
            switch index {
            case 0:
                formatted += "("
                formatted.append(digit)
            case 1...2:
                formatted.append(digit)
            case 3:
                formatted += ") "
                formatted.append(digit)
            case 4...5:
                formatted.append(digit)
            case 6:
                formatted += "-"
                formatted.append(digit)
            case 7...15:
                formatted.append(digit)
            default:
                break
            }
        }

        text = formatted
    }
}

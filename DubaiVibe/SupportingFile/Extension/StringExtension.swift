//
//  StringExtension.swift
//  Auction
//
//  Created by mac on 10/12/20.
//

import Foundation
import  UIKit
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    var digitsOnly: String {
        filter { $0.isNumber }
    }

    func isPhoneNumberInput(minDigits: Int = 4) -> Bool {
        if contains("@") { return false }
        if rangeOfCharacter(from: .letters) != nil { return false }
        return digitsOnly.count >= minDigits
    }

    var usFormattedPhoneNumber: String {
        let digits = String(digitsOnly.prefix(15))
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

    func localPhoneDigits(strippingDialCode dialCode: String) -> String {
        var digits = digitsOnly
        let dialDigits = dialCode.digitsOnly

        if !dialDigits.isEmpty, digits.hasPrefix(dialDigits) {
            digits = String(digits.dropFirst(dialDigits.count))
        }

        return String(digits.prefix(15))
    }

    func phoneDisplay(dialCode: String, countryISO: String) -> String {
        let localDigits = localPhoneDigits(strippingDialCode: dialCode)
        let localNumber = countryISO.uppercased() == "US"
            ? localDigits.usFormattedPhoneNumber
            : localDigits

        guard !dialCode.isEmpty else { return localNumber }
        return "\(dialCode) \(localNumber)"
    }
    
    
    func formattedDateAndTime() -> (date: String, time: String)? {
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: self) else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE MMM d, yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "h:mm a"
        
        return (
            date: dateFormatter.string(from: date),
            time: timeFormatter.string(from: date)
        )
    }
}
extension UIImage {
    static func gradientImageWithBounds(bounds: CGRect, colors: [CGColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors

        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


import Foundation

extension Locale {

    static var currentCountryCode: String {
        return Locale.current.region?.identifier ?? "IN"
    }

}

extension String {
    var titleCased: String {
        self.lowercased().capitalized
    }
}


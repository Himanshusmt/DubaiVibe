//
//  APIEndpoint.swift
//  MyGuardianLink
//

import Foundation

enum APIEndpoint {
    /// DubaiVibe mobile API — see http://18.194.78.138:5000/docs
    static let baseURL = "http://18.194.78.138:5000/api/mobile/v1/"
    
    static let privcypolicy = "https://portal.myguardianlink.com/privacy-policy?standalone=true"
    static let termsAndConditions = "https://portal.myguardianlink.com/terms-of-use?standalone=true"

    // MARK: - Mobile Auth //new
    case sendOTP
    case verifyOTP
    case resendOTP
    case googleLogin
    case googleAuthURL(String? = nil)
    case appleLogin
    case appleAuthURL(String? = nil)
    case authSession
    case logout
    case logoutAll
    case updateProfile
    case listCategories
    case listBusinesses(
        cursor: String? = nil,
        limit: Int? = nil,
        name: String? = nil,
        categoryId: String? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        radiusMeters: Double? = nil
    )
    case businessDetail(uuid: String, lat: Double? = nil, lng: Double? = nil)
    
    var path: String {
        
        switch self {
            
        case .sendOTP:
            return "auth/phone/otp"
        case .verifyOTP:
            return "auth/phone/verify"
        case .resendOTP:
            return "auth/phone/resend"
        case .googleLogin:
            return "auth/google"
        case .googleAuthURL(let callbackURL):
            return Self.oauthURLPath("auth/google/url", callbackURL: callbackURL)
        case .appleLogin:
            return "auth/apple"
        case .appleAuthURL(let callbackURL):
            return Self.oauthURLPath("auth/apple/url", callbackURL: callbackURL)
        case .authSession:
            return "auth/session"
        case .logout:
            return "auth/logout"
        case .logoutAll:
            return "auth/logout-all"

        case .updateProfile:
            return "profile"

        case .listCategories:
            return "categories"

        case .listBusinesses(let cursor, let limit, let name, let categoryId, let lat, let lng, let radiusMeters):
            return "businesses" + Self.query([
                ("cursor", cursor),
                ("limit", limit.map(String.init)),
                ("q", name),
                ("categoryId", categoryId),
                ("lat", lat.map { String(format: "%.6f", $0) }),
                ("lng", lng.map { String(format: "%.6f", $0) }),
                ("radiusMeters", radiusMeters.map { String(format: "%.0f", $0) })
            ])
        case .businessDetail(let uuid, let lat, let lng):
            let encoded = uuid.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? uuid
            return "businesses/\(encoded)" + Self.query([
                ("lat", lat.map { String(format: "%.6f", $0) }),
                ("lng", lng.map { String(format: "%.6f", $0) })
            ])
        }
    }
    
    var url: String {
        return APIEndpoint.baseURL + path
    }

    private static func oauthURLPath(_ path: String, callbackURL: String?) -> String {
        guard let callbackURL, !callbackURL.isEmpty else { return path }
        let encoded = callbackURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? callbackURL
        return "\(path)?callbackURL=\(encoded)"
    }

    private static func query(_ pairs: [(String, String?)]) -> String {
        let items = pairs.compactMap { key, value -> URLQueryItem? in
            guard let value, !value.isEmpty else { return nil }
            return URLQueryItem(name: key, value: value)
        }
        guard !items.isEmpty else { return "" }
        var components = URLComponents()
        components.queryItems = items
        guard let query = components.percentEncodedQuery, !query.isEmpty else { return "" }
        return "?" + query
    }
}

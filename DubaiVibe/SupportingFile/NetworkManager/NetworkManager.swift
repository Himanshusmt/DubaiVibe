
//
//  NetworkManager.swift
//

import Foundation
import UIKit
import Combine
import Network
import SVProgressHUD

// MARK: - API Error

enum APIError: LocalizedError {
    
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorized
    case noInternet
    case serverError(String)
    case custom(message: String, code: String?, currentGroupName: String?, newGroupName: String?)
    case unknown(Error)
    
    var errorDescription: String? {
        
        switch self {
            
        case .invalidURL:
            return "Invalid URL"
            
        case .invalidResponse:
            return "Invalid Response"
            
        case .decodingError:
            return "Decoding Failed"
            
        case .unauthorized:
            return "Session Expired"
            
        case .noInternet:
            return "No Internet Connection"
            
        case .serverError(let message):
            return message
            
        case .custom(let message, _, _, _):
            return message
            
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    
    case GET
    case POST
    case PUT
    case DELETE
}

// MARK: - AnyEncodable

struct AnyEncodable: Encodable {
    
    private let encodeClosure: (Encoder) throws -> Void
    
    init<T: Encodable>(_ wrapped: T) {
        encodeClosure = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}

// MARK: - Error Response

struct ErrorResponse: Codable {
    let message: String?
    let success: Bool?
    let error: APIErrorData?
}

struct APIErrorData: Codable {
    let message: String?
    let errorCode: String?
    let currentGroupName: String?
    let existingGroupName: String?
    let newGroupName: String?
}

// MARK: - Error Message Parser

enum APIErrorMessageParser {

    static func message(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }

        if let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            if let nested = decoded.error?.message?.trimmedNonEmpty {
                return nested
            }
            if let topLevel = decoded.message?.trimmedNonEmpty {
                return topLevel
            }
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return plainTextMessage(from: data)
        }

        if let nestedError = json["error"] as? [String: Any],
           let nestedMessage = (nestedError["message"] as? String)?.trimmedNonEmpty {
            return nestedMessage
        }

        if let errorString = (json["error"] as? String)?.trimmedNonEmpty {
            return errorString
        }

        if let topMessage = (json["message"] as? String)?.trimmedNonEmpty {
            return topMessage
        }

        if let dataDict = json["data"] as? [String: Any],
           let dataMessage = (dataDict["message"] as? String)?.trimmedNonEmpty {
            return dataMessage
        }

        if let errors = json["errors"] as? [String],
           let first = errors.first?.trimmedNonEmpty {
            return first
        }

        if let errors = json["errors"] as? [[String: Any]] {
            for item in errors {
                if let itemMessage = (item["message"] as? String)?.trimmedNonEmpty {
                    return itemMessage
                }
            }
        }

        return plainTextMessage(from: data)
    }

    static func businessLogicError(from data: Data) -> APIError? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let success = json["success"] as? Bool,
            success == false
        else {
            return nil
        }

        let message = message(from: data) ?? "Request failed"
        let errorData = (try? JSONDecoder().decode(ErrorResponse.self, from: data))?.error
        return .custom(
            message: message,
            code: errorData?.errorCode,
            currentGroupName: errorData?.currentGroupName ?? errorData?.existingGroupName,
            newGroupName: errorData?.newGroupName
        )
    }

    private static func plainTextMessage(from data: Data) -> String? {
        guard
            let raw = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !raw.isEmpty,
            !raw.hasPrefix("{"),
            !raw.hasPrefix("[")
        else {
            return nil
        }

        return raw.count <= 300 ? raw : nil
    }
}

// MARK: - Error Alert Presenter

enum APIErrorAlertPresenter {

    static func present(_ error: APIError) {
        guard error.shouldPresentToUser else { return }

//        DispatchQueue.main.async {
//            guard let presenter = topViewController() else { return }
//            guard !(presenter is UIAlertController) else { return }
//
//            presenter.showAlert(
//                title: "Error",
//                message: error.userFacingMessage
//            )
//        }
    }

    private static func topViewController(
        from root: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    ) -> UIViewController? {
        guard let root else { return nil }

        if let presented = root.presentedViewController {
            return topViewController(from: presented)
        }

        if let navigation = root as? UINavigationController {
            return topViewController(from: navigation.visibleViewController)
        }

        if let tab = root as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }

        return root
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

extension APIError {

    var errorCode: String? {
        if case .custom(_, let code, _, _) = self {
            return code
        }
        return nil
    }

    var currentGroupName: String? {
        if case .custom(_, _, let name, _) = self {
            return name
        }
        return nil
    }

    var newGroupName: String? {
        if case .custom(_, _, _, let name) = self {
            return name
        }
        return nil
    }

    var shouldPresentToUser: Bool {
        if case .unauthorized = self {
            return false
        }
        return true
    }

    var userFacingMessage: String {
        localizedDescription ?? "Something went wrong. Please try again."
    }
}

// MARK: - Empty Response

struct EmptyResponse: Codable {}

// MARK: - Network Reachability

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    
    private let queue = DispatchQueue(
        label: "NetworkMonitor"
    )
    
    private(set) var isConnected = true
    
    private init() {
        
        monitor.pathUpdateHandler = { path in
            
            self.isConnected = path.status == .satisfied
            
            #if DEBUG
            print("🌐 Network:",
                  self.isConnected
                  ? "Connected"
                  : "Disconnected")
            #endif
        }
        
        monitor.start(queue: queue)
    }
}

// MARK: - Loader Manager

final class LoaderManager {
    
    static let shared = LoaderManager()
    
    private var loaderCount = 0
    private var isConfigured = false
    
    private init() {
        configureIfNeeded()
    }
    
    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(0)
        SVProgressHUD.setFadeInAnimationDuration(0.15)
        SVProgressHUD.setFadeOutAnimationDuration(0.15)
    }
    
    func show() {
        configureIfNeeded()
        
        DispatchQueue.main.async {
            self.loaderCount += 1
            
            #if DEBUG
            print("🟡 SHOW LOADER (\(self.loaderCount))")
            #endif
            
            SVProgressHUD.show()
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.loaderCount = max(0, self.loaderCount - 1)
            
            #if DEBUG
            print("🟢 HIDE LOADER (\(self.loaderCount))")
            #endif
            
            if self.loaderCount == 0 {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.loaderCount = 0
            SVProgressHUD.dismiss()
        }
    }
}

// MARK: - Network Logger

final class NetworkLogger {
    
    static func logRequest(
        _ request: URLRequest
    ) {
        
        #if DEBUG
        
        print("""
        
        ===========================
        🚀 API REQUEST
        ===========================
        
        URL:
        \(request.url?.absoluteString ?? "")
        
        METHOD:
        \(request.httpMethod ?? "")
        
        HEADERS:
        \(request.allHTTPHeaderFields ?? [:])
        
        """)
        
        if let body = request.httpBody {
            
            print("""
            
            BODY:
            \(prettyPrint(data: body))
            
            """)
        }
        
        print("===========================\n")
        
        #endif
    }
    
    static func logResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) {
        
        #if DEBUG
        
        print("""
        
        ===========================
        ✅ API RESPONSE
        ===========================
        """)
        
        if let response =
            response as? HTTPURLResponse {
            
            print("""
            
            URL:
            \(response.url?.absoluteString ?? "")
            
            STATUS CODE:
            \(response.statusCode)
            
            """)
        }
        
        if let data = data {
            
            print("""
            
            RESPONSE:
            \(prettyPrint(data: data))
            
            """)
        }
        
        if let error = error {
            
            print("""
            
            ERROR:
            \(error.localizedDescription)
            
            """)
        }
        
        print("===========================\n")
        
        #endif
    }
    
    static func prettyPrint(
        data: Data
    ) -> String {
        
        do {
            
            let jsonObject =
            try JSONSerialization
                .jsonObject(with: data)
            
            let prettyData =
            try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: .prettyPrinted
            )
            
            return String(
                data: prettyData,
                encoding: .utf8
            ) ?? ""
            
        } catch {
            
            return String(
                data: data,
                encoding: .utf8
            ) ?? ""
        }
    }
}

// MARK: - Upload Progress Delegate

final class UploadProgressDelegate:
    NSObject,
    URLSessionTaskDelegate {
    
    var progressHandler:
    ((Double) -> Void)?
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        
        let progress =
        Double(totalBytesSent)
        / Double(totalBytesExpectedToSend)
        
        progressHandler?(progress)
    }
}

// MARK: - Network Manager

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private var isHandlingUnauthorizedSession = false
    
    private init() {}
    
    private let session: URLSession = {
        
        let configuration =
        URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 600
        
        configuration.timeoutIntervalForResource = 600
        
        return URLSession(
            configuration: configuration
        )
    }()
    
    // MARK: - Common Request
    
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String] = [:],
        showLoader: Bool = true,
        showErrorAlert: Bool = true
    ) -> AnyPublisher<T, APIError> {
        
        // MARK: Internet Check
        
        guard NetworkMonitor.shared
            .isConnected else {
            
            return Fail(
                error: APIError.noInternet
            )
            .eraseToAnyPublisher()
        }
        
        // MARK: URL
        
        guard let url =
                URL(string: endpoint.url) else {
            
            return Fail(
                error: APIError.invalidURL
            )
            .eraseToAnyPublisher()
        }
        
        var request =
        URLRequest(url: url)
        
        request.httpMethod =
        method.rawValue
        
        request.timeoutInterval = 60
        
        // MARK: Headers
        
        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )
        
        // MARK: Token
        
        if let token =
            TokenManager.shared.accessToken {
            
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField:
                    "Authorization"
            )
        }
        
        // MARK: Custom Headers
        
        headers.forEach {
            
            request.setValue(
                $0.value,
                forHTTPHeaderField:
                    $0.key
            )
        }
        
        // MARK: Body
        
        if let parameters = parameters {
            
            do {
                
                request.httpBody = try JSONSerialization
                    .data(
                        withJSONObject: parameters,
                        options: []
                    )
                
            } catch {
                
                return Fail(
                    error: APIError.decodingError
                )
                .eraseToAnyPublisher()
            }
        }
        
        // MARK: Loader
        
        if showLoader {
            LoaderManager.shared.show()
        }
        
        // MARK: Logs
        
        NetworkLogger.logRequest(
            request
        )
        
        return session
            .dataTaskPublisher(
                for: request
            )
            .retry(2)
            .tryMap { output in
                
                NetworkLogger.logResponse(
                    data: output.data,
                    response: output.response,
                    error: nil
                )
                
                guard let response =
                        output.response
                        as? HTTPURLResponse else {
                    
                    throw APIError
                        .invalidResponse
                }
                
                switch response.statusCode {
                    
                case 200...299:
                    if let businessError = APIErrorMessageParser.businessLogicError(from: output.data) {
                        throw businessError
                    }
                    return output.data
                    
                default:
                    throw Self.mapHTTPError(
                        statusCode: response.statusCode,
                        data: output.data
                    )
                }
            }
            .tryMap { data in
                    
                    try self.decodeResponse(
                        T.self,
                        from: data
                    )
                }
            .mapError { error in
                
                #if DEBUG
                
                print("""
                
                ❌ API ERROR:
                \(error.localizedDescription)
                
                """)
                
                #endif
                
                let apiError: APIError
                if let error = error as? APIError {
                    apiError = error
                } else {
                    apiError = .unknown(error)
                }

                if showErrorAlert {
                    APIErrorAlertPresenter.present(apiError)
                }

                return apiError
            }
            .receive(
                on: DispatchQueue.main
            )
            .handleEvents(
                receiveCompletion: { _ in
                    if showLoader {
                        LoaderManager.shared.hide()
                    }
                },
                receiveCancel: {
                    if showLoader {
                        LoaderManager.shared.hide()
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Upload Image
    
    func uploadImage<T: Decodable>(
        endpoint: APIEndpoint,
        image: UIImage?,
        imageKey: String = "image",
        method: HTTPMethod = .POST,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        showLoader: Bool = true,
        showErrorAlert: Bool = true,
        progressHandler:
        ((Double) -> Void)? = nil
    ) -> AnyPublisher<T, APIError> {
        
        guard let url =
                URL(string: endpoint.url) else {
            
            return Fail(
                error: APIError.invalidURL
            )
            .eraseToAnyPublisher()
        }
        
        let boundary =
        UUID().uuidString
        
        var request =
        URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField:
                "Content-Type"
        )
        
        // MARK: Token
        
        if let token =
            TokenManager.shared.accessToken {
            
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField:
                    "Authorization"
            )
        }
        
        // MARK: Headers
        
        headers.forEach {
            
            request.setValue(
                $0.value,
                forHTTPHeaderField:
                    $0.key
            )
        }
        
        // MARK: Body
        
        let body =
        createMultipartBody(
            boundary: boundary,
            image: image,
            imageKey: imageKey,
            parameters: parameters
        )
        
        // MARK: Loader
        
        if showLoader {
            LoaderManager.shared.show()
        }
        
        // MARK: Logs
        
        NetworkLogger.logRequest(
            request
        )
        
        return Future<T, APIError> {
            promise in
            
            let task =
            self.session.uploadTask(
                with: request,
                from: body
            ) {
                data,
                response,
                error in
                
                DispatchQueue.main.async {
                    
                    if showLoader {
                        LoaderManager.shared
                            .hide()
                    }
                }
                
                NetworkLogger.logResponse(
                    data: data,
                    response: response,
                    error: error
                )
                
                // MARK: Error
                
                if let error = error {
                    let apiError = APIError.unknown(error)
                    if showErrorAlert {
                        APIErrorAlertPresenter.present(apiError)
                    }
                    promise(.failure(apiError))
                    return
                }
                
                // MARK: Response
                
                guard let response =
                        response
                        as? HTTPURLResponse else {
                    let apiError = APIError.invalidResponse
                    if showErrorAlert {
                        APIErrorAlertPresenter.present(apiError)
                    }
                    promise(.failure(apiError))
                    return
                }
                
                switch response.statusCode {
                    
                case 200...299:
                    if let data,
                       let businessError = APIErrorMessageParser.businessLogicError(from: data) {
                        if showErrorAlert {
                            APIErrorAlertPresenter.present(businessError)
                        }
                        promise(.failure(businessError))
                        return
                    }
                    break
                    
                default:
                    let apiError = NetworkManager.mapHTTPError(
                        statusCode: response.statusCode,
                        data: data ?? Data()
                    )
                    if showErrorAlert {
                        APIErrorAlertPresenter.present(apiError)
                    }
                    promise(.failure(apiError))
                    return
                }
                
                // MARK: Decode
                
                guard let data = data else {
                    let apiError = APIError.invalidResponse
                    if showErrorAlert {
                        APIErrorAlertPresenter.present(apiError)
                    }
                    promise(.failure(apiError))
                    return
                }
                
                do {
                    
                    let decoded =
                    try JSONDecoder()
                        .decode(
                            T.self,
                            from: data
                        )
                    
                    promise(
                        .success(decoded)
                    )
                    
                } catch {
                    let apiError = APIError.decodingError
                    if showErrorAlert {
                        APIErrorAlertPresenter.present(apiError)
                    }
                    promise(.failure(apiError))
                }
            }
            
            task.resume()
        }
        .receive(
            on: DispatchQueue.main
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: - Async Await
    
    func asyncRequest<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        showErrorAlert: Bool = true
    ) async throws -> T {
        
        guard let url =
                URL(string: endpoint.url) else {
            
            throw APIError.invalidURL
        }
        
        var request =
        URLRequest(url: url)
        
        request.httpMethod =
        method.rawValue
        
        if let body = body {
            
            request.httpBody =
            try JSONEncoder()
                .encode(
                    AnyEncodable(body)
                )
        }
        
        let (data, response) =
        try await session.data(
            for: request
        )
        
        guard let response =
                response as? HTTPURLResponse else {
            
            throw APIError.invalidResponse
        }
        
        switch response.statusCode {
            
        case 200...299:
            if let businessError = APIErrorMessageParser.businessLogicError(from: data) {
                if showErrorAlert {
                    APIErrorAlertPresenter.present(businessError)
                }
                throw businessError
            }
            break
            
        default:
            let apiError = NetworkManager.mapHTTPError(
                statusCode: response.statusCode,
                data: data
            )
            if showErrorAlert {
                APIErrorAlertPresenter.present(apiError)
            }
            throw apiError
        }
        
        return try JSONDecoder()
            .decode(T.self,
                    from: data)
    }
    
    
    func requestJSON(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String] = [:],
        showLoader: Bool = true,
        showErrorAlert: Bool = true
    ) -> AnyPublisher<[String: Any], APIError> {

        // Internet Check
        guard NetworkMonitor.shared.isConnected else {
            return Fail(error: .noInternet)
                .eraseToAnyPublisher()
        }

        // URL
        guard let url = URL(string: endpoint.url) else {
            return Fail(error: .invalidURL)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 60

        // Headers
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type")

        // Token
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
        }

        // Custom Headers
        headers.forEach {
            request.setValue($0.value,
                             forHTTPHeaderField: $0.key)
        }

        // Body
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(
                    withJSONObject: parameters,
                    options: []
                )
            } catch {
                return Fail(error: .decodingError)
                    .eraseToAnyPublisher()
            }
        }

        if showLoader {
            LoaderManager.shared.show()
        }

        NetworkLogger.logRequest(request)

        return session
            .dataTaskPublisher(for: request)
            .retry(2)
            .tryMap { output in

                NetworkLogger.logResponse(
                    data: output.data,
                    response: output.response,
                    error: nil
                )

                guard let response = output.response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                switch response.statusCode {

                case 200...299:

                    guard let json = try JSONSerialization.jsonObject(
                        with: output.data,
                        options: []
                    ) as? [String: Any] else {
                        throw APIError.decodingError
                    }

                    if let success = json["success"] as? Bool, success == false {
                        let message = APIErrorMessageParser.message(from: output.data)
                            ?? "Request failed"
                        throw APIError.serverError(message)
                    }

                    return json

                default:
                    throw Self.mapHTTPError(
                        statusCode: response.statusCode,
                        data: output.data
                    )
                }

            }
            .mapError { error in

                let apiError: APIError
                if let error = error as? APIError {
                    apiError = error
                } else {
                    apiError = .unknown(error)
                }

                if showErrorAlert {
                    APIErrorAlertPresenter.present(apiError)
                }

                return apiError
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveCompletion: { _ in
                    if showLoader {
                        LoaderManager.shared.hide()
                    }
                },
                receiveCancel: {
                    if showLoader {
                        LoaderManager.shared.hide()
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    // MARK: - 401 Unauthorized

    func handleUnauthorizedSession() {
        guard !isHandlingUnauthorizedSession else { return }
        isHandlingUnauthorizedSession = true

        LoaderManager.shared.reset()
        TokenManager.shared.clearUnauthorizedSession()

        guard let presenter = Self.topViewControllerForSessionAlert(),
              !(presenter is UIAlertController) else {
            navigateToSignUpAfterUnauthorized()
            isHandlingUnauthorizedSession = false
            return
        }

        let alert = UIAlertController(
            title: "Session Expired",
            message: "Your session has expired. Please sign in again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToSignUpAfterUnauthorized()
            self?.isHandlingUnauthorizedSession = false
        })
        presenter.present(alert, animated: true)
    }

    private func navigateToSignUpAfterUnauthorized() {
//        let signupVC = SignUpViewController.fetchInstance()
//        let navigationController = UINavigationController(rootViewController: signupVC)
//        navigationController.setNavigationBarHidden(true, animated: false)
//
//        guard let window = UIApplication.shared.connectedScenes
//            .compactMap({ $0 as? UIWindowScene })
//            .flatMap(\.windows)
//            .first(where: \.isKeyWindow) else {
//            return
//        }
//
//        window.rootViewController = navigationController
//        window.makeKeyAndVisible()
    }

    private static func topViewControllerForSessionAlert(
        from root: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    ) -> UIViewController? {
        guard let root else { return nil }

        if let presented = root.presentedViewController {
            return topViewControllerForSessionAlert(from: presented)
        }

        if let navigation = root as? UINavigationController {
            return topViewControllerForSessionAlert(from: navigation.visibleViewController)
        }

        if let tab = root as? UITabBarController {
            return topViewControllerForSessionAlert(from: tab.selectedViewController)
        }

        return root
    }
}

// MARK: - HTTP Error Mapping

private extension NetworkManager {

    static func mapHTTPError(statusCode: Int, data: Data) -> APIError {
        if statusCode == 401 {
            DispatchQueue.main.async {
                NetworkManager.shared.handleUnauthorizedSession()
            }
            return .unauthorized
        }

        let message = APIErrorMessageParser.message(from: data)
            ?? "Request failed (\(statusCode))"

        if statusCode == 404,
           let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           let code = decoded.error?.errorCode {
            return .custom(message: message, code: code, currentGroupName: nil, newGroupName: nil)
        }
        
        if statusCode == 400,
           let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           let code = decoded.error?.errorCode {
            return .custom(message: message, code: code, currentGroupName: nil, newGroupName: nil)
        }
        
        if statusCode == 403,
           let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           let code = decoded.error?.errorCode {
            return .custom(message: message, code: code, currentGroupName: nil, newGroupName: nil)
        }
        
        if statusCode == 409,
           let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           let code = decoded.error?.errorCode {
            return .custom(message: message, code: code, currentGroupName: nil, newGroupName: nil)
        }

        return .serverError(message)
    }
}

// MARK: - Multipart Body

private extension NetworkManager {
    
    func createMultipartBody(
        boundary: String,
        image: UIImage?,
        imageKey: String,
        parameters: [String: String]
    ) -> Data {
        
        let body = NSMutableData()
        
        // Parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        // Image (Optional)
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        
        return body as Data
    }
    
    
    private func decodeResponse<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T {
        
        do {
            
            return try JSONDecoder()
                .decode(T.self, from: data)
            
        } catch DecodingError.typeMismatch(let type, let context) {
            
            print("""
            
            ❌ TYPE MISMATCH
            
            Expected Type:
            \(type)
            
            Path:
            \(context.codingPath.map(\.stringValue).joined(separator: "."))
            
            Description:
            \(context.debugDescription)
            
            """)
            
            throw APIError.decodingError
            
        } catch DecodingError.valueNotFound(let value, let context) {
            
            print("""
            
            ❌ VALUE NOT FOUND
            
            Value:
            \(value)
            
            Path:
            \(context.codingPath.map(\.stringValue).joined(separator: "."))
            
            Description:
            \(context.debugDescription)
            
            """)
            
            throw APIError.decodingError
            
        } catch DecodingError.keyNotFound(let key, let context) {
            
            print("""
            
            ❌ KEY NOT FOUND
            
            Key:
            \(key.stringValue)
            
            Path:
            \(context.codingPath.map(\.stringValue).joined(separator: "."))
            
            Description:
            \(context.debugDescription)
            
            """)
            
            throw APIError.decodingError
            
        } catch DecodingError.dataCorrupted(let context) {
            
            print("""
            
            ❌ DATA CORRUPTED
            
            Path:
            \(context.codingPath.map(\.stringValue).joined(separator: "."))
            
            Description:
            \(context.debugDescription)
            
            """)
            
            throw APIError.decodingError
            
        } catch {
            
            print("""
            
            ❌ DECODING ERROR
            
            \(error.localizedDescription)
            
            """)
            
            if let serverMessage = APIErrorMessageParser.message(from: data) {
                throw APIError.serverError(serverMessage)
            }

            throw APIError.decodingError
        }
    }
}

extension NSMutableData {
    func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - Data Extension

private extension Data {
    
    mutating func append(
        _ string: String
    ) {
        
        if let data =
            string.data(
                using: .utf8
            ) {
            
            append(data)
        }
    }
}

// MARK: - Alert Extension

extension UIViewController {
    
    func showAlert(
        title: String = "Error",
        message: String
    ) {
        
        let alert =
        UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        
        present(
            alert,
            animated: true
        )
    }
}




//receiveValue: { (response: VerifyOTPResponse) in
//
//    TokenManager.shared.saveAccessToken(
//        response.accessToken
//    )
//}

enum LaunchType {
    case signup
    case resumeOnboarding
}

// MARK: - Token Manager



final class TokenManager {

    static let shared = TokenManager()

    private init() {}

    private let accessTokenKey = "ACCESS_TOKEN"
    private let currentStepKey = "CURRENT_STEP"
    private let isOnboardingCompletedKey = "IS_ONBOARDING_COMPLETED"
    private let userIdKey = "USER_ID"
    private let isSkipPersonalInfoKey: String = "IS_SKIP_PERSONAL_INFO"
    private let socialFullNameKey = "SOCIAL_LOGIN_FULL_NAME"
    private let hasSeenHomeTutorialsIntroKey = "HAS_SEEN_HOME_TUTORIALS_INTRO"
    
    var isResumingOnboarding = false
    
    var accessToken: String? {
        UserDefaults.standard.string(
            forKey: accessTokenKey
        )
    }

    /// Name from Google / Apple login — used to prefill Complete Profile.
    var socialFullName: String? {
        let name = UserDefaults.standard.string(forKey: socialFullNameKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let name, !name.isEmpty else { return nil }
        return name
    }

    var isSocialLoginNameLocked: Bool {
        socialFullName != nil
    }

    /// Saves social name. Empty / nil values are ignored so we never wipe a previously saved name.
    func saveSocialFullName(_ name: String?) {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return }
        UserDefaults.standard.set(trimmed, forKey: socialFullNameKey)
        UserDefaults.standard.synchronize()
        print("TokenManager saved socialFullName:", trimmed)
    }

    func clearSocialFullName() {
        UserDefaults.standard.removeObject(forKey: socialFullNameKey)
    }

    /// Apple sends fullName only on the first authorization — persist per Apple user id.
    func saveAppleUserName(appleUserId: String, fullName: String?) {
        let trimmed = fullName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !appleUserId.isEmpty, !trimmed.isEmpty else { return }
        UserDefaults.standard.set(trimmed, forKey: "AppleUserName.\(appleUserId)")
        saveSocialFullName(trimmed)
    }

    func appleUserName(for appleUserId: String) -> String? {
        guard !appleUserId.isEmpty else { return nil }
        let name = UserDefaults.standard.string(forKey: "AppleUserName.\(appleUserId)")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let name, !name.isEmpty else { return nil }
        return name
    }

    var curretnStep: Int? {
        UserDefaults.standard.integer(
            forKey: currentStepKey
        )
    }
    
    var isNeedToSkipPersonalInfo: Bool? {
        get {
            UserDefaults.standard.bool(forKey: isSkipPersonalInfoKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isSkipPersonalInfoKey)
        }
    }

    var userId: String? {
        if let stored = UserDefaults.standard.string(forKey: userIdKey), !stored.isEmpty {
            return stored
        }
        return jwtUserId(from: accessToken)
    }
    
    func saveAccessToken(_ token: String) {

        UserDefaults.standard.set(
            token,
            forKey: accessTokenKey
        )
    }
    
    var isOnboardingCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: isOnboardingCompletedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isOnboardingCompletedKey)
        }
    }

    /// Home tutorials card: first-time ("See How…") on first visit; returning copy after that.
    var hasSeenHomeTutorialsIntro: Bool {
        get {
            UserDefaults.standard.bool(forKey: homeTutorialsIntroStorageKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: homeTutorialsIntroStorageKey)
        }
    }

    private var homeTutorialsIntroStorageKey: String {
        if let userId = userId, !userId.isEmpty {
            return "\(hasSeenHomeTutorialsIntroKey).\(userId)"
        }
        return hasSeenHomeTutorialsIntroKey
    }
    
    func saveCurrentStep(_ step: Int) {
        UserDefaults.standard.set(
            step,
            forKey: currentStepKey
        )
    }

    func saveUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    func clearToken() {

        UserDefaults.standard.removeObject(
            forKey: accessTokenKey
        )

        UserDefaults.standard.removeObject(
            forKey: userIdKey
        )
    }

    /// 401 unauthorized — full session clear without posting `SESSION_EXPIRED`.
    func clearUnauthorizedSession() {
        let defaults = UserDefaults.standard

        defaults.removeObject(forKey: accessTokenKey)
        defaults.removeObject(forKey: currentStepKey)
        defaults.removeObject(forKey: userIdKey)
        defaults.removeObject(forKey: isOnboardingCompletedKey)
        defaults.removeObject(forKey: isSkipPersonalInfoKey)
        defaults.removeObject(forKey: socialFullNameKey)
        defaults.removeObject(forKey: "SelectedAlertsDraftKey")
        defaults.removeObject(forKey: "AdditionalAlertsDraftKey")
        defaults.removeObject(forKey: "PersonalInfoDraftKey")
        defaults.removeObject(forKey: "AppleSignInEmail")
        defaults.removeObject(forKey: "AppleSignInGivenName")
        defaults.removeObject(forKey: "AppleSignInFamilyName")

        FCMNotificationManager.clearDeviceId()

        defaults.synchronize()
    }

    func clearSteps() {
        UserDefaults.standard.removeObject(
            forKey: currentStepKey
        )
    }
    
    var isLoggedIn: Bool {
        accessToken != nil
    }
    
    func logout() {
        clearUnauthorizedSession()

        NotificationCenter.default.post(
            name: .sessionExpired,
            object: nil
        )
    }
    
    private func jwtUserId(from token: String?) -> String? {
        guard let token = token else { return nil }

        let segments = token.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }

        var base64 = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let id = json["id"] as? String else {
            return nil
        }

        return id
    }
    
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("SESSION_EXPIRED")
}

//receiveValue: { (response: VerifyOTPResponse) in
//
//    TokenManager.shared.saveAccessToken(
//        response.accessToken
//    )
//}

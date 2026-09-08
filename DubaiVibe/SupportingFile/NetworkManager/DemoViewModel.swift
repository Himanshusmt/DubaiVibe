//
//  DemoViewModel.swift
//  MyGuardianLink
//
//  Created by himanshu pal on 28/05/26.
//

import Foundation

struct UserModel: Codable {
    let id: Int?
    let name: String?
    let email: String?
}
import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

//------ view model
import Foundation
import Combine
import UIKit

final class UserViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var user: UserModel?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var uploadSuccessMessage: String = ""
    
    // MARK: - Combine
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Login API
    
    func login(email: String,
               password: String) {
        
        isLoading = true
        
       
        var param = [String : Any]()
        param[""] =  email
        param[""] = password
       
        
   
        NetworkManager.shared.request(
            endpoint: .sendOTP,
            method: .POST,
            parameters: param,
            showLoader: true
        )
        .sink { [weak self] completion in
            
            self?.isLoading = false
            
            switch completion {
                
            case .finished:
                print("Login Success")
                
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
            
        } receiveValue: { [weak self] (response: UserModel) in
            
            self?.user = response
            
            print("User Name:", response.name ?? "")
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Get Profile
    
    func getProfile() {
        
        NetworkManager.shared.request(
            endpoint: .sendOTP,
            method: .GET,
            showLoader: true
        )
        .sink { [weak self] completion in
            
            switch completion {
                
            case .finished:
                print("Profile Success")
                
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
            
        } receiveValue: { [weak self] (response: UserModel) in
            
            self?.user = response
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Upload Image
    
    func uploadProfileImage(image: UIImage) {
        
        NetworkManager.shared.uploadImage(
            endpoint: .sendOTP,
            image: image,
            imageKey: "profile_image",
            parameters: [
                "user_id": "1"
            ],
            showLoader: true
        )
        .sink { [weak self] completion in
            
            switch completion {
                
            case .finished:
                print("Upload Success")
                
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
            
        } receiveValue: { [weak self] (_: UserModel) in
            
            self?.uploadSuccessMessage = "Image Uploaded Successfully"
        }
        .store(in: &cancellables)
    }
}

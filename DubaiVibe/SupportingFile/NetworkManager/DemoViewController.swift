//
//  DemoViewController.swift
//  MyGuardianLink
//
//  Created by himanshu pal on 28/05/26.
//


//import UIKit
//import Combine

//final class UserViewController: UIViewController {
//    
//    // MARK: - IBOutlets
//    
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
//    
//    // MARK: - Properties
//    
//    private let viewModel = UserViewModel()
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - Life Cycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        binding()
//        
//        // API Call
//        
//        viewModel.getProfile()
//    }
//    
//    // MARK: - Binding
//    
//    private func binding() {
//        
//        // User Data
//        
//        viewModel.$user
//            .compactMap { $0 }
//            .sink { [weak self] user in
//                
//                self?.nameLabel.text = user.name
//                self?.emailLabel.text = user.email
//                
//            }
//            .store(in: &cancellables)
//        
//        // Error
//        
//        viewModel.$errorMessage
//            .sink { [weak self] message in
//                
//                guard !message.isEmpty else { return }
//                
//                self?.showAlert(message: message)
//            }
//            .store(in: &cancellables)
//        
//        // Upload Success
//        
//        viewModel.$uploadSuccessMessage
//            .sink { message in
//                
//                if !message.isEmpty {
//                    print(message)
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    // MARK: - Button Actions
//    
//    @IBAction func loginButtonTapped(_ sender: UIButton) {
//        
//        viewModel.login(
//            email: "test@gmail.com",
//            password: "123456"
//        )
//    }
//    
//    @IBAction func uploadButtonTapped(_ sender: UIButton) {
//        
//        guard let image = UIImage(named: "demo") else { return }
//        
//        viewModel.uploadProfileImage(image: image)
//    }
//}

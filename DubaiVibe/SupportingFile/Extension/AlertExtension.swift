////
////  AlertExtension.swift
////  Auction
////
////  Created by mac on 10/12/20.
////
//
//import Foundation
//import UIKit
//class Util: NSObject {
//    // MARK: - Alert Methods
//    class func showNetWorkAlert()
//    {
//        showAlertWithCallback("No Network Connection", message: "Please check your connection and try again.", isWithCancel: false)
//        // Loader.hideLoader()
//    }
//    
//    //MARK:- alert with handler
//    class func showAlertWithCallback(_ title: String?, message: String?, isWithCancel: Bool, handler: (() -> Void)? = nil) {
//        if UIApplication.topViewController() != nil {
//            if (UIApplication.topViewController()!.isKind(of: UIAlertController.self)) {
//                return
//            }
//        }
//        
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        if isWithCancel {
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
//        }
//        
//        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
//            handler?()
//        }))
//        appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//      //  UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//    class func showAlertWithCancelCallback(_ title: String?, message: String?, isWithCancel: Bool, handler: ((String) -> Void)? = nil) {
//        if UIApplication.topViewController() != nil {
//            if (UIApplication.topViewController()!.isKind(of: UIAlertController.self)) {
//                return
//            }
//        }
//        
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//    
//        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
//            handler?("Ok")
//        }))
//        
//        if isWithCancel {
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
//                handler?("Cancel")
//            }))
//        }
//        
//        appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//}
//
//
////Return top or visible view controller
////extension UIApplication {
////    
////    class func topViewController(_ base: UIViewController? = appDelegate.window?.rootViewController) -> UIViewController? {
////        if let nav = base as? UINavigationController {
////            return topViewController(nav.visibleViewController)
////        }
////        if let tab = base as? UITabBarController {
////            if let selected = tab.selectedViewController {
////                return topViewController(selected)
////            }
////        }
////        if let presented = base?.presentedViewController {
////            return topViewController(presented)
////        }
////        return base
////    }
////}
//

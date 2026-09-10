//
//  TDImagePicker.swift
//  Traydi
//
//  Created by mac on 26/12/19.
//  Copyright © 2019 Creative thought infotech. All rights reserved.
//

import Foundation

import UIKit

public protocol TDImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class TDImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: TDImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: TDImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
    
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
//        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
//            alertController.addAction(action)
//        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true) {
            Self.clearDimmingBackdrop(for: alertController)
        }
        // Also clear mid-animation so the dim never flashes in.
        DispatchQueue.main.async {
            Self.clearDimmingBackdrop(for: alertController)
        }
    }

    private static func clearDimmingBackdrop(for alertController: UIAlertController) {
        guard let container = alertController.presentationController?.containerView else { return }
        let presented = alertController.presentationController?.presentedView

        for subview in container.subviews {
            // Keep the action sheet itself; only clear the full-screen dimming layer.
            if subview === presented || subview === alertController.view || subview.isDescendant(of: alertController.view) {
                continue
            }
            subview.backgroundColor = .clear
            subview.isOpaque = false
            if let effectView = subview as? UIVisualEffectView {
                effectView.effect = nil
            }
            for nested in subview.subviews {
                nested.backgroundColor = .clear
                if let effectView = nested as? UIVisualEffectView {
                    effectView.effect = nil
                }
            }
        }
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension TDImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension TDImagePicker: UINavigationControllerDelegate {
    
}

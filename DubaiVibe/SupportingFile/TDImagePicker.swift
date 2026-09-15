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
        self.pickerController.overrideUserInterfaceStyle = .dark
        // Avoid the brief white flash when the picker covers a black screen.
        self.pickerController.modalPresentationStyle = .overFullScreen
        self.pickerController.view.backgroundColor = .black
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
        let alertController = UndimmedActionSheetController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.overrideUserInterfaceStyle = .dark

        if let action = self.action(for: .camera, title: L10n.takePhoto) {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: L10n.photoLibrary) {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        // Keep the profile screen from dimming/flashing behind the sheet.
        presentationController?.view.tintAdjustmentMode = .normal
        presentationController?.view.window?.tintAdjustmentMode = .normal

        presentationController?.presentStyledAlert(alertController)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

/// Action sheet that never shows the system dimming backdrop (avoids the flash on dark screens).
private final class UndimmedActionSheetController: UIAlertController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearDimmingBackdrop()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        clearDimmingBackdrop()
    }

    private func clearDimmingBackdrop() {
        guard let container = presentationController?.containerView else { return }
        let presented = presentationController?.presentedView

        for subview in container.subviews {
            if subview === presented || subview === view || subview.isDescendant(of: view) {
                continue
            }
            subview.backgroundColor = .clear
            subview.isOpaque = false
            subview.alpha = 1
            if let effectView = subview as? UIVisualEffectView {
                effectView.effect = nil
            }
            for nested in subview.subviews {
                nested.backgroundColor = .clear
                nested.isOpaque = false
                if let effectView = nested as? UIVisualEffectView {
                    effectView.effect = nil
                }
            }
        }
        container.backgroundColor = .clear
    }
}

extension TDImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension TDImagePicker: UINavigationControllerDelegate {}

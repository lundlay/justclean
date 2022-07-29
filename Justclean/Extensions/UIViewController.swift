//
//  UIViewController.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import UIKit

extension UIViewController {

    @discardableResult
    func display(error: Error?) -> Bool {
        guard let error = error else {
            return true
        }
        
        

        switch error {
        case let error as LocalizedError:
            self.alert(title: error.errorDescription, message: error.failureReason ?? error.localizedDescription)
        case let error as NSError:
            self.alert(title: "NSError", message: error.localizedDescription)
        case let error as CocoaError:
            self.alert(title: "CocoaError", message: error.localizedDescription)
        default:
            self.alert(title: "Error", message: String(describing: error))
        }

        return false
    }
    
    @discardableResult
    func alert(title: String?, message: String?, actions: [UIAlertAction] = []) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach {
            alertController.addAction($0)
        }
        
        if actions.isEmpty {
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
        }

        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.frame
            presenter.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(alertController, animated: true, completion: nil)
        return alertController
    }
}


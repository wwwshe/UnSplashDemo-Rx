//
//  UIViewController+Extension.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/25.
//

import Foundation
import UIKit

enum StoryBoard: String {
    case main = "Main"
}

extension UIViewController {
    func getViewController<T: UIViewController>(target: T.Type,
                                                storyboard: StoryBoard = .main) -> T? {
        let storyBoard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let identifierStr = String(describing: target)
        let identifiersList = storyBoard.value(forKey: "identifierToNibNameMap") as? [String: Any]
        guard identifiersList?[identifierStr] != nil else {
            print("UIViewController identifier not found, identifier : \(identifierStr)")
            return nil
        }
        var vc: UIViewController
        if #available(iOS 13.0, *) {
            vc = storyBoard.instantiateViewController(identifier: identifierStr)
        } else {
            vc = storyBoard.instantiateViewController(withIdentifier: identifierStr)
        }
        let selfViewController = vc as? T
        return selfViewController
    }
}

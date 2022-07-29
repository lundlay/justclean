//
//  NSObject.swift
//  Justclean
//
//  Created by Oleg Lavronov on 27.07.2022.
//

import Foundation

extension NSObject {

    var className: String {
        return String(describing: type(of: self))
    }

    class var className: String {
        return String(describing: self)
    }

}

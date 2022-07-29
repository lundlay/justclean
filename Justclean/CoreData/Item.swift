//
//  Item.swift
//  Justclean
//
//  Created by Oleg Lavronov on 27.07.2022.
//

import CoreData

extension Item {
    
    func with(_ laundryID: String, _ item: API.Item) {
        self.laundryID = laundryID
        self.name = item.name
        self.price = item.price ?? 0.0
    }
    
}

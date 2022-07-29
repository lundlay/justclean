//
//  Laundry.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import CoreData

extension Laundry {
    
    var items: [Item] {
        guard let laundryID = laundryID else { return [] }
        let fetchRequest : NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "laundryID = %@", laundryID)
        let fetchedResults = try? managedObjectContext?.fetch(fetchRequest)
        return fetchedResults ?? []
    }
    
    func with(_ laundry: API.Laundry) {
        self.laundryID = String(describing: laundry.id)
        self.name = laundry.name
        self.photo = laundry.photo
        
        self.createdAt = self.createdAt ?? Date()
        self.updatedAt = Date()
    }
    
}

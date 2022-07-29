//
//  NSManagedObject.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import CoreData

extension NSManagedObject {
    
    static func findOrCreateBy(_ predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
        if let object = findBy(predicate, context: context) {
            return object
        }
        let object = Self.create(context: context)
        return object
    }
    
    static func find(_ object: NSManagedObject?, context: NSManagedObjectContext) -> Self? {
        guard let objectID = object?.objectID else { return nil }
        return try? context.existingObject(with: objectID) as? Self
    }
    
    static func findBy(_ predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
        let fetchRequest = NSFetchRequest<Self>(entityName: Self.className)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetched: [Self] = try context.fetch(fetchRequest) as [Self]
            return fetched.first
        } catch {
            debugPrint("\(error)")
        }
        return nil
    }

    static func create(context: NSManagedObjectContext) -> Self? {
        if let object = NSEntityDescription.insertNewObject(forEntityName: self.className, into: context) as? Self {
            context.insert(object)
            return object
        }
        return nil
    }

}

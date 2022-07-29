//
//  CoreData.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import CoreData

class CoreData: NSObject {

    static var shared = CoreData()

    var persistentContainer: NSPersistentContainer!
    var storeURL: URL!

    override init() {
        super.init()
        
        do {
            storeURL = try FileManager.default.url(for: .applicationSupportDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true).appendingPathComponent("Justclean.store")
        } catch {
            fatalError("Unable to get path to Application Support directory")
        }
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        persistentContainer = NSPersistentContainer(name: "Justclean")
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                if let url = description.url {
                    do {
                        try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: description.type)
                        self.persistentContainer.loadPersistentStores(completionHandler: { description, error in
                            if let error = error as NSError? {
                                fatalError("Unresolved error \(error), \(error.userInfo)")
                            }
                        })
                    } catch {
                        print(error)
                    }
                }
                print(error)
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
            }
            //completion?(error)
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        })
    }
    
    var newContext: NSManagedObjectContext {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

}

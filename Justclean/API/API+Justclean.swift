//
//  API+Justclean.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import Foundation

extension API {
    
    static var justclean = API("https://justclean.com")
    
    struct Laundry: Codable {
        var id: Int?
        var name: String?
        var photo: String?
        var items: [Item] = []
    }
    
    struct Item: Codable {
        var name: String?
        var price: Double?
    }
    
    
    struct ResponseV1: Codable {
        var code: Int?
        var status: String?
        var data: [Laundry]?
    }
    
    struct ResponseV2: Codable {
        
        struct Data: Codable {
            var success: [Laundry]?
        }
        
        var code: Int?
        var data: Data?
    }
    
    func laundries(test: Data?, complete: @escaping ([Laundry]?, Swift.Error?) -> Void) {
        get("laundries") { data, _, error in
            guard let data = test ?? data else {
                complete(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            if let response = try? decoder.decode(ResponseV2.self, from: data) {
                complete(response.data?.success, error)
                return
            }
            
            do {
                let response = try decoder.decode(ResponseV1.self, from: data)
                complete(response.data, error)
            } catch {
                complete(nil, error)
            }
        }
    }
    
}


extension API {
    
    enum Refresh {
        case laundries
    }
    
    func refresh(_ refresh: Refresh, complete: @escaping (Swift.Error?) -> Void) {
        switch refresh {
        case .laundries:
            Self.justclean.laundries(test: testLaundriesV1.data(using: .utf8)) { laundries, error in
                let context = CoreData.shared.newContext
                
                laundries?.forEach { laundry in
                    let predicate = NSPredicate(format: "laundryID = %@", String(describing: laundry.id))
                    let record = Justclean.Laundry.findOrCreateBy(predicate, context: context)
                    record?.with(laundry)
                    
                    laundry.items.forEach { item in
                        let laundryID = String(describing: laundry.id)
                        let predicate = NSPredicate(format: "laundryID = %@ and name = %@", laundryID, item.name ?? "")
                        let record = Justclean.Item.findOrCreateBy(predicate, context: context)
                        record?.with(laundryID, item)
                    }
                }
                
                try? context.save()
                
                DispatchQueue.main.async {
                    complete(error)
                }
            }
        }
    }
    
}



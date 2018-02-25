//
//  DBManager.swift
//  Anton_Duda_SimplePins
//
//  Created by Anton on 2/23/18.
//  Copyright © 2018 Anton Duda. All rights reserved.
//

import Foundation
import CoreData

class DBManager {
    
    static let shared = DBManager()
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Anton_Duda_SimplePins")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: User methods
    
    func currentUser() -> User? {
        do {
            let moc = persistentContainer.viewContext
            
            let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            userFetch.predicate = NSPredicate(format: "isActive == true")
            
            let users = try moc.fetch(userFetch)
            return users.first as? User
        }
        catch {
            return nil
        }
    }
    
    func logOutCurrentUser() {
        guard let user = currentUser() else {return}
        
        user.isActive = false
        saveContext()
    }
    
    func getUser(with id: String) -> User? {
        do {
            let moc = persistentContainer.viewContext
            
            let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            userFetch.predicate = NSPredicate(format: "id == %@", id)

            let users = try moc.fetch(userFetch)
            return users.first as? User
        }
        catch {
            return nil
        }
    }
    
    func makeUserActive(with id: String) {
        guard let user = getUser(with: id) else {return}
        
        user.isActive = true
        saveContext()
    }
    
    func createUser(with id: String) {        
        let moc = persistentContainer.viewContext
        let user = NSEntityDescription.insertNewObject(forEntityName: "User",
                                                       into: moc) as! User
        user.id = id
        user.isActive = true

        saveContext()
    }
    
    // MARK: Pins methods
    
    func getPinsForCurrentUser() -> [Pin]? {
        guard
            let user = currentUser(),
            let pins = user.pins?.allObjects as? [Pin]
        else {
            return nil
        }
        return pins
    }
    
    func addPin(with longitude: Double, and latitude: Double) {
        guard let user = currentUser() else {return}
        
        let moc = persistentContainer.viewContext
        let pin = NSEntityDescription.insertNewObject(forEntityName: "Pin",
                                                      into: moc) as! Pin
        pin.latitude = latitude
        pin.longitude = longitude
        
        user.addToPins(pin)
        
        saveContext()
    }
    
    func removePin(with longitude: Double, and latitude: Double) {
        guard
            let user = currentUser(),
            let pin = getPint(with: longitude, and: latitude)
        else {
            return
        }
        
        user.removeFromPins(pin)
        persistentContainer.viewContext.delete(pin)
    
        saveContext()
    }
    
    func getPint(with longitude: Double, and latitude: Double) -> Pin? {
        guard let user = currentUser() else {return nil}
        if let pins = user.pins as? Set<Pin> {
            return pins.first(where: { $0.latitude == latitude &&
                                       $0.longitude == longitude})
        }
        else {
            return nil
        }
    }
}

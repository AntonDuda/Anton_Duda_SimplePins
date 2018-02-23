//
//  User+CoreDataProperties.swift
//  Anton_Duda_SimplePins
//
//  Created by Anton on 2/23/18.
//  Copyright © 2018 Anton Duda. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var fbToken: String?
    @NSManaged public var id: Int64
    @NSManaged public var isActive: Bool
    @NSManaged public var pins: NSSet?

}

// MARK: Generated accessors for pins
extension User {

    @objc(addPinsObject:)
    @NSManaged public func addToPins(_ value: Pin)

    @objc(removePinsObject:)
    @NSManaged public func removeFromPins(_ value: Pin)

    @objc(addPins:)
    @NSManaged public func addToPins(_ values: NSSet)

    @objc(removePins:)
    @NSManaged public func removeFromPins(_ values: NSSet)

}

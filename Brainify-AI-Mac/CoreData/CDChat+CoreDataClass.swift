//
//  CDChat+CoreDataClass.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 11/12/2025.
//
//

import Foundation
import CoreData

@objc(CDChat)
public class CDChat: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChat> {
        return NSFetchRequest<CDChat>(entityName: "CDChat")
    }

    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var chatJSON: String?
    @NSManaged public var chatName: String?
    @NSManaged public var topic: String?
}

//
//  CDMath+CoreDataProperties.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 12/12/2025.
//
//

import Foundation
import CoreData


extension CDMath {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMath> {
        return NSFetchRequest<CDMath>(entityName: "CDMath")
    }

    @NSManaged public var id: String?
    @NSManaged public var problemText: String?
    @NSManaged public var solution: String?
    @NSManaged public var problemImage: Data?
    @NSManaged public var date: Date?
}

extension CDMath : Identifiable {

}

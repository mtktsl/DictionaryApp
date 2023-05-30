//
//  RecentSearch+CoreDataClass.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 30.05.2023.
//
//

import Foundation
import CoreData

@objc(RecentSearch)
public class RecentSearch: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentSearch> {
        return NSFetchRequest<RecentSearch>(entityName: "RecentSearch")
    }

    @NSManaged public var word: String?
}

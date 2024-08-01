//
//  Transaction+CoreDataProperties.swift
//  FinanceTracker
//
//  Created by Egor Tolmachev on 31.07.2024.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var type: String?
    @NSManaged public var month: Month?

}

extension Transaction : Identifiable {

}

//
//  Month+CoreDataProperties.swift
//  FinanceTracker
//
//  Created by Egor Tolmachev on 31.07.2024.
//
//

import Foundation
import CoreData


extension Month {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Month> {
        return NSFetchRequest<Month>(entityName: "Month")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var monthYear: String?
    @NSManaged public var previousMonthBalance: Double
    @NSManaged public var month: Int16
    @NSManaged public var year: Int16
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension Month {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

extension Month : Identifiable {

}

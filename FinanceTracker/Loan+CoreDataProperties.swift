//
//  Loan+CoreDataProperties.swift
//  FinanceTracker
//
//  Created by Egor Tolmachev on 02.08.2024.
//
//

import Foundation
import CoreData


extension Loan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Loan> {
        return NSFetchRequest<Loan>(entityName: "Loan")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var initialAmount: Double
    @NSManaged public var remainingAmount: Double
    @NSManaged public var interestRate: Double
    @NSManaged public var monthlyPayment: Double
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var termInMonths: Int16
    @NSManaged public var transaction: NSSet?

}

// MARK: Generated accessors for transaction
extension Loan {

    @objc(addTransactionObject:)
    @NSManaged public func addToTransaction(_ value: Transaction)

    @objc(removeTransactionObject:)
    @NSManaged public func removeFromTransaction(_ value: Transaction)

    @objc(addTransaction:)
    @NSManaged public func addToTransaction(_ values: NSSet)

    @objc(removeTransaction:)
    @NSManaged public func removeFromTransaction(_ values: NSSet)

}

extension Loan : Identifiable {

}

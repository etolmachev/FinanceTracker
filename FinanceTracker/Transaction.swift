import Foundation

enum TransactionType {
    case income
    case expense
}

struct Transaction: Identifiable {
    var id = UUID()
    var type: TransactionType
    var amount: Double
    var category: String
    var date: Date
    var isRecurring: Bool
}

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
//    
//    init(type: TransactionType, amount: Double, category: String, date: Date, isRecurring: Bool) {
//        self.type = type
//        self.amount = amount
//        self.category = category
//        self.date = date
//        self.isRecurring = isRecurring
//    }
}

    

//struct Transaction: Identifiable {
//    var id = UUID()
//    var type: TransactionType
//    var amount: Double
//    var category: String
//    var date: Date
//    var isRecurring: Bool
//    
//    init(type: TransactionType, amount: Double, category: String, date: Date, isRecurring: Bool) {
//        self.type = type
//        self.amount = amount
//        self.category = category
//        self.date = date
//        self.isRecurring = isRecurring
//    }
//}

import Foundation

struct MonthYear: Identifiable, Equatable {
    var id = UUID()
    var month: Int
    var year: Int
}

struct Month: Identifiable {
    var monthYear: MonthYear
    var transactions: [Transaction] = []
    
    var id = UUID()
    var previousMonthBalance: Double = 0.0
    
    var monthlyBalance: Double {
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return totalIncome - totalExpense + previousMonthBalance
    }
    
    mutating func addRecurringTransactions(from recurringTransactions: [Transaction]) {
        let filteredTransactions = recurringTransactions.filter { $0.isRecurring }
        self.transactions.append(contentsOf: filteredTransactions)        
    }
}

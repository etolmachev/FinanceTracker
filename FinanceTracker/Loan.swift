import Foundation

struct Loan: Identifiable {
    var id = UUID()
    var initialAmount: Double
    var remainingAmount: Double
    var monthlyPayment: Double
    var interestRate: Double
    var startDate: Date
    var endDate: Date
}

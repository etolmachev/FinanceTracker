import SwiftUI

struct AmortizationScheduleView: View {
    @ObservedObject var loan: Loan

    var body: some View {
        List {
            ForEach(calculateAmortizationSchedule(for: loan), id: \.self) { payment in
                NavigationLink(destination: PaymentDetailView(payment: payment)) {
                    HStack {
                        Text(payment.date, formatter: dateFormatter)
                        Spacer()
                        Text("\(payment.totalPayment, specifier: "%.2f")")
                    }
                }
            }
        }
        .navigationTitle("График платежей")
    }

    private func calculateAmortizationSchedule(for loan: Loan) -> [Payment] {
        let principal = loan.remainingAmount
        let annualRate = loan.interestRate / 100
        let monthlyRate = annualRate / 12
        let termInMonths = loan.termInMonths

        var balance = principal
        var schedule: [Payment] = []

        let dateComponents = DateComponents(month: 1)
        var paymentDate = loan.startDate ?? Date()

        for _ in 0..<Int(termInMonths) {
            let interestPayment = balance * monthlyRate
            let principalPayment = loan.monthlyPayment// + interestPayment
            balance -= principalPayment

            let payment = Payment(date: paymentDate, principal: principalPayment, interest: interestPayment, totalPayment: loan.monthlyPayment)
            schedule.append(payment)

            paymentDate = Calendar.current.date(byAdding: dateComponents, to: paymentDate) ?? paymentDate
        }

        return schedule
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct AmortizationScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AmortizationScheduleView(loan: Loan(context: PersistenceController.preview.container.viewContext))
    }
}

struct Payment: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var principal: Double
    var interest: Double
    var totalPayment: Double

    static func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

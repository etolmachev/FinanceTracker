import SwiftUI
import CoreData

struct EditLoanView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var loan: Loan

    @State private var name: String
    @State private var initialAmount: String
    @State private var remainingAmount: String
    @State private var interestRate: String
    @State private var termInMonths: String
    @State private var startDate: Date

    init(loan: Loan) {
        self.loan = loan
        _name = State(initialValue: loan.name ?? "")
        _initialAmount = State(initialValue: String(loan.initialAmount))
        _remainingAmount = State(initialValue: String(loan.remainingAmount))
        _interestRate = State(initialValue: String(loan.interestRate))
        _termInMonths = State(initialValue: String(loan.termInMonths))
        _startDate = State(initialValue: loan.startDate ?? Date())
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Наименование долга", text: $name)
                TextField("Изначальный размер кредита", text: $initialAmount)
                    .keyboardType(.decimalPad)
                TextField("Текущая задолженность", text: $remainingAmount)
                    .keyboardType(.decimalPad)
                TextField("Процентная ставка", text: $interestRate)
                    .keyboardType(.decimalPad)
                TextField("Срок кредита в месяцах", text: $termInMonths)
                    .keyboardType(.numberPad)
                DatePicker("Дата начала", selection: $startDate, displayedComponents: .date)
            }
            .navigationTitle("Редактировать долг")
            .navigationBarItems(trailing: Button("Сохранить") {
                loan.name = name
                loan.initialAmount = Double(initialAmount) ?? 0
                loan.remainingAmount = Double(remainingAmount) ?? 0
                loan.interestRate = Double(interestRate) ?? 0
                loan.termInMonths = Int16(termInMonths) ?? 0
                loan.startDate = startDate
                loan.monthlyPayment = calculateMonthlyPayment(for: loan)

                try? viewContext.save()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func calculateMonthlyPayment(for loan: Loan) -> Double {
        let principal = loan.remainingAmount
        let annualRate = loan.interestRate / 100
        let monthlyRate = annualRate / 12
        let termInMonths = Double(loan.termInMonths)

        return principal * (monthlyRate * pow(1 + monthlyRate, termInMonths)) / (pow(1 + monthlyRate, termInMonths) - 1)
    }
}

struct EditLoanView_Previews: PreviewProvider {
    static var previews: some View {
        EditLoanView(loan: Loan(context: PersistenceController.preview.container.viewContext))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

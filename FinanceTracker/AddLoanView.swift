import SwiftUI
import CoreData

struct AddLoanView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name: String = ""
    @State private var initialAmount: String = ""
    @State private var remainingAmount: String = ""
    @State private var interestRate: String = ""
    @State private var termInMonths: String = ""
    @State private var startDate: Date = Date()

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
            .navigationTitle("Добавить долг")
            .navigationBarItems(trailing: Button("Сохранить") {
                let newLoan = Loan(context: viewContext)
                newLoan.id = UUID()
                newLoan.name = name
                newLoan.initialAmount = Double(initialAmount) ?? 0
                newLoan.remainingAmount = Double(remainingAmount) ?? 0
                newLoan.interestRate = Double(interestRate) ?? 0
                newLoan.termInMonths = Int16(termInMonths) ?? 0
                newLoan.startDate = startDate
                newLoan.monthlyPayment = calculateMonthlyPayment(for: newLoan)

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

struct AddLoanView_Previews: PreviewProvider {
    static var previews: some View {
        AddLoanView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

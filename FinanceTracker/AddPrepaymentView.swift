import SwiftUI
import CoreData

struct AddPrepaymentView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Loan.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Loan.name, ascending: true)]) var loans: FetchedResults<Loan>

    @State private var selectedLoan: Loan?
    @State private var prepaymentAmount: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Выберите кредит")) {
                    Picker("Кредит", selection: $selectedLoan) {
                        ForEach(loans) { loan in
                            Text(loan.name ?? "").tag(loan as Loan?)
                        }
                    }
                }

                Section(header: Text("Сумма досрочного погашения")) {
                    TextField("Сумма", text: $prepaymentAmount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Досрочное погашение")
            .navigationBarItems(trailing: Button("Сохранить") {
                if let loan = selectedLoan, let amount = Double(prepaymentAmount) {
                    loan.remainingAmount -= amount
                    loan.monthlyPayment = calculateMonthlyPayment(for: loan)
                    try? viewContext.save()
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }

    private func calculateMonthlyPayment(for loan: Loan) -> Double {
        // Формула расчета аннуитетного платежа
        let monthlyRate = loan.interestRate / 12 / 100
        let months = 12.0 * Double(Calendar.current.dateComponents([.year], from: loan.startDate ?? Date(), to: Date()).year ?? 1)
        return loan.remainingAmount * (monthlyRate * pow(1 + monthlyRate, months)) / (pow(1 + monthlyRate, months) - 1)
    }
}

struct AddPrepaymentView_Previews: PreviewProvider {
    static var previews: some View {
        AddPrepaymentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

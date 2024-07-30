import SwiftUI

struct EditTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var amount: String
    @State private var category: String
    @State private var date: Date
    @State private var isRecurring: Bool
    var transaction: Transaction
    var onSave: ((Transaction) -> Void)?

    init(transaction: Transaction, onSave: @escaping (Transaction) -> Void) {
        self.transaction = transaction
        self.onSave = onSave
        _amount = State(initialValue: String(transaction.amount))
        _category = State(initialValue: transaction.category)
        _date = State(initialValue: transaction.date)
        _isRecurring = State(initialValue: transaction.isRecurring)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Категория", text: $category)
                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Дата", selection: $date, displayedComponents: .date)
                Toggle("Ежемесячная", isOn: $isRecurring)
            }
            .navigationTitle("Редактировать транзакцию")
            .navigationBarItems(trailing: Button("Сохранить") {
                if let amount = Double(amount) {
                    let updatedTransaction = Transaction(
                        id: transaction.id,
                        type: transaction.type,
                        amount: amount,
                        category: category,
                        date: date,
                        isRecurring: isRecurring
                    )
                    onSave?(updatedTransaction)
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        EditTransactionView(transaction: Transaction(type: .expense, amount: 50.00, category: "Продукты", date: Date(), isRecurring: false)) { _ in }
    }
}

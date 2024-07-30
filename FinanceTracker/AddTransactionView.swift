import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var type: TransactionType = .expense
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false

    var onSave: ((Transaction) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Picker("Тип", selection: $type) {
                    Text("Расход").tag(TransactionType.expense)
                    Text("Доход").tag(TransactionType.income)
                }
                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Категория", text: $category)
                DatePicker("Дата", selection: $date, displayedComponents: .date)
                Toggle("Ежемесячный", isOn: $isRecurring)
            }
            .navigationTitle("Добавить транзакцию")
            .navigationBarItems(trailing: Button("Сохранить") {
                if let amount = Double(amount) {
                    let transaction = Transaction(type: type, amount: amount, category: category, date: date, isRecurring: isRecurring)
                    onSave?(transaction)
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
    }
}

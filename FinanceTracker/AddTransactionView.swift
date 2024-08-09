import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var type: TransactionType = .expense
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false
    @State private var endDate: Date = Date()
    
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
                Toggle("Повторяющаяся", isOn: $isRecurring)
                if isRecurring {
                    DatePicker("Дата окончания", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Добавить транзакцию")
            .navigationBarItems(trailing: Button("Сохранить") {
                if let amount = Double(amount) {
                    let transaction = Transaction(context: viewContext)
                    transaction.id = UUID()
                    transaction.type = type.rawValue
                    transaction.amount = amount
                    transaction.category = category
                    transaction.date = date
                    transaction.startDate = date
                    transaction.isRecurring = isRecurring
                    if isRecurring {
                        transaction.endDate = endDate
                    }
                    onSave?(transaction)
                    try? viewContext.save()
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

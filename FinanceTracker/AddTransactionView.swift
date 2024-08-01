import SwiftUI
import CoreData

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var amount: Double = 0.0
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false
    @State private var transactionType: String = "expense" // или "income"

    var onAddTransaction: (Transaction) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали транзакции")) {
                    TextField("Категория", text: $category)
                    TextField("Сумма", value: $amount, formatter: NumberFormatter())
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                    Toggle("Повторяющаяся", isOn: $isRecurring)
                    Picker("Тип транзакции", selection: $transactionType) {
                        Text("Доход").tag("income")
                        Text("Расход").tag("expense")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("Добавить транзакцию")
            .navigationBarItems(trailing: Button("Сохранить") {
                let newTransaction = Transaction(context: viewContext)
                newTransaction.id = UUID()
                newTransaction.amount = amount
                newTransaction.category = category
                newTransaction.date = date
                newTransaction.isRecurring = isRecurring
                newTransaction.transactionType = TransactionType(rawValue: transactionType) ?? .expense
                onAddTransaction(newTransaction)
                do {
                    try viewContext.save()
                } catch {
                    print("Ошибка при сохранении транзакции: \(error)")
                }
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView { _ in }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

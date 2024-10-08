import SwiftUI
import CoreData

struct EditTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var amount: String
    @State private var category: String
    @State private var date: Date
    @State private var isRecurring: Bool
    @State private var transactionType: TransactionType
    @State private var showDeleteConfirmation = false
    @State private var endDate: Date
    var transaction: Transaction
    var onSave: ((Transaction) -> Void)?
    var onDelete: ((Transaction) -> Void)?
    
    init(transaction: Transaction, onSave: @escaping (Transaction) -> Void, onDelete: @escaping (Transaction) -> Void) {
        self.transaction = transaction
        self.onSave = onSave
        self.onDelete = onDelete
        //_type = State(initialValue: TransactionType(rawValue: transaction.type ?? "") ?? .expense)
        _amount = State(initialValue: String(transaction.amount))
        _category = State(initialValue: transaction.category ?? "")
        _date = State(initialValue: transaction.date ?? Date())
        _isRecurring = State(initialValue: transaction.isRecurring)
        _transactionType = State(initialValue: transaction.transactionType ?? .expense)
        _endDate = State(initialValue: transaction.endDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Категория", text: $category)
                    TextField("Сумма", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                    Toggle("Ежемесячная", isOn: $isRecurring)
                    Picker("Тип транзакции", selection: $transactionType) {
                        Text("Доход").tag(TransactionType.income)
                        Text("Расход").tag(TransactionType.expense)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Удалить транзакцию") {
                        showDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
//                    TextField("Сумма", text: $amount)
//                        .keyboardType(.decimalPad)
//                    TextField("Категория", text: $category)
//                    DatePicker("Дата", selection: $date, displayedComponents: .date)
//                    Toggle("Повторяющаяся", isOn: $isRecurring)
                    if isRecurring {
                        DatePicker("Дата окончания", selection: $endDate, displayedComponents: .date)
                    }
                }
                .navigationTitle("Редактировать транзакцию")
                .navigationBarItems(trailing: Button("Сохранить") {
                    if let amount = Double(amount) {
                        transaction.type = transactionType.rawValue
                        transaction.amount = amount
                        transaction.category = category
                        transaction.date = date
                        transaction.isRecurring = isRecurring
                        if isRecurring {
                            transaction.endDate = endDate
                        }
                        onSave?(transaction)
                        try? viewContext.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                })
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Удалить транзакцию?"),
                        message: Text("Это действие нельзя будет отменить."),
                        primaryButton: .destructive(Text("Удалить")) {
                            onDelete?(transaction)
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
}

//struct EditTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTransactionView(
//            transaction: Transaction(),
//            onSave: { _ in },
//            onDelete: { _ in }
//        )
//        EditTransactionView(transaction: Transaction(context: PersistenceController.preview.container.viewContext)) { _ in }
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

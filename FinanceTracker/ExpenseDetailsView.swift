import SwiftUI
import CoreData

extension Transaction {
    var transactionType: TransactionType {
        get {
            TransactionType(rawValue: type ?? "") ?? .expense
        }
        set {
            type = newValue.rawValue
        }
    }
}

struct ExpenseDetailsView: View {
    @Binding var transactions: [Transaction]
    @State private var selectedTransaction: Transaction?
    @State private var showingEditTransaction = false

    var body: some View {
        NavigationView {
            List {
                ForEach(transactions.filter { $0.transactionType == .expense }) { transaction in
                    HStack {
                        Text(transaction.category ?? "")
                        Spacer()
                        Text("\(transaction.amount, specifier: "%.2f")")
                    }
                    .onTapGesture {
                        selectedTransaction = transaction
                        showingEditTransaction.toggle()
                    }
                }
            }
            .navigationTitle("Расходы")
            .sheet(isPresented: $showingEditTransaction) {
                if let transaction = selectedTransaction {
                    EditTransactionView(
                        transaction: transaction,
                        onSave: { updatedTransaction in
                            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                                transactions[index] = updatedTransaction
                            }
                        },
                        onDelete: { transactionToDelete in
                            if let index = transactions.firstIndex(where: { $0.id == transactionToDelete.id }) {
                                transactions.remove(at: index)
                                transactionToDelete.managedObjectContext?.delete(transactionToDelete)
                                try? transactionToDelete.managedObjectContext?.save()
                            }
                        }
                    )
                }
            }
        }
    }
}

struct ExpenseDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailsView(transactions: .constant([
            Transaction(context: PersistenceController.preview.container.viewContext)
        ]))
    }
}

import SwiftUI
import CoreData

struct IncomeDetailsView: View {
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)], predicate: NSPredicate(format: "type == %@", "income")) var incomeTransactions: FetchedResults<Transaction>
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var transactions: [Transaction]
    @State private var showingEditTransaction = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedTransactionIndex: Int?

    var body: some View {
        NavigationView {
            List {
                ForEach(transactions.filter { $0.transactionType == .income }) { transaction in
                    HStack {
                        Text(transaction.category ?? "")
                        Spacer()
                        Text("\(transaction.amount, specifier: "%.2f")")
                    }
                    .onTapGesture {
                        selectedTransaction = transaction
                        selectedTransactionIndex = transactions.firstIndex(where: { $0.id == transaction.id })
                        showingEditTransaction = true
                    }
                }
            }
            .navigationTitle("Доходы")
            .sheet(isPresented: $showingEditTransaction) {
                if let transaction = selectedTransaction, let index = selectedTransactionIndex {
                    EditTransactionView(
                        transaction: transaction,
                        onSave: { updatedTransaction in
                            transactions[index] = updatedTransaction
                            try? viewContext.save()
                        },
                        onDelete: { transactionToDelete in
                            if let index = transactions.firstIndex(where: { $0.id == transactionToDelete.id }) {
                                transactions.remove(at: index)
                                viewContext.delete(transactionToDelete)
                                try? viewContext.save()
                            }
                        }
                    )
                }
            }
        }
    }
}

//struct IncomeDetailsView_Previews: PreviewProvider {
//    @State static var transactions = [
//        Transaction(id: UUID(), type: .income, amount: 100.0, category: "ЗП", date: Date(), isRecurring: false)
//    ]
//
//    static var previews: some View {
//        IncomeDetailsView(transactions: .constant(transactions))
//    }
//}

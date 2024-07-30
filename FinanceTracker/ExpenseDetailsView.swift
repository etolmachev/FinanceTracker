import SwiftUI

struct ExpenseDetailsView: View {
    @Binding var transactions: [Transaction]
    @State private var selectedTransaction: Transaction?
    @State private var showingEditTransaction = false

    var body: some View {
        NavigationView {
            List {
                ForEach(transactions.filter {$0.type == .expense}) { transaction in
                    HStack {
                        Text(transaction.category)
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
                    EditTransactionView(transaction: transaction) { updatedTransaction in
                        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                            transactions[index] = updatedTransaction
                        }
                    }
                }
            }
        }
    }
}

struct ExpenseDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailsView(transactions: .constant([
            Transaction(type: .expense, amount: 50.00, category: "Продукты", date: Date(), isRecurring: false)
        ]))
    }
}

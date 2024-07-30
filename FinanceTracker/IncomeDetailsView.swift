import SwiftUI

struct IncomeDetailsView: View {
    @Binding var transactions: [Transaction]
    @State private var showingEditTransaction = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedTransactionIndex: Int?

    var body: some View {
        List {
            ForEach(transactions.filter { $0.type == .income }) { transaction in
                HStack {
                    Text(transaction.category)
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
                EditTransactionView(transaction: transaction) { updatedTransaction in
                    transactions[index] = updatedTransaction
                }
            }
        }
    }
}

struct IncomeDetailsView_Previews: PreviewProvider {
    @State static var transactions = [
        Transaction(id: UUID(), type: .income, amount: 100.0, category: "ЗП", date: Date(), isRecurring: false)
    ]

    static var previews: some View {
        IncomeDetailsView(transactions: .constant(transactions))
    }
}

import SwiftUI

struct IncomeDetailsView: View {
    @Binding var transactions: [Transaction]
    @State private var selectedTransaction: Transaction?
    @State private var showingEditTransaction = false

    var body: some View {
        NavigationView {
            List {
                ForEach(transactions) { transaction in
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
            .navigationTitle("Доходы")
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

struct IncomeDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeDetailsView(transactions: .constant([
            Transaction(type: .income, amount: 1000.00, category: "Зарплата", date: Date(), isRecurring: true)
        ]))
    }
}

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
        .sheet(isPresented: $showingEditTransaction) {
            if let transaction = selectedTransaction, let index = selectedTransactionIndex {
                EditTransactionView(transaction: transaction) { updatedTransaction in
                    transactions[index] = updatedTransaction

                    //                    transactions[index].id = updatedTransaction.id
//                    transactions[index].amount = updatedTransaction.amount
//                    transactions[index].category = updatedTransaction.category
//                    transactions[index].date = updatedTransaction.date
//                    transactions[index].isRecurring = updatedTransaction.isRecurring
//                    transactions[index].type = updatedTransaction.type
                    
//                    transactions.remove(at: index)
//                    transactions.append(updatedTransaction)
                    
//                    print("из транзакций")
//                    print(transactions[index].id)
//                    print(transactions[index].type)
//                    print(transactions[index].amount)
//                    print(transactions[index].category)
//                    print(transactions[index].date)
//                    print(transactions[index].isRecurring)
//                    print("/n")
//                    print("из updatedTransaction")
//                    print(updatedTransaction.id)
//                    print(updatedTransaction.type)
//                    print(updatedTransaction.amount)
//                    print(updatedTransaction.category)
//                    print(updatedTransaction.date)
//                    print(updatedTransaction.isRecurring)
                }
            }
        }
        .navigationTitle("Доходы")
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

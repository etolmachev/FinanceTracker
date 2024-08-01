import SwiftUI
import CoreData

struct LoanListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Loan.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Loan.name, ascending: true)]
    ) var loans: FetchedResults<Loan>
    
    @Binding var selectedMonthYear: MonthYear

    @State private var showingAddLoan = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Долги")) {
                        ForEach(loans) { loan in
                            NavigationLink(destination: LoanDetailView(loan: loan)) {
                                HStack {
                                    Text(loan.name ?? "")
                                    Spacer()
                                    Text("\(calculateRemainingBalance(for: loan, asOf: selectedMonthYear), specifier: "%.2f")")
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let loan = loans[index]
                                viewContext.delete(loan)
                            }
                            try? viewContext.save()
                        }
                    }
                    
                    Section(header: Text("Сумма остатков по долгам")) {
                        HStack {
                            Text("Общая сумма:")
                            Spacer()
                            Text("\(calculateTotalRemainingBalance(), specifier: "%.2f")")
                        }
                    }
                }
                .navigationTitle("Долги")
                .navigationBarItems(trailing: Button(action: {
                    showingAddLoan.toggle()
                }) {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $showingAddLoan) {
                    AddLoanView().environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func calculateRemainingBalance(for loan: Loan, asOf monthYear: MonthYear) -> Double {
        let totalMonthsElapsed = monthsBetween(startDate: loan.startDate ?? Date(), endDate: monthYear.date)
        let monthlyPayment = loan.monthlyPayment
        let interestRate = loan.interestRate / 100 / 12
        var remainingBalance = loan.remainingAmount
        
        for _ in 0..<totalMonthsElapsed {
            let interestPayment = remainingBalance * interestRate
            let principalPayment = monthlyPayment// - interestPayment
            remainingBalance -= principalPayment
        }
        
        return max(remainingBalance, 0)
    }

    private func monthsBetween(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: startDate, to: endDate)
        return components.month ?? 0
    }

    private func calculateTotalRemainingBalance() -> Double {
        return loans.reduce(0) { $0 + calculateRemainingBalance(for: $1, asOf: selectedMonthYear) }
    }
}

extension MonthYear {
    var date: Date {
        let components = DateComponents(year: year, month: month)
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct LoanListView_Previews: PreviewProvider {
    static var previews: some View {
        LoanListView(selectedMonthYear: .constant(MonthYear(month: 3, year: 2024))).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

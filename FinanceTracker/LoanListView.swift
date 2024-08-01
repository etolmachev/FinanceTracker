import SwiftUI
import CoreData

struct LoanListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Loan.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Loan.name, ascending: true)]
    ) var loans: FetchedResults<Loan>

    @State private var showingAddLoan = false
    @State private var selectedLoan: Loan?

    var body: some View {
        NavigationView {
            List {
                ForEach(loans) { loan in
                    NavigationLink(destination: LoanDetailView(loan: loan)) {
                        HStack {
                            Text(loan.name ?? "")
                            Spacer()
                            Text("\(loan.monthlyPayment, specifier: "%.2f")")
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

struct LoanListView_Previews: PreviewProvider {
    static var previews: some View {
        LoanListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

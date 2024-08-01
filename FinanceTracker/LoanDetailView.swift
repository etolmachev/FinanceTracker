import SwiftUI
import CoreData

struct LoanDetailView: View {
    @ObservedObject var loan: Loan
    @State private var showingEditLoan = false
    @State private var showingAmortizationSchedule = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Информация о кредите")) {
                Text("Наименование долга: \(loan.name ?? "")")
                Text("Изначальный размер кредита: \(loan.initialAmount, specifier: "%.2f")")
                Text("Текущая задолженность: \(loan.remainingAmount, specifier: "%.2f")")
                Text("Процентная ставка: \(loan.interestRate, specifier: "%.2f")%")
                Text("Ежемесячный платеж: \(loan.monthlyPayment, specifier: "%.2f")")
                Text("Дата начала: \(loan.startDate ?? Date(), formatter: dateFormatter)")
            }
            Button("График платежей") {
                showingAmortizationSchedule.toggle()
            }
            .sheet(isPresented: $showingAmortizationSchedule) {
                AmortizationScheduleView(loan: loan)
            }

            Button("Закрыть кредит") {
                // логика закрытия кредита
            }
            .foregroundColor(.red)
            
            Button("Удалить кредит") {
                deleteLoan()
            }
            .foregroundColor(.red)
        }
        .navigationTitle(loan.name ?? "")
        .navigationBarItems(trailing: Button("Редактировать") {
            showingEditLoan.toggle()
        })
        .sheet(isPresented: $showingEditLoan) {
            EditLoanView(loan: loan)
        }
    }

    private func deleteLoan() {
        viewContext.delete(loan)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting loan: \(error.localizedDescription)")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct LoanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LoanDetailView(loan: Loan(context: PersistenceController.preview.container.viewContext))
    }
}

import SwiftUI

struct AddMonthView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentMonth: Int
    @State private var currentYear: Int

    var lastMonthYear: MonthYear
    var onAddMonth: (MonthYear) -> Void
    var allRecurringTransactions: [Transaction]

    init(lastMonthYear: MonthYear, onAddMonth: @escaping (MonthYear) -> Void, allRecurringTransactions: [Transaction]) {
        self.lastMonthYear = lastMonthYear
        self.onAddMonth = onAddMonth
        self.allRecurringTransactions = allRecurringTransactions
        
        if lastMonthYear.month == 12 {
            _currentMonth = State(initialValue: 1)
            _currentYear = State(initialValue: lastMonthYear.year + 1)
        } else {
            _currentMonth = State(initialValue: lastMonthYear.month + 1)
            _currentYear = State(initialValue: lastMonthYear.year)
        }
    }

    var body: some View {
        VStack {
            Text("Добавить месяц")
                .font(.largeTitle)
            
            Form {
                Section(header: Text("Следующий месяц")) {
                    Text("Месяц: \(currentMonth)")
                    Text("Год: \(currentYear)")
                }
            }
            
            Button(action: {
                let newMonthYear = MonthYear(month: currentMonth, year: currentYear)
                onAddMonth(newMonthYear)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Добавить")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

struct AddMonthView_Previews: PreviewProvider {
    static var previews: some View {
        AddMonthView(
            lastMonthYear: MonthYear(month: 8, year: 2024),
            onAddMonth: { _ in },
            allRecurringTransactions: []
        )
    }
}

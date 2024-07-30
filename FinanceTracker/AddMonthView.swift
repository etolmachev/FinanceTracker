import SwiftUI

struct AddMonthView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentMonth: Int = 1
    @State private var currentYear: Int = 2024

    var lastMonthYear: MonthYear
    var onAddMonth: (MonthYear) -> Void
    var allRecurringTransactions: [Transaction]
    //var addRecurringTransactions: ([Month], [Transaction]) -> Void

    init(lastMonthYear: MonthYear, onAddMonth: @escaping (MonthYear) -> Void, allRecurringTransactions: [Transaction]) {
        self.lastMonthYear = lastMonthYear
        self.onAddMonth = onAddMonth
        self.allRecurringTransactions = allRecurringTransactions
//        self.addRecurringTransactions = addRecurringTransactions

        // Calculate the next month and year
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
                    Text("Год: \(String(currentYear))")
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
        AddMonthView(lastMonthYear: MonthYear(month: 8, year: 2024), onAddMonth: { _ in }, allRecurringTransactions: [])
    }
}

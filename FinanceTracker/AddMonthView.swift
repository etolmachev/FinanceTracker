//import SwiftUI
//
//struct AddMonthView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var monthName: String = ""
//    @State private var monthIndex: Int = 0
//    var onAddMonth: ((Month) -> Void)?
//
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Название месяца", text: $monthName)
//                TextField("Индекс месяца", value: $monthIndex, formatter: NumberFormatter())
//            }
//            .navigationTitle("Добавить месяц")
//            .navigationBarItems(trailing: Button("Сохранить") {
//                let newMonth = Month(monthYear: monthName)
//                onAddMonth?(newMonth)
//                presentationMode.wrappedValue.dismiss()
//            })
//        }
//    }
//}
//
//struct AddMonthView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddMonthView()
//    }
//}

import SwiftUI

struct AddMonthView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var newMonthYear: String = getNextMonthYear()
    var onAddMonth: ((Month) -> Void)?
    var allRecurringTransactions: [Transaction] = []

    var body: some View {
        NavigationView {
            Form {
                TextField("Месяц и год (например, Aug 2024)", text: $newMonthYear)
            }
            .navigationTitle("Добавить месяц")
            .navigationBarItems(trailing: Button("Добавить") {
                let newMonth = Month(monthYear: newMonthYear)
                onAddMonth?(newMonth)
                // Добавляем повторяющиеся транзакции в новый месяц
                var months = [Month]()
                addRecurringTransactions(to: &months, from: allRecurringTransactions)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

func getNextMonthYear() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    let date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    return formatter.string(from: date)
}


struct AddMonthView_Previews: PreviewProvider {
    static var previews: some View {
        AddMonthView()
    }
}

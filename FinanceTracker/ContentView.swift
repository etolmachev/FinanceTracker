import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Month.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Month.year, ascending: true),
            NSSortDescriptor(keyPath: \Month.month, ascending: true)
        ]
    ) var months: FetchedResults<Month>

    @State private var sortedMonths: [Month] = []
    @State private var selectedMonthIndex = 0
    @State private var showingAddTransaction = false
    @State private var showingAddMonth = false
    @State private var showingIncomeDetails = false
    @State private var showingExpenseDetails = false
    @State private var recurringTransactions: [Transaction] = []
    @State private var showingDeleteConfirmation = false
    @State private var showingLoans = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedMonthYear: MonthYear = MonthYear(month: 8, year: 2024) // Инициализация переменной

    private var currentMonth: Month? {
        guard !months.isEmpty, selectedMonthIndex < months.count else { return nil }
        return months[selectedMonthIndex]
    }

    private var totalIncome: Double {
        currentMonth?.transactionsArray.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount } ?? 0.0
    }

    private var totalExpenses: Double {
        currentMonth?.transactionsArray.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount } ?? 0.0
    }

    private var monthlyBalance: Double {
        calculateMonthlyBalance(for: selectedMonthIndex, in: Array(months))
    }

    private var previousMonthBalance: Double {
        guard selectedMonthIndex > 0 else { return 0 }
        return calculateMonthlyBalance(for: selectedMonthIndex - 1, in: Array(months))
    }

    var body: some View {
        VStack {
            if months.isEmpty {
                Text("Нет данных. Добавьте месяц.")
            } else {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Доходы")
                                .font(.headline)
                                .padding()

                            Text("\(totalIncome, specifier: "%.2f")")
                                .font(.largeTitle)
                                .padding()
                        }
                        .frame(width: 170, height: 150)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .onTapGesture {
                            showingIncomeDetails.toggle()
                        }
                        .sheet(isPresented: $showingIncomeDetails) {
                            if let currentMonth = currentMonth {
                                IncomeDetailsView(transactions: .constant(currentMonth.transactionsArray.filter { $0.transactionType == .income }))
                            } else {
                                EmptyView()
                            }
                        }.onDisappear(){
                            updateAllMonthlyBalances()
                        }

                        Spacer()

                        VStack(alignment: .leading) {
                            Text("Расходы")
                                .font(.headline)
                                .padding()

                            Text("\(totalExpenses, specifier: "%.2f")")
                                .font(.largeTitle)
                                .padding()
                        }
                        .frame(width: 170, height: 150)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .onTapGesture {
                            showingExpenseDetails.toggle()
                        }
                        .sheet(isPresented: $showingExpenseDetails) {
                            if let currentMonth = currentMonth {
                                ExpenseDetailsView(transactions: .constant(currentMonth.transactionsArray.filter { $0.transactionType == .expense }))
                            } else {
                                EmptyView()
                            }
                        }.onDisappear(){
                            updateAllMonthlyBalances()
                        }
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Остаток на начало месяца")
                                    .font(.headline)
                                Text("\(previousMonthBalance, specifier: "%.2f")")
                                    .font(.title)
                            }
                            Spacer()
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Остаток в этом месяце")
                                    .font(.headline)
                                Text("\(monthlyBalance, specifier: "%.2f")")
                                    .font(.largeTitle)
                            }
                            Spacer()
                        }

                    }
                    .padding()

                    Button(action: {
                        showingAddTransaction.toggle()
                    }) {
                        Text("Добавить транзакцию")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                    .sheet(isPresented: $showingAddTransaction) {
                        if let currentMonth = currentMonth {
                            AddTransactionView { transaction in
                                
                                if !transaction.isRecurring {
                                    currentMonth.addToTransactions(transaction)
                                }
                                
//                                if transaction.isRecurring {
//                                    recurringTransactions.append(transaction)
//                                }
                                try? viewContext.save()
                                updateAllMonthlyBalances()
                            }
                            .environment(\.managedObjectContext, viewContext)
                        } else {
                            EmptyView()
                        }
                    }

                    if months.count > 1 && selectedMonthIndex == months.count - 1 {
                        Button(action: {
                            showingDeleteConfirmation.toggle()
                        }) {
                            Text("Удалить этот месяц")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                        }
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(
                                title: Text("Подтверждение удаления"),
                                message: Text("Вы уверены, что хотите удалить этот месяц?"),
                                primaryButton: .destructive(Text("Удалить")) {
                                    deleteCurrentMonth()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }

                    Button(action: {
                        showingLoans.toggle()
                    }) {
                        Text("Долги")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                    .sheet(isPresented: $showingLoans) {
                        LoanListView(selectedMonthYear: $selectedMonthYear).environment(\.managedObjectContext, viewContext)
                    }
                }
                .navigationTitle("Финансовый обзор")
                .padding(.bottom, 60)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sortedMonths.indices, id: \.self) { index in
                            Button(action: {
                                selectedMonthIndex = index
                                selectedMonthYear = MonthYear(month: Int(months[index].monthYear?.split(separator: ".")[0] ?? "1") ?? 1, year: Int(months[index].monthYear?.split(separator: ".")[1] ?? "2024") ?? 2024)
                            }) {
                                Text(months[index].monthYear ?? "")
                                    .padding()
                                    .background(selectedMonthIndex == index ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedMonthIndex == index ? .white : .black)
                                    .cornerRadius(10)
                            }
                        }

                        Button(action: {
                            showingAddMonth.toggle()
                            updateSortedMonths()
                        }) {
                            Text("+")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddMonth) {
            if let lastMonthYear = sortedMonths.last?.monthYear {
                AddMonthView(
                    lastMonthYear: MonthYear(month: Int(lastMonthYear.split(separator: ".")[0])!, year: Int(lastMonthYear.split(separator: ".")[1])!),
                    onAddMonth: { newMonthYear in
                        let newMonth = Month(context: viewContext)
                        
                        newMonth.id = UUID()
                        newMonth.monthYear = "\(newMonthYear.month).\(newMonthYear.year)"
                        newMonth.month = Int32(newMonthYear.month)
                        newMonth.year = Int32(newMonthYear.year)
                        newMonth.previousMonthBalance = 0
                        
//                        let calendar = Calendar.current
//                        let startDateComponents = calendar.dateComponents([.year, .month], from: sortedMonths.last!.startDate!)
//                        let endDateComponents = calendar.dateComponents([.year, .month], from: sortedMonths.last!.endDate!)
                        
                        newMonth.startDate = Calendar.current.date(byAdding: .month, value: 1, to: sortedMonths.last!.startDate!)!
                        newMonth.endDate = Calendar.current.date(byAdding: .month, value: 1, to: newMonth.startDate!)!
                        addRecurringTransactions(to: newMonth)
                        updateAllMonthlyBalances()

                        try? viewContext.save()

                        updateSortedMonths()

                    },
                    allRecurringTransactions: recurringTransactions
                )
            }
        }
        .onAppear {
            if months.isEmpty {
                addInitialData()
            }
            updateAllMonthlyBalances()
            updateSortedMonths()
            // Очистка всех данных при запуске
//            clearAllData()
        }
    }

    private func deleteCurrentMonth() {
        guard months.count > 1 else {
            return
        }
        let monthToDelete = months[selectedMonthIndex]
        viewContext.delete(monthToDelete)
        try? viewContext.save()
        selectedMonthIndex = min(selectedMonthIndex, months.count - 1)
        updateAllMonthlyBalances()
    }

    private func updateAllMonthlyBalances() {
        for month in months {
            addRecurringTransactions(to: month)
        }
        recurringTransactions.removeAll()
        for index in months.indices {
            _ = calculateMonthlyBalance(for: index, in: Array(months))
        }
    }

    private func calculateMonthlyBalance(for index: Int, in months: [Month]) -> Double {
        guard index < months.count else { return 0 }

        let previousBalance = (index > 0) ? calculateMonthlyBalance(for: index - 1, in: months) : 0

        let currentBalance = months[index].transactionsArray.reduce(0) { $0 + ($1.transactionType == .income ? $1.amount : -$1.amount) }

        return currentBalance + previousBalance
    }

    private func addInitialData() {
        let initialMonth = Month(context: viewContext)
        initialMonth.id = UUID()
        initialMonth.monthYear = "8.2024"
        initialMonth.month = 8
        initialMonth.year = 2024
        initialMonth.previousMonthBalance = 0.0
        initialMonth.startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 8))!
        initialMonth.endDate = Calendar.current.date(byAdding: .month, value: 1, to: initialMonth.startDate!)!

        // Пример транзакции
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = 100.0
        transaction.category = "Salary"
        transaction.date = Date()
        transaction.isRecurring = false
        transaction.transactionType = .income
        initialMonth.addToTransactions(transaction)

        try? viewContext.save()
    }

    private func clearAllData() {
        print("ПРОИЗОШЛА ПОЛНАЯ ОЧИСТКА ТРАНЩАКЦИЙ И МЕСЯЦЕВ")
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Month.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        try? viewContext.execute(batchDeleteRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        try? viewContext.execute(batchDeleteRequest2)
    }
    
    private func updateSortedMonths() {
        print("called months sort ")
        sortedMonths = months.sorted {
            let components1 = $0.monthYear?.split(separator: ".").compactMap { Int($0) }
            let components2 = $1.monthYear?.split(separator: ".").compactMap { Int($0) }
            guard let year1 = components1?.last, let month1 = components1?.first,
                  let year2 = components2?.last, let month2 = components2?.first else { return false }
            if year1 == year2 {
                return month1 < month2
            } else {
                return year1 < year2
            }
        }
        print(sortedMonths)
    }
    
    func addRecurringTransactions(to month: Month) {
        //let viewContext = container.viewContext
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        //fetchRequest.predicate = NSPredicate(format: "isRecurring == YES AND startDate >= %@ AND endDate <= %@", month.startDate! as NSDate, month.endDate! as NSDate)
//        print(month.startDate)
//        print(month.endDate)
        do {
            let transactions = try viewContext.fetch(fetchRequest)
            
            print("recurring Transactions found " + String(transactions.filter{$0.isRecurring == true}.count))
            
            for transaction in transactions.filter{$0.isRecurring == true} {
                print(transaction.startDate)
                print(transaction.endDate)
                print("\n")

                if(transaction.startDate != nil && transaction.endDate != nil){ // заменить на isRecurring?
                    //if(month.startDate! >= transaction.startDate! && month.endDate! <= transaction.endDate!){
                    print(month.month)
                    print(month.year)
                    print(transaction.amount)
                    print(isMonthBetweenDates(month: Int(month.month), year: Int(month.year), startDate: transaction.startDate, endDate: transaction.endDate))
                    print("\n")
                    
                    if(isMonthBetweenDates(month: Int(month.month), year: Int(month.year), startDate: transaction.startDate, endDate: transaction.endDate)){
                        //if(transaction.startDate! >= month.startDate! && transaction.endDate! <= month.endDate!){
//                        if(!month.transactions?.contains(where: { transaction in
//                            transaction.id == transaction.id})){
                        if let monthTransactions = month.transactions?.allObjects as? [Transaction] {
                            print("ids in month")
                            for trans in monthTransactions {
                                print(trans.id)
                            }
                            print("id to add")
                            print(transaction.id)
                            print("\n")
                            if !monthTransactions.contains(where: { $0.id == transaction.id }) || monthTransactions.count == 0 {
                                print("добавляю")
                                print("\n")

                                let newTransaction = Transaction(context: viewContext)
                                newTransaction.id = transaction.id
                                newTransaction.amount = transaction.amount
                                newTransaction.category = transaction.category
                                newTransaction.date = month.startDate! // или установить соответствующую дату в пределах месяца
                                newTransaction.isRecurring = transaction.isRecurring
                                newTransaction.transactionType = transaction.transactionType
                                newTransaction.endDate = transaction.endDate
                                
                                month.addToTransactions(newTransaction)
                            }
                        }
                        
                    }
                }
            }
            try viewContext.save()
        } catch {
            fatalError("Failed to fetch recurring transactions: \(error)")
        }
    }
}

//func addRecurringTransactions(to months: inout [Month], from allRecurringTransactions: [Transaction]) {
//    guard months.count > 1 else {
//        return
//    }
//    for index in 1..<months.count {
//        months[index].addRecurringTransactions(from: allRecurringTransactions)
//    }
//}

extension Month {
    var transactionsArray: [Transaction] {
        let set = transactions as? Set<Transaction> ?? []
        return set.sorted {
            $0.date ?? Date() < $1.date ?? Date()
        }
    }

//    func addRecurringTransactions(from allRecurringTransactions: [Transaction]) {
//        for transaction in allRecurringTransactions {
//            let newTransaction = Transaction(context: self.managedObjectContext!)
//            newTransaction.id = UUID()
//            newTransaction.amount = transaction.amount
//            newTransaction.category = transaction.category
//            newTransaction.date = transaction.date
//            newTransaction.isRecurring = transaction.isRecurring
//            newTransaction.transactionType = transaction.transactionType
//            self.addToTransactions(newTransaction)
//        }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

func isMonthBetweenDates(month: Int, year: Int, startDate: Date?, endDate: Date?) -> Bool {
    guard let startDate = startDate, let endDate = endDate else {
        return false
    }
    
    let calendar = Calendar.current
    let startMonth = calendar.component(.month, from: startDate)
    let endMonth = calendar.component(.month, from: endDate)
    let startYear = calendar.component(.year, from: startDate)
    let endYear = calendar.component(.year, from: endDate)
    
    print ("год окончания транзакции " + String(endYear))
    // Проверка, что месяц находится между стартовым и конечным месяцами
    if(year < endYear){
        return true
    }
    else{
        return month >= startMonth && month <= endMonth
    }
}

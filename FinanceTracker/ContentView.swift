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

    @State private var selectedMonthIndex = 0
    @State private var showingAddTransaction = false
    @State private var showingAddMonth = false
    @State private var showingIncomeDetails = false
    @State private var showingExpenseDetails = false
    @State private var recurringTransactions: [Transaction] = []
    @State private var showingDeleteConfirmation = false
    @State private var selectedTransaction: Transaction?
    @State private var nextMonthYear: MonthYear?

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
                                currentMonth.addToTransactions(transaction)
                                if transaction.isRecurring {
                                    recurringTransactions.append(transaction)
                                }
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
                }
                .navigationTitle("Финансовый обзор")
                .padding(.bottom, 60)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(months.indices, id: \.self) { index in
                            Button(action: {
                                selectedMonthIndex = index
                            }) {
                                Text("\(months[index].month).\(months[index].year)")
                                    .padding()
                                    .background(selectedMonthIndex == index ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedMonthIndex == index ? .white : .black)
                                    .cornerRadius(10)
                            }
                        }

                        Button(action: {
                            showingAddMonth.toggle()
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
            if let lastMonth = months.last {
                AddMonthView(
                    lastMonthYear: MonthYear(month: Int(lastMonth.month), year: Int(lastMonth.year)),
                    onAddMonth: { newMonthYear in
                        let newMonth = Month(context: viewContext)
                        newMonth.id = UUID()
                        newMonth.monthYear = "\(newMonthYear.month).\(newMonthYear.year)"
                        newMonth.month = Int16(newMonthYear.month)
                        newMonth.year = Int16(newMonthYear.year)
                        newMonth.previousMonthBalance = 0
                        try? viewContext.save()
                        updateAllMonthlyBalances()
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
            //clearAllData()
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
        var mutableMonths = Array(months)
        addRecurringTransactions(to: &mutableMonths, from: recurringTransactions)
        recurringTransactions.removeAll()
        for index in mutableMonths.indices {
            _ = calculateMonthlyBalance(for: index, in: mutableMonths)
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
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Month.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        try? viewContext.execute(batchDeleteRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        try? viewContext.execute(batchDeleteRequest2)
    }
}

func addRecurringTransactions(to months: inout [Month], from allRecurringTransactions: [Transaction]) {
    guard months.count > 1 else {
        return
    }
    for index in 1..<months.count {
        months[index].addRecurringTransactions(from: allRecurringTransactions)
    }
}

extension Month {
    var transactionsArray: [Transaction] {
        let set = transactions as? Set<Transaction> ?? []
        return set.sorted {
            $0.date ?? Date() < $1.date ?? Date()
        }
    }

    func addRecurringTransactions(from allRecurringTransactions: [Transaction]) {
        for transaction in allRecurringTransactions {
            let newTransaction = Transaction(context: self.managedObjectContext!)
            newTransaction.id = UUID()
            newTransaction.amount = transaction.amount
            newTransaction.category = transaction.category
            newTransaction.date = transaction.date
            newTransaction.isRecurring = transaction.isRecurring
            newTransaction.transactionType = transaction.transactionType
            self.addToTransactions(newTransaction)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

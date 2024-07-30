import SwiftUI

struct ContentView: View {
    @State private var months: [Month] = [Month(monthYear: MonthYear(month: 8, year: 2024), transactions: [
        Transaction(type: .income, amount: 100.0, category: "зп", date: Date(), isRecurring: false)
    ])]
    @State private var selectedMonthIndex = 0
    @State private var showingAddTransaction = false
    @State private var showingAddMonth = false
    @State private var showingIncomeDetails = false
    @State private var showingExpenseDetails = false
    @State private var recurringTransactions: [Transaction] = []
    @State private var showingDeleteConfirmation = false

    private var currentMonth: Month {
        months[selectedMonthIndex]
    }

    private var totalIncome: Double {
        currentMonth.transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        currentMonth.transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var monthlyBalance: Double {
        calculateMonthlyBalance(for: selectedMonthIndex)
    }

    private var previousMonthBalance: Double {
        guard selectedMonthIndex > 0 else { return 0 }
        return calculateMonthlyBalance(for: selectedMonthIndex - 1)
    }

    var body: some View {
        VStack {
            // Main Content
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
                    .frame(width: 170, height: 150) // Square size
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .onTapGesture {
                        showingIncomeDetails.toggle()
                    }
                    .sheet(isPresented: $showingIncomeDetails) {
                        IncomeDetailsView(transactions: $months[selectedMonthIndex].transactions)
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
                    .frame(width: 170, height: 150) // Square size
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .onTapGesture {
                        showingExpenseDetails.toggle()
                    }
                    .sheet(isPresented: $showingExpenseDetails) {
                        ExpenseDetailsView(transactions: $months[selectedMonthIndex].transactions)
                    }.onDisappear(){
                        updateAllMonthlyBalances()
                    }
                }
                .padding()

                VStack(alignment: .leading) {
                    Text("Остаток на начало месяца")
                        .font(.headline)
                    Text("\(previousMonthBalance, specifier: "%.2f")")
                        .font(.title)
                    
                    Text("Остаток в этом месяце")
                        .font(.headline)
                    Text("\(monthlyBalance, specifier: "%.2f")")
                        .font(.largeTitle)
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
                    AddTransactionView { transaction in
                        months[selectedMonthIndex].transactions.append(transaction)
                        // Добавляем транзакцию в список повторяющихся, если это повторяющаяся транзакция
                        if transaction.isRecurring {
                            recurringTransactions.append(transaction)
                            print("кол-во потор транзакций адейт" + " " + String(recurringTransactions.count))
                        }
                        updateAllMonthlyBalances()
                    }
                }
                
                if months.count > 1 && selectedMonthIndex == months.count-1 {
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
            .padding(.bottom, 60) // Add padding to avoid overlap with the month scroller
            
            // Horizontal Scroll for Months
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(months.indices, id: \.self) { index in
                        Button(action: {
                            selectedMonthIndex = index
                        }) {
                            Text(String(months[index].monthYear.month) + " " + String(months[index].monthYear.year))
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
        .navigationTitle("Финансовый обзор")
        .sheet(isPresented: $showingAddMonth) {
            if let lastMonthYear = months.last?.monthYear {
                
                AddMonthView(
                    lastMonthYear: lastMonthYear,
                    onAddMonth: { newMonthYear in
                        let newMonth = Month(monthYear: newMonthYear, transactions: [])
                        months.append(newMonth)
                        // Обновляем все месяцы с повторяющимися транзакциями
                        //addRecurringTransactions(to: &months, from: recurringTransactions)
                        updateAllMonthlyBalances()
                }, allRecurringTransactions: recurringTransactions)
            }
        }
        .onAppear {
            updateAllMonthlyBalances()
        }
    }

    private func deleteCurrentMonth() {
        guard months.count > 1 else {
            // Ensure that we always have at least one month
            return
        }
        months.remove(at: selectedMonthIndex)
        selectedMonthIndex = min(selectedMonthIndex, months.count - 1)
        updateAllMonthlyBalances()
    }

    private func updateAllMonthlyBalances() {
        addRecurringTransactions(to: &months, from: recurringTransactions)
        recurringTransactions.removeAll()
        for index in months.indices {
            _ = calculateMonthlyBalance(for: index)
        }
    }

    private func calculateMonthlyBalance(for index: Int) -> Double {
        guard index < months.count else { return 0 }
        
        let previousBalance = (index > 0) ? calculateMonthlyBalance(for: index - 1) : 0
        
        let currentBalance = months[index].transactions.reduce(0) { $0 + ($1.type == .income ? $1.amount : -$1.amount) }
        
        return currentBalance + previousBalance
    }
}

func getCurrentMonthYear() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter.string(from: Date())
}


func addRecurringTransactions(to months: inout [Month], from allRecurringTransactions: [Transaction]) {
    // Проверяем, есть ли в массиве months хотя бы два элемента
    guard months.count > 1 else {
        print("Недостаточно месяцев для добавления повторяющихся транзакций.")
        return
    }
    
    // Итерация по месяцам начиная со второго
    for index in 1..<months.count {
        months[index].addRecurringTransactions(from: allRecurringTransactions)
        print(index)
        print("trans count" + " " + String(allRecurringTransactions.count))
        print("/n")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

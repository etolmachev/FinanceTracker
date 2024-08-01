import SwiftUI

struct PaymentDetailView: View {
    var payment: Payment

    var body: some View {
        VStack {
            Text("Дата: \(payment.date, formatter: dateFormatter)")
            Text("Основной долг: \(payment.principal, specifier: "%.2f")")
            Text("Проценты: \(payment.interest, specifier: "%.2f")")
            Text("Общий платеж: \(payment.totalPayment, specifier: "%.2f")")
        }
        .navigationTitle("Детали платежа")
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct PaymentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentDetailView(payment: Payment(date: Date(), principal: 500, interest: 50, totalPayment: 550))
    }
}

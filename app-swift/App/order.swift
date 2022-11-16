import Foundation
import RealmSwift

class order: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: Int
    @Persisted var customer: order_customer?
    @Persisted var customerId: String
    @Persisted var employee: order_employee?
    @Persisted var employeeId: Int
    @Persisted var freight: Double
    @Persisted var orderDate: Date
    @Persisted var orderDetails: List<order_orderDetails>
    @Persisted var requiredDate: Date?
    @Persisted var shipAddress: String
    @Persisted var shipCity: String
    @Persisted var shipCountry: String
    @Persisted var shipName: String
    @Persisted var shipPostalCode: String
    @Persisted var shipRegion: String
    @Persisted var shipVia: Int
    @Persisted var shippedDate: Date
}

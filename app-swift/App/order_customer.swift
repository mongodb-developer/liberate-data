import Foundation
import RealmSwift

class order_customer: EmbeddedObject {
    @Persisted var companyName: String?

    @Persisted var contactName: String?

    @Persisted var contactTitle: String?

    @Persisted var customerId: String?

    @Persisted var phone: String?
}

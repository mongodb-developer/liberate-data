import Foundation
import RealmSwift

class order_employee: EmbeddedObject {
    @Persisted var employeeId: Int?

    @Persisted var firstName: String?

    @Persisted var lastName: String?

    @Persisted var notes: String?

    @Persisted var title: String?
}

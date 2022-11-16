import Foundation
import RealmSwift

class order_orderDetails_product: EmbeddedObject {
    @Persisted var categoryId: Int?

    @Persisted var productId: Int?

    @Persisted var productName: String?

    @Persisted var quantityPerUnit: String?
}

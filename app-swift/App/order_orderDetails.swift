import Foundation
import RealmSwift

class order_orderDetails: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var discount: Double?

    @Persisted var product: order_orderDetails_product?

    @Persisted var productId: Int?

    @Persisted var quantity: Int?

    @Persisted var unitPrice: Double?
}

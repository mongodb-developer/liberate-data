import SwiftUI
import RealmSwift

/// Instantiate a new Item object, let the user input a ``summary``, and then
/// append it to the ``items`` collection to add it to the Item list.
struct CreateItemView: View {
    // The ``items`` ObservedResults collection is the
    // entire list of Item objects in the realm.
    @ObservedResults(
        order.self,
        sortDescriptor: {SortDescriptor(keyPath: "_id", ascending: false)}()
    ) var items
    
    // Create a new Realm Item object.
    @State private var newItem = order()
    @State private var newOrderDetails = order_orderDetails()
    
    
    // We've passed in the ``creatingNewItem`` variable
    // from the ItemsView to know when the user is done
    // with the new Item and we should return to the ItemsView.
    @Binding var isInCreateItemView: Bool
    
    @State var user: User
    
    @State var customerId = ""
    @State var employeeId = 0
    @State var freight = 0.00
    @State var orderDate = Date()
    @State var shipAddress = ""
    @State var shipCity = ""
    @State var shipCountry = ""
    @State var shipPostalCode = ""
    @State var shipRegion = ""
    @State var shipVia = 0
    @State var productId = 0
    @State var quantity = 0
    @State var unitPrice = 0.00

    var body: some View {
        
        let lastOrderId = items.first?._id ?? 10000
            
        Form {
//            Section(header: Text("Customer ID")) {
//                // Accessing the observed item object lets us update the live object
//                // No need to explicitly update the object in a write transaction
//                TextField("Customer ID", text: $customerId)
//            }
            Section(header: Text("Shipping Address")) {
                TextField("Shipping Address", text: $shipAddress)
            }
            Section(header: Text("Freight")) {
                TextField("Freight", value: $freight, format: .number)
            }
            Section(header: Text("Order Date")) {
                TextField("Order Date", value: $orderDate, format: .dateTime)
            }
            Section(header: Text("City")) {
                TextField("City", text: $shipCity)
            }
            Section(header: Text("Country")) {
                TextField("Country", text: $shipCountry)
            }
            Section(header: Text("Postal Code")) {
                TextField("Postal Code", text: $shipPostalCode)
            }
            // Order Details
            Section(header: Text("Product ID")) {
                TextField("Product ID", value: $productId, format: .number)
            }
            Section(header: Text("Quantity")) {
                TextField("Quantity", value: $quantity, format: .number)
            }
            Section(header: Text("Unit Price")) {
                TextField("Unit Price", value: $unitPrice, format: .number)
            }
            
            Section {
                Button(action: {
//                    newItem.owner_id = user.id
                    // To avoid updating too many times and causing Sync-related
                    // performance issues, we only assign to the `newItem.summary`
                    // once when the user presses `Save`.
                    newItem.orderDetails = List()
                    newItem.orderDetails.append(newOrderDetails)
                    newItem._id = lastOrderId
                    newItem._id += 1
                    newItem.customerId = customerId
                    newItem.employeeId = employeeId
                    newItem.freight = freight
                    newItem.orderDate = orderDate
                    newItem.shipAddress = shipAddress
                    newItem.shipCity = shipCity
                    newItem.shipCountry = shipCountry
                    newItem.shipPostalCode = shipPostalCode
                    newItem.shipRegion = shipRegion
                    newItem.shipVia = shipVia
                    newOrderDetails.unitPrice = unitPrice
                    newOrderDetails.productId = productId
                    newOrderDetails.quantity = quantity
                    
                    // Appending the new Item object to the ``items``
                    // ObservedResults collection adds it to the
                    // realm in an implicit write.
                    $items.append(newItem)
                    
                    // Now we're done with this view, so set the
                    // ``isInCreateItemView`` variable to false to
                    // return to the ItemsView.
                    isInCreateItemView = false
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
                Button(action: {
                    // If the user cancels, we don't want to
                    // append the new object we created to the
                    // task list, so we set the ``isInCreateItemView``
                    // value to false to return to the ItemsView.
                    isInCreateItemView = false
                }) {
                    HStack {
                        Spacer()
                        Text("Cancel")
                        Spacer()
                    }
                }
            }
        }
        .navigationBarTitle("Add Order")
    }
}

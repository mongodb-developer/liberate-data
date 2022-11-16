import SwiftUI
import RealmSwift

/// Show a detail view of a task Item. User can edit the summary or mark the Item complete.
struct ItemDetail: View {
    // This property wrapper observes the Item object and
    // invalidates the view when the Item object changes.
    @ObservedRealmObject var anOrder: order    
    
    var body: some View {
        Form {
            Section(header: Text("Customer ID")) {
                // Accessing the observed item object lets us update the live object
                // No need to explicitly update the object in a write transaction
                TextField("Customer ID", text: $anOrder.customerId)
            }            
            Section(header: Text("Shipping Address")) {
                TextField("Shipping Address", text: $anOrder.shipAddress)
            }
            Section(header: Text("Freight")) {
                TextField("Freight", value: $anOrder.freight, format: .number)
            }
            Section(header: Text("Order Date")) {
                TextField("Order Date", value: $anOrder.orderDate, format: .dateTime)
            }
            Section(header: Text("City")) {
                TextField("City", text: $anOrder.shipCity)
            }
            Section(header: Text("Country")) {
                TextField("Country", text: $anOrder.shipCountry)
            }
            Section(header: Text("Name")) {
                TextField("Name", text: $anOrder.shipName)
            }
            Section(header: Text("Postal Code")) {
                TextField("Postal Code", text: $anOrder.shipPostalCode)
            }
            NavigationLink(destination: OrderDetailsDetailsView(order: anOrder)) {
                Text("Order Details")
            }
            
        }
        .navigationBarTitle("Update Order", displayMode: .inline)
    }
}

import SwiftUI
import RealmSwift

/// Show a detail view of a task Item. User can edit the summary or mark the Item complete.
struct ItemDetail: View {
    // This property wrapper observes the Item object and
    // invalidates the view when the Item object changes.
    @ObservedRealmObject var anOrder: order
    @State var isInEditMode: Bool?
    @State var customerId = ""
    @State var shipAddress = ""
    @State var freight = 0.00
    @State var orderDate = Date()
    @State var shipCity = ""
    @State var shipCountry = ""
    @State var shipName = ""
    @State var shipPostalCode = ""
    
    var body: some View {
        Form {
            Section(header: Text("Customer ID")) {
                // Accessing the observed item object lets us update the live object
                // No need to explicitly update the object in a write transaction
                TextField("Customer ID", text: $customerId)
            }
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
            Section(header: Text("Name")) {
                TextField("Name", text: $shipName)
            }
            Section(header: Text("Postal Code")) {
                TextField("Postal Code", text: $shipPostalCode)
            }
            NavigationLink(destination: OrderDetailsDetailsView(order: anOrder)) {
                Text("Order Details")
            }
            
            Section {
                            Button(action: {
                                $anOrder.customerId.wrappedValue = customerId
                                $anOrder.shipAddress.wrappedValue = shipAddress
                                $anOrder.freight.wrappedValue = freight
                                $anOrder.orderDate.wrappedValue = orderDate
                                $anOrder.shipCity.wrappedValue = shipCity
                                $anOrder.shipCountry.wrappedValue = shipCountry
                                $anOrder.shipName.wrappedValue = shipName
                                $anOrder.shipPostalCode.wrappedValue = shipPostalCode
                                isInEditMode = false
                                
                            }) {HStack{
                                Spacer()
                                Text("Save")
                                Spacer()
                                
                            }}
                            Button(action: {
                                // If the user cancels, we don't want to update the Realm object
                                isInEditMode = true
                                customerId = anOrder.customerId
                                shipAddress = anOrder.shipAddress
                                freight = anOrder.freight
                                orderDate = anOrder.orderDate
                                shipCity = anOrder.shipCity
                                shipCountry = anOrder.shipCountry
                                shipName = anOrder.shipName
                                shipPostalCode = anOrder.shipPostalCode
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Cancel")
                                    Spacer()
                                }
                            }
                        }
            
        }.onAppear(perform:{
            isInEditMode = true
            customerId = anOrder.customerId
            shipAddress = anOrder.shipAddress
            freight = anOrder.freight
            orderDate = anOrder.orderDate
            shipCity = anOrder.shipCity
            shipCountry = anOrder.shipCountry
            shipName = anOrder.shipName
            shipPostalCode = anOrder.shipPostalCode
            
        })
        .navigationBarTitle("Order: \(anOrder._id)", displayMode: .inline)
    }
}

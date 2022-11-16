//
//  OrderDetailsDetails.swift
//  App
//
//  Created by Mark Franklin on 11/8/22.
//

import SwiftUI
import RealmSwift

struct OrderDetailsDetails: View {
    @ObservedRealmObject var anOrderDetails: order_orderDetails
    
    var body: some View {
        Form {
            Section(header: Text("Quantity")) {
                TextField("Quantity", value: $anOrderDetails.quantity, format: .number)
            }
            Section(header: Text("Product ID")) {
                TextField("Product ID", value: $anOrderDetails.productId, format: .number)
            }
            Section(header: Text("Unit Price")) {
                TextField("Unit Price", value: $anOrderDetails.unitPrice, format: .currency(code: "USD"))
            }
        }.navigationBarBackButtonHidden()
        .navigationBarTitle("Update Order Details")
        
    }
}

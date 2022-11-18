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
    @State var quantity = 0
    @State var productId = 0
    @State var unitPrice = 0.00
    
    var body: some View {
        Form {
            Section(header: Text("Quantity")) {
                TextField("Quantity", value: $quantity, format: .number)
            }
            Section(header: Text("Product ID")) {
                TextField("Product ID", value: $productId, format: .number)
            }
            Section(header: Text("Unit Price")) {
                TextField("Unit Price", value: $unitPrice, format: .currency(code: "USD"))
            }
            
            Section {
                Button(action: {
                    $anOrderDetails.quantity.wrappedValue = quantity
                    $anOrderDetails.productId.wrappedValue = productId
                    $anOrderDetails.unitPrice.wrappedValue = unitPrice
                    
                }) {HStack {
                    Spacer()
                    Text("Save")
                    Spacer()
                    
                }}
                Button(action: {
                    quantity = anOrderDetails.quantity ?? 0
                    productId = anOrderDetails.productId ?? 0
                    unitPrice = anOrderDetails.unitPrice ?? 0.00
                    
                }) {HStack {
                    Spacer()
                    Text("Cancel")
                    Spacer()
                    
                }}
            }
            
            
            
        }.onAppear(perform: {
            quantity = anOrderDetails.quantity ?? 0
            productId = anOrderDetails.productId ?? 0
            unitPrice = anOrderDetails.unitPrice ?? 0.00
        })
        .navigationBarBackButtonHidden()
        .navigationBarTitle("Update Order Details")
        
    }
}

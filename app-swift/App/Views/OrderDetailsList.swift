//
//  OrderDetailsList.swift
//  App
//
//  Created by Mark Franklin on 11/8/22.
//

import SwiftUI
import RealmSwift

struct OrderDetailsList: View {
    @ObservedRealmObject var order: order    
    var body: some View {
        VStack {
            List {
                ForEach(order.orderDetails) {
                    orderDetails in OrderDetailsRow(orderDetails: orderDetails)
                }
            }.listStyle(InsetListStyle())
            Spacer()
        }
    }
}

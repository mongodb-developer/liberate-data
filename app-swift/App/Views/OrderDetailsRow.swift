//
//  OrderDetailsRow.swift
//  App
//
//  Created by Mark Franklin on 11/7/22.
//

import SwiftUI
import RealmSwift

struct OrderDetailsRow: View {
    @ObservedRealmObject var orderDetails: order_orderDetails
    var body: some View {
        NavigationLink(destination: OrderDetailsDetails(anOrderDetails: orderDetails)) {
            Text(String(orderDetails.productId ?? 0))
            Spacer()
        }
    }
}

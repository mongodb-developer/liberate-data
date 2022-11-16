//
//  OrderDetailsDetailsView.swift
//  App
//
//  Created by Mark Franklin on 11/14/22.
//

import SwiftUI
import RealmSwift

struct OrderDetailsDetailsView: View {
    @ObservedRealmObject var order: order
    var body: some View {
        NavigationView {
            VStack {
                OrderDetailsList(order: order)
            }
        }
    }
}

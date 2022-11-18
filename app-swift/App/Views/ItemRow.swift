import SwiftUI
import RealmSwift

struct ItemRow: View {
    @ObservedRealmObject var item: order
    @State var isInEditMode = false
    
    var body: some View {
        NavigationLink(destination: ItemDetail(anOrder: item)) {
            Text(String(item._id))
            Spacer()
        }
    }
}

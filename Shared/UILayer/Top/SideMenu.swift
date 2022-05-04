import SwiftUI

struct SidebarMainView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            QueryView()
        }
    }
}

struct SidebarView: View {
    var body: some View {
        List {
            ForEach(TabModel.views, id: \.title) { model in
                NavigationLink(destination: model.destination) {
                    Label(model.title, systemImage: model.image)
                }
            }
        }
        .listStyle(.sidebar)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}

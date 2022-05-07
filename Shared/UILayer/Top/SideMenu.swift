import SwiftUI
import Resolver

struct SidebarMainView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            Resolver.resolve([TabModel].self)[1].destination
        }
    }
}

struct SidebarView: View {
    var body: some View {
        List {
            ForEach(Resolver.resolve([TabModel].self), id: \.title) { model in
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
        Resolver.registerMockServices()
        return SidebarMainView()
    }
}

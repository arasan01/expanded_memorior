import SwiftUI
import Resolver

struct TabMainView: View {
    
    var body: some View {
        TabView {
            ForEach(Resolver.resolve([TabModel].self), id: \.title) { model in
                model.destination
                    .tabItem {
                        Image(systemName: model.image)
                        Text(model.title.uppercased())
                    }
            }
        }
        .accentColor(.accentColor)
    }
}

struct TabMainView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerMockServices()
        return TabMainView()
    }
}

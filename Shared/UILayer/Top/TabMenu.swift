import SwiftUI

struct TabMainView: View {
    var body: some View {
        TabView {
            ForEach(TabModel.views, id: \.title) { model in
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
        TabMainView()
    }
}

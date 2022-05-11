import SwiftUI
import Resolver

struct TabModel {
    var title: String
    var image: String
    var destination: AnyView
    
    init<V>(title: String, image: String, destination: V) where V: View {
        self.title = title
        self.image = image
        self.destination = AnyView(destination)
    }
    
    static var views: [TabModel] {
        [
            TabModel(title: "Calender", image: "calendar.circle", destination: CalendarView()),
            TabModel(title: "Query", image: "greaterthan.circle", destination: QueryView(model: Resolver.resolve())),
            TabModel(title: "Setting", image: "gear.circle", destination: SettingsView())
        ]
    }
}

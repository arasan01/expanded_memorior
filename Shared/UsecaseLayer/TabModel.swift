import SwiftUI

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
        let models = [
            TabModel(title: "Calender", image: "calendar.circle.fill", destination: CalendarView()),
            TabModel(title: "Query", image: "greaterthan.circle.fill", destination: QueryView()),
            TabModel(title: "Setting", image: "exclamationmark.circle.fill", destination: SettingsView())
        ]
        return models
    }
}

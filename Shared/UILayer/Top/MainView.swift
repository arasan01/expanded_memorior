import SwiftUI

struct MainView: View {
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    
    var body: some View {
#if os(macOS)
        SidebarMainView().frame(minWidth: 360)
#else
        if horizontalSizeClass == .compact {
            TabMainView()
        } else {
            SidebarMainView()
        }
#endif
    }
}

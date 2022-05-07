//
//  ProgrammableCalenderApp.swift
//  Shared
//
//  Created by 新山響生 on 2022/05/03.
//

import SwiftUI
import Resolver

@main
struct ProgrammableCalenderApp: App {
    
    @Injected var database: DatabaseProtocol
    
    init() {
        try! database.defineScheme()
        #if DEBUG
        database.debugSection()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

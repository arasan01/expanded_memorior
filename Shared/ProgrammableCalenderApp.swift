//
//  ProgrammableCalenderApp.swift
//  Shared
//
//  Created by 新山響生 on 2022/05/03.
//

import SwiftUI

@main
struct ProgrammableCalenderApp: App {
    let dbModel = try! Database()
    
    init() {
        try! dbModel.defineScheme()
        (0..<5).forEach { _ in try! dbModel.insertTest() }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(dbModel)
        }
    }
}

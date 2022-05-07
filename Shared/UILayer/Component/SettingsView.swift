//
//  SettingsView.swift
//  ProgrammableCalender
//
//  Created by 新山響生 on 2022/05/05.
//

import SwiftUI
import Resolver

struct SettingsView: View {
    @Injected var db: DatabaseProtocol
    
    var body: some View {
        Form {
            Section {
                Button {
                    try! db.insertTest()
                } label: {
                    Text("Insert Test")
                }

            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerMockServices()
        return SettingsView()
    }
}

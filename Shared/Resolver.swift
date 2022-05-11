//
//  Resolver.swift
//  ProgrammableCalender
//
//  Created by 新山響生 on 2022/05/07.
//

import SwiftUI
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { try! Database() as DatabaseProtocol }.scope(.application)
        register { QueryViewModel(code: .init(), output: .init()) }.scope(.cached)
        register([TabModel].self) { TabModel.views }
    }
}

extension Resolver {
    public static func registerMockServices() {
        register { try! MockDatabase() as DatabaseProtocol }
        register([TabModel].self) {
            [
                TabModel(title: "Sample 1", image: "calendar.circle", destination: Text("Text")),
                TabModel(title: "Sample 2", image: "greaterthan.circle", destination: Text("Query")),
                TabModel(title: "Sample 3", image: "gear.circle", destination: Text("Setting"))
            ]
        }
    }
}

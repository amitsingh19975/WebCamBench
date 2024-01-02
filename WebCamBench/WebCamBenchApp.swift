//
//  WebCamBenchApp.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import SwiftUI
import SwiftData

@main
struct WebCamBenchApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
//            DeviceInfo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private let viewModel = CameraDeviceModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}

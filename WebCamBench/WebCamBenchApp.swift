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
    private let viewModel = CameraDeviceModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

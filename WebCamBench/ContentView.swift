//
//  ContentView.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject private var viewModel: CameraDeviceModel

    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.currentSelectedDevice) {
                ForEach(viewModel.devices, id: \.uniqueID) { device in
                    DeviceView(device: device)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        DispatchQueue.main.async {
                            viewModel.searchDevices()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
            }
            Button {
                viewModel.currentSelectedDevice = nil
            } label: {
                Label("Clear Select", systemImage: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .padding(.all)
        } detail: {
            if let device = viewModel.currentSelectedDevice {
                DeviceContentView(device: device)
                    .environmentObject(viewModel)
            } else {
                Text("Select an item")
            }
        }.task {
            let status = await viewModel.isAuthorized
            if status {
                DispatchQueue.main.async {
                    viewModel.searchDevices()
                }
            }
        }.alert(isPresented: Binding(get: {
            viewModel.error != nil
        }, set: { v in
            viewModel.error = nil
        })) {
            Alert(title: Text("Error"), message: Text(viewModel.error!))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CameraDeviceModel())
}

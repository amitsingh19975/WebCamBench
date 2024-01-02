//
//  ContentView.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CameraDeviceModel.self) private var viewModel
    @Query private var devicesInfo: [DeviceInfo]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.devices, id: \.uniqueID) { device in
                    DeviceView(device: device)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.searchDevices()
                    } label: {
                        Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
            }
            Button {
                DispatchQueue.main.async {
                    viewModel.benchmark?.stopSession()
                    viewModel.currentSelectedDevice = nil
                }
            } label: {
                Label("Clear Select", systemImage: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .padding(.all)
        } detail: {
            if viewModel.currentSelectedDevice != nil {
                DeviceContentView(device: Binding(get: {
                    viewModel.currentSelectedDevice
                }, set: { v in
                    viewModel.currentSelectedDevice = v
                }), viewModel: viewModel)
            } else {
                Text("Select an item")
            }
        }.task {
            let status = await viewModel.isAuthorized
            if status {
                viewModel.searchDevices()
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
        .modelContainer(for: DeviceInfo.self, inMemory: true)
        .environment(CameraDeviceModel())
}

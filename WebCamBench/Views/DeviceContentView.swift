//
//  DeviceContentView.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import Foundation
import AVFoundation
import SwiftUI

struct DeviceContentView: View {
    private static let SAMPLE_FRAME_NUMBER: Int64 = 10
    @State var viewModel: CameraDeviceModel
    var device: Binding<AVCaptureDevice?>
    
    @State private var disablePreview = true
    
    init(device: Binding<AVCaptureDevice?>, viewModel: CameraDeviceModel) {
        self.device = device
        self.viewModel = viewModel
        self.viewModel.totalSamples = 0
        self.viewModel.fps = 0
    }
    
    var body: some View {
        if let device = device.wrappedValue {
            if viewModel.isBenchmarkRunning {
                deviceView(device)
            } else {
                VStack {
                    ProgressView()
                    Text("Please wait...")
                }.padding(.all)
                    .onAppear(perform: {
                        startBenchmark(for: device)
                    })
            }
        } else {
            Text("No Device")
        }
    }
    
    private func deviceView(_ device: AVCaptureDevice) -> some View {
        return VStack(alignment: .center, spacing: 1) {
            if let benchmark = viewModel.benchmark {
                if disablePreview {
                    Color(.black)
                        .padding()
                } else {
                    PlayerContainerView(captureSession: benchmark.captureSession)
                        .padding()
                }
                HStack(alignment: .center, spacing: 2) {
                    Spacer()
                    DeviceMetricLabelView(title: "Total Samples Taken", value: "\(viewModel.totalSamples)")
                    Spacer()
                    DeviceMetricLabelView(title: "Average FPS", value: String(format: "%.2f", viewModel.fps))
                    Spacer()
                    VStack(spacing: 8) {
                        Button(disablePreview ? "Enable Preview" : "Disable Preview") {
                            disablePreview = !disablePreview
                        }
                        Button(viewModel.isBenchmarkRunning ? "Stop" : "Start") {
                            if viewModel.isBenchmarkRunning {
                                DispatchQueue.main.async {
                                    self.viewModel.benchmark?.stopSession()
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.viewModel.fps = 0
                                    self.viewModel.totalSamples = 0
                                    self.viewModel.benchmark?.startSession()
                                }
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            } else {
                Text("Unable to start benchmarking")
            }
        }
        .padding(.all)
    }
    
    private func startBenchmark(for device: AVCaptureDevice) {
        DispatchQueue.main.async {
            self.viewModel.benchmark?.stopSession()
            do {
                self.viewModel.benchmark = try Benchmark(device: device, sampleframes: Self.SAMPLE_FRAME_NUMBER) { fps in
                    let oldSamples = Double(viewModel.totalSamples)
                    viewModel.totalSamples += 1
                    viewModel.fps = (fps + (viewModel.fps * oldSamples)) / Double(viewModel.totalSamples)
                }
                self.viewModel.benchmark?.startSession()
            } catch {
                viewModel.error = error.localizedDescription
                print("Error: ", error)
            }
        }
    }
}

#Preview {
    let viewModel = CameraDeviceModel()
    viewModel.searchDevices()
    viewModel.currentSelectedDevice = viewModel.devices[0]
    return DeviceContentView(device: Binding(get: {
        viewModel.currentSelectedDevice
    }, set: { v in
        viewModel.currentSelectedDevice = v
    }), viewModel: viewModel)
}

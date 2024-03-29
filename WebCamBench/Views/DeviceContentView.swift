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
    @EnvironmentObject private var viewModel: CameraDeviceModel
    let device: AVCaptureDevice
    
    @State private var disablePreview = true
    
    var body: some View {
        deviceView(device)
    }
    
    private var resolutionView: some View {
        HStack {
            Text("Resoultion:")
            Menu {
                ForEach(Array(viewModel.supportedResolution), id: \.self) { f in
                    Button {
                        viewModel.currentFormat = f
                    } label: {
                        Text("\(f.resolution.width.description) x \(f.resolution.height.description) | \(f.mediaType)")
                    }

                }
            } label: {
                if let f = viewModel.currentFormat {
                    Text("\(f.resolution.width.description) x \(f.resolution.height.description) | \(f.mediaType)")
                } else {
                    Text("Select a resolution")
                }
            }
            .frame(maxWidth: 300)
            .disabled(viewModel.cameraState != .idle)
            Spacer()
        }
        .padding(.leading)
    }
    
    
    private func deviceView(_ device: AVCaptureDevice) -> some View {
        return VStack(alignment: .center, spacing: 1) {
            resolutionView
            if disablePreview || viewModel.cameraState != .running {
                ZStack {
                    Color(.black)
                        .padding()
                    if viewModel.cameraState == .starting {
                        VStack {
                            ProgressView()
                            Text("Please wait...")
                        }.padding(.all)
                    }
                }
            } else {
                if let benchmark = viewModel.benchmark {
                    PlayerContainerView(captureSession: benchmark.captureSession)
                        .padding()
                } else {
                    Text("Unable to start benchmark")
                }
            }
            HStack(alignment: .center, spacing: 2) {
                Spacer()
                DeviceMetricLabelView(title: "Total Samples Taken", value: viewModel.totalSamples.roundedWithAbbreviations)
                Spacer()
                DeviceMetricLabelView(title: "Average FPS", value: String(format: "%.2f", viewModel.fps))
                Spacer()
                DeviceMetricLabelView(title: "FPS", value: String(format: "%.2f", viewModel.currentFps))
                Spacer()
                VStack(spacing: 8) {
                    Button(disablePreview ? "Enable Preview" : "Disable Preview") {
                        disablePreview = !disablePreview
                    }
                    Button(viewModel.cameraState == .running ? "Stop" : "Start") {
                        if viewModel.cameraState == .running {
                            DispatchQueue.main.async {
                                self.viewModel.benchmark?.stopSession()
                                if let benchmark = viewModel.benchmark {
                                    benchmark.stopSession()
                                }
                            }
                        } else {
                            self.viewModel.reset()
                            DispatchQueue.main.async {
                                self.viewModel.cameraState = .starting
                                if let benchmark = viewModel.benchmark {
                                    benchmark.startSession()
                                } else {
                                    startBenchmark(for: device)
                                }
                            }
                        }
                    }.disabled(viewModel.cameraState == .starting)
                }
                Spacer()
            }
            Spacer()
        }.padding(.all)
    }
    
    private func startBenchmark(for device: AVCaptureDevice) {
        DispatchQueue.main.async {
            self.viewModel.benchmark?.stopSession()
            do {
                self.viewModel.benchmark = try Benchmark(device: device, sampleframes: Self.SAMPLE_FRAME_NUMBER) { fps in
                    viewModel.updateFps(fps)
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
    return DeviceContentView(device: viewModel.devices[0])
        .environmentObject(viewModel)
}

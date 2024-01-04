//
//  DeviceView.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct DeviceView: View {
    let device: AVCaptureDevice
    @EnvironmentObject private var viewModel: CameraDeviceModel
    
    var body: some View {
        NavigationLink(value: device) {
            DeviceLableView(label: device.localizedName,
                            isSelected: viewModel.currentSelectedDevice == device)
        }
        .onTapGesture {
            DispatchQueue.main.async {
                viewModel.currentSelectedDevice = device
            }
        }
    }
}

#Preview {
    let viewModel = CameraDeviceModel()
    viewModel.searchDevices()
    return DeviceView(device: viewModel.devices[0])
        .environmentObject(viewModel)
}

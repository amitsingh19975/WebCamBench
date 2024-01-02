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
    @Environment(CameraDeviceModel.self) private var viewModel
    
    var body: some View {
        NavigationLink(value: device) {
            DeviceLableView(label: device.localizedName,
                            isSelected: viewModel.currentSelectedDevice == device)
        }
        .onTapGesture {
            viewModel.currentSelectedDevice = device
        }
    }
}

#Preview {
    let viewModel = CameraDeviceModel()
    viewModel.searchDevices()
    return DeviceView(device: viewModel.devices[0])
        .environment(viewModel)
}

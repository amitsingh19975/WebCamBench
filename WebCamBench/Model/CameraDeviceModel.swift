//
//  CameraDevice.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import Foundation
import AVFoundation
import SwiftUI

enum DeviceCameraState {
    case idle, running, starting
}

@MainActor
final class CameraDeviceModel: ObservableObject {
    @Published var devices: [AVCaptureDevice] = []
    @Published private var _currentSelectedDevice: AVCaptureDevice?
    @Published var error: String?
    @Published var benchmark: Benchmark?
    @Published var totalSamples: Int64 = 0
    @Published var fps: Double = 0
    @Published var cameraState: DeviceCameraState = .idle
    
    var currentSelectedDevice: AVCaptureDevice? {
        get {
            _currentSelectedDevice
        }
        set(v) {
            DispatchQueue.main.async {
                if let benchmark = self.benchmark {
                    benchmark.stopSession()
                    self.benchmark = nil
                }
                self._currentSelectedDevice = v
            }
        }
    }
    
    nonisolated init() {
        DispatchQueue.main.async {
            self.observeCameraSessionRunningState()
        }
    }
    
    func observeCameraSessionRunningState() {
        NotificationCenter.default.addObserver(forName: .AVCaptureSessionDidStartRunning, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.cameraState = .running
            }
        }
        
        NotificationCenter.default.addObserver(forName: .AVCaptureSessionDidStopRunning, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.cameraState = .idle
            }
        }
    }
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    func searchDevices() {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera
        ]
        
        if #available(macOS 14.0, *) {
            deviceTypes.append(contentsOf: [
                .continuityCamera,
                .external,
            ])
        } else {
            deviceTypes.append(.externalUnknown)
        }
        
        if #available(macOS 13.0, *) {
            deviceTypes.append(contentsOf: [
                .deskViewCamera
            ])
        }
        
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .unspecified)
        devices = session.devices
    }
    
    nonisolated func reset() {
        DispatchQueue.main.async {
            self.fps = 0
            self.totalSamples = 0
        }
    }
    
    nonisolated func updateFps(_ fps: Double) {
        DispatchQueue.main.async {
            let oldSamples = Double(self.totalSamples)
            self.totalSamples += 1
            self.fps = (fps + (self.fps * oldSamples)) / Double(self.totalSamples)
        }
    }
}

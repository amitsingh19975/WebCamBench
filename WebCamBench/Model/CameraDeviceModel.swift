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

@Observable
final class CameraDeviceModel {
    var devices: [AVCaptureDevice] = []
    private var _currentSelectedDevice: AVCaptureDevice?
    var error: String?
    var benchmark: Benchmark?
    var totalSamples: Int64 = 0
    var fps: Double = 0
    var cameraState: DeviceCameraState = .idle
    
    var currentSelectedDevice: AVCaptureDevice? {
        get {
            _currentSelectedDevice
        }
        set(v) {
            DispatchQueue.main.async {
                self.benchmark?.stopSession()
                self.benchmark = nil
                self._currentSelectedDevice = v
            }
        }
    }
    
    init() {
        observeCameraSessionRunningState()
    }
    
    func observeCameraSessionRunningState() {
        NotificationCenter.default.addObserver(forName: .AVCaptureSessionDidStartRunning, object: nil, queue: nil) { _ in
            self.cameraState = .running
        }
        
        NotificationCenter.default.addObserver(forName: .AVCaptureSessionDidStopRunning, object: nil, queue: nil) { _ in
            self.cameraState = .idle
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
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [
            .builtInWideAngleCamera,
            .continuityCamera,
            .external,
            .deskViewCamera
        ], mediaType: .video, position: .unspecified)
        devices = session.devices
    }
}

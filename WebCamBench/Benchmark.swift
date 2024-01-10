//
//  Benchmark.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class PlayerView: NSView {
    var previewLayer: AVCaptureVideoPreviewLayer
    
    init(captureSession: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        super.init(frame: .zero)
        
        setupLayer()
    }
    
    func setupLayer() {
        previewLayer.frame = self.frame
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.contentsGravity = .resizeAspectFill
        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
        layer = previewLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct PlayerContainerView: NSViewRepresentable {
    let captureSession: AVCaptureSession
    
    init(captureSession: AVCaptureSession) {
        self.captureSession = captureSession
    }
    
    func makeNSView(context: Context) -> PlayerView {
        return PlayerView(captureSession: captureSession)
    }
    
    func updateNSView(_ nsView: PlayerView, context: Context) {}
}

enum BenchmarkError: Error, CustomStringConvertible, LocalizedError {
    case str(String)
    
    var description: String {
        switch self {
        case .str(let s): return s
        }
    }
}

class BenchmarkDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var sampleframes: Int64
    var frameCount: Int64 = 0
    var startTime = DispatchTime.now()
    let updateFps: (Double) -> Void
    
    init(sampleframes: Int64, updateFps: @escaping (Double) -> Void) {
        self.sampleframes = sampleframes
        self.updateFps = updateFps
    }
    
    func resetStartTime() {
        startTime = DispatchTime.now()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCount += 1
        
        if frameCount % sampleframes == 0 {
            let end = DispatchTime.now()
            let diff = Double(end.uptimeNanoseconds - startTime.uptimeNanoseconds)
            resetStartTime()
            let secs = diff * 1e-9
            let fps = Double(frameCount) / secs
            updateFps(fps)
            frameCount = 0
        }
    }
}

@MainActor
final class Benchmark {
    nonisolated let captureSession = AVCaptureSession()
    let device: AVCaptureDevice
    private let ourCameraQueue = DispatchQueue(label: "Benchmark")
    private let delegate: BenchmarkDelegate
    
    init(device: AVCaptureDevice, sampleframes: Int64, updateFps: @escaping (Double) -> Void) throws {
        self.device = device
        self.delegate = BenchmarkDelegate(sampleframes: sampleframes, updateFps: updateFps)
        try prepareCamera()
    }
    
    func startSession() {
        guard !self.captureSession.isRunning else { return }
        self.captureSession.startRunning()
        self.delegate.resetStartTime()
    }

    func stopSession() {
        guard self.captureSession.isRunning else { return }
        self.captureSession.stopRunning()
    }
    
    func prepareCamera() throws {
        captureSession.sessionPreset = .high
        try startSessionForDevice(self.device)
    }
    
    private func startSessionForDevice(_ device: AVCaptureDevice) throws {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            try addInput(input)
        } catch let e as BenchmarkError {
            throw e
        } catch {
            throw BenchmarkError.str("Unable to initialize device: \(device.localizedName)")
        }
        
        let output = AVCaptureVideoDataOutput()
        try addOutput(output)
        
        output.setSampleBufferDelegate(self.delegate, queue: self.ourCameraQueue)
        
    }
    
    private func addInput(_ input: AVCaptureInput) throws {
        guard captureSession.canAddInput(input) == true else {
            throw BenchmarkError.str("Unable to add input device")
        }
        captureSession.addInput(input)
    }
    
    private func addOutput(_ output: AVCaptureVideoDataOutput) throws {
        guard captureSession.canAddOutput(output) == true else {
            throw BenchmarkError.str("Unable to add output device")
        }
        captureSession.addOutput(output)
    }
    
    deinit {
        DispatchQueue.main.async { [weak self] in
            self?.stopSession()
        }
    }
}

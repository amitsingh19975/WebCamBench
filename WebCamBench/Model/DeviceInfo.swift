////
////  Device.swift
////  WebCamBench
////
////  Created by Amit Singh on 02/01/24.
////
//
//import Foundation
//import SwiftData
//
//@Model
//final class DeviceInfo: Identifiable, Hashable {
//    let id: String
//    let name: String
//    let averageOfNFrames: Int
//    var fps: Double
//    var samples: Int64
//    
//    init(id: String, name: String, averageOfNFrames: Int = 10, fps: Double, samples: Int64) {
//        self.id = id
//        self.name = name
//        self.averageOfNFrames = averageOfNFrames
//        self.fps = fps
//        self.samples = samples
//    }
//    
//    func updateFPS(_ nFps: Double) {
//        let oldSamples = samples
//        samples += 1
//        fps = (nFps + (fps * Double(oldSamples))) / Double(samples)
//    }
//}

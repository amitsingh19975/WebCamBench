//
//  DeviceMetricLable.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import Foundation
import SwiftUI

struct DeviceMetricLabelView: View {
    let title: String
    let value: String
    var body: some View {
        VStack {
            Text(title)
                .opacity(0.8)
            Text(value)
                .font(.title)
                .bold()
        }
    }
}

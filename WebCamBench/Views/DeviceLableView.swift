//
//  DeviceLableView.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import Foundation
import SwiftUI

struct DeviceLableView: View {
    let label: String
    var isSelected: Bool
    
    var body: some View {
        let stack = Text(label)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .foregroundStyle(.foreground)
        
        if isSelected {
            stack.background(Color.accentColor)
                .clipShape(.rect(cornerRadius: 5))
        } else {
            stack
                .clipShape(.rect(cornerRadius: 5))
        }
    }
}

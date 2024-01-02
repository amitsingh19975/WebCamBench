//
//  Utils.swift
//  WebCamBench
//
//  Created by Amit Singh on 02/01/24.
//

import Foundation

extension Int64 {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1_000
        let million = number / 1_000_000
        if million >= 1.0 {
            return "\(round(million * 10) / 10)M"
        } else if thousand >= 1.0 {
            return "\(round(thousand * 10) / 10)K"
        } else {
            return "\(self)"
        }
    }
}

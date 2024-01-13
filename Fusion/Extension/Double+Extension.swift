//
//  Double+Extension.swift
//  Fusion
//
//  Created by Matteo Gentili on 05/01/24.
//

import Foundation

extension Double {
    
    func toByte() -> Double {
        // Converti byte a megabyte
        let megabyteValue = self * (1024 * 1024)

        return megabyteValue
    }
    
    func byteToMB() -> Double {
        let mb = self / (1024 * 1024)
        return mb.rounded(to: 2)
    }
    
    func byteToGB() -> Double {
        let gb = self / (1024 * 1024 * 1024)
        return gb.rounded(to: 2)// String(format: "%.2f MB", gb)
    }
}

extension Double {
    func rounded(to decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }
}


extension Double {
    func toFormattedString() -> String {
        return String(format: "%.1f", self)
    }
}

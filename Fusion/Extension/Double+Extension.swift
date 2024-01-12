//
//  Double+Extension.swift
//  Fusion
//
//  Created by Matteo Gentili on 05/01/24.
//

import Foundation

extension Double {
    
    func toMB() -> String {
        // Converti byte a megabyte
        let megabyteValue = self / (1024)
        // Formatta il risultato con due cifre decimali dopo la virgola
        let formattedValue = String(format: "%.2f MB", megabyteValue)

        return formattedValue
    }
    
    func toByte() -> Double {
        // Converti byte a megabyte
        let megabyteValue = self * (1024 * 1024)

        return megabyteValue
    }
    
    func byteToGB() -> Double {
        let gb = self / (1024 * 1024 * 1024)
        return gb// String(format: "%.2f MB", gb)
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

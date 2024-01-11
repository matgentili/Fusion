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
}

extension Double {
    func rounded(to decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }
}

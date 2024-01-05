//
//  CGFloat+Extension.swift
//  Fusion
//
//  Created by Matteo Gentili on 05/01/24.
//

import Foundation

extension CGFloat {
    
    func toMB() -> String {
        // Converti byte a megabyte
        let megabyteValue = self / (1024 * 1024)
        // Formatta il risultato con due cifre decimali dopo la virgola
        let formattedValue = String(format: "%.2f MB", megabyteValue)

        return formattedValue
    }
}
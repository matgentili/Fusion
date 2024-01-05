//
//  Date+Extension.swift
//  Fusion
//
//  Created by Matteo Gentili on 05/01/24.
//

import Foundation

extension Date {
    func italianDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

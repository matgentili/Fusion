//
//  Item.swift
//  Fusion
//
//  Created by Matteo Gentili on 29/12/23.
//

import Foundation

struct Item: Codable, Identifiable {
    var id: UUID
    var user: String
    var path: String
    
    func toDictionary() -> [String: Any]?{
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return dictionary
            }
        } catch {
            print("Errore durante la conversione dell'oggetto in dizionario: \(error.localizedDescription)")
        }
        return nil
    }
}

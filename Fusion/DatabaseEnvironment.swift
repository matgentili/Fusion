//
//  DatabaseEnvironment.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import Foundation
import SwiftUI
import FirebaseDatabaseSwift
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Combine


class DatabaseEnvironment: ObservableObject {
//    @Published var db: CharmDatabase = CharmDatabase(orders: []) {
//        didSet {
//            Utils.shared.numberOfOrders = db.orders.count
//        }
//    }
//    
//    private lazy var databasePath: DatabaseReference? = {
//        let ref = Database.database().reference()
//        return ref
//    }()
//    
//    private let encoder = JSONEncoder()
//    private let decoder = JSONDecoder()
//
//    private let child = "orders"
//    
//    private var userService: UserService = UserService()
//    private var cancellables: [AnyCancellable] = []
//    
//    init(){
//        self.getCurrentUserID().sink(receiveCompletion: { completion in
//            switch completion {
//            case let .failure(error):
//                print(error.localizedDescription)
//                // In case of failure it starts the parse from the local file menu.json
//            case .finished:
//                print("Login completed")
//                try? self.readDatabase()
//            }
//        }, receiveValue: { userId in
//            print("Current User ID: \(userId)")
//        }).store(in: &self.cancellables)
//    }
//
//    private func getCurrentUserID() -> AnyPublisher<String, Error> {
//        return userService.currentUser().flatMap { user -> AnyPublisher<String, Error> in
//            if let userId = user?.uid {
//                return Just(userId)
//                    .setFailureType(to: Error.self)
//                    .eraseToAnyPublisher()
//            } else {
//                print("User logged in anonymously")
//                return self.userService
//                    .signInAnonymously()
//                    .map { $0.uid }
//                    .eraseToAnyPublisher()
//            }
//        }.eraseToAnyPublisher()
//    }
//    
//    func readDatabase() throws {
//        self.databasePath?.child(child).observe(.value, with: { [self] snapshot in
//            // This is the snapshot of the data at the moment in the Firebase database
//            // To get value from the snapshot, we user snapshot.value
//            
//            if snapshot.exists() {
//                guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any) else {
//                    return
//                }
//                do {
//                    let orders = try decoder.decode([Order].self, from: data)
//                    db.orders = orders.reversed()
//                    print(db.orders)
//                    db.printNotes()
//                    
//                } catch let error {
//                    print(error)
//                }
//            } else {
//                print("Il db non contiene il child: \(child)")
//            }
//        })
//    }
//    
//    func writeDatabase(value: Any, id: String) {
//        //self.databasePath?.setValue(value)
//        self.databasePath?.child(child).child(id).setValue(value)
//    }
//    
//    func removeFromDatabase(id: String){
//        self.databasePath?.child(child).child(id).removeValue(completionBlock: { error, _  in
//            if let error = error {
//                print("removeFromDatabase error \(error)")
//            } else {
//                print("removed")
//            }
//        })
//    }
}

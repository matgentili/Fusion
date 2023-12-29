//
//  SplashVC.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import UIKit

class SplashVC: UIViewController {
    
    override func viewDidLoad() {
        if let navigationController = self.navigationController {
            let coordinator = Coordinator<Router>.init(navigationController: navigationController, startingRoute: .signIn)
            coordinator.start()
        }
    }
}

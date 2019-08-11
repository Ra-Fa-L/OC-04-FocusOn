//
//  StartFactory.swift
//  FocusOn
//
//  Created by Rafal Padberg on 10.03.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class StartFactory {
    
    static func showIn(window: UIWindow) {
        
        let tabBarController = CustomTabBarController()
        let navigationController = UINavigationController()
        navigationController.configure()
        
//        GoalData.createALotOfDataScenario(numberOfDays: 333)
        
        navigationController.setViewControllers([tabBarController], animated: false)
        
        window.rootViewController = navigationController
    }
}

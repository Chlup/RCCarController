//
//  AppDelegate.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 12/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let flowCoordinator = FlowCoordinatorFactory().make()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let rootController = flowCoordinator.start()
        let navController = UINavigationController(rootViewController: rootController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        return true
    }

}


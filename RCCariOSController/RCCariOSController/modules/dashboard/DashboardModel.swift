//
//  DashboardModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

protocol DashboardModel {
    func start()
    func stop()
}

class DashboardModelImpl {

    struct Dependencies {
        let accelerometerManager = DI.getAccelerometerDataManager()
    }

    let deps = Dependencies()

    init() { }
}

extension DashboardModelImpl: DashboardModel {
    func start() { deps.accelerometerManager.start() }
    func stop() { deps.accelerometerManager.stop() }
}

//
//  AccelerometerDataManager.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

extension DI {
    static let getAccelerometerDataManager = bind(AccelerometerDataManager.self) { AccelerometerDataManagerImpl.sharedInstance }
}

protocol AccelerometerDataManager {
    func start()
    func stop()
}

class AccelerometerDataManagerImpl {
    static let sharedInstance = AccelerometerDataManagerImpl()

    struct Dependencies {
        let btManager = DI.getBTManager()
    }

    let deps = Dependencies()

    init() { }
}

extension AccelerometerDataManagerImpl: AccelerometerDataManager {
    func start() {
        deps.btManager.startReceivingAccelerometerData()
    }

    func stop() {
        deps.btManager.stopReceivingAccelerometerData()
    }
}

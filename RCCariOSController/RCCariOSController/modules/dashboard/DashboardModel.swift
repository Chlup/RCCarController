//
//  DashboardModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift

protocol DashboardModel {
    var accelerometerDataStream: Observable<(Int, Int)> { get }
    func start()
    func stop()
}

class DashboardModelImpl {

    struct Dependencies {
        let accelerometerManager = DI.getAccelerometerDataManager()
        let btManager = DI.getBTManager()
    }

    let deps = Dependencies()

    init() { }
}

extension DashboardModelImpl: DashboardModel {
    var accelerometerDataStream: Observable<(Int, Int)> {
        return deps.accelerometerManager.accelerometerDataStream
            .map { x, y in
                let angleX = x.interpolate(fromLow: 0, fromHigh: 200, toLow: 0, toHigh: 180) - 90
                let angleY = y.interpolate(fromLow: 0, fromHigh: 200, toLow: 0, toHigh: 180) - 90
                return (angleX, angleY)
            }
    }

    func start() {
        deps.accelerometerManager.start()
    }
    func stop() { deps.accelerometerManager.stop() }
}

private extension Int {
    func interpolate(fromLow: Int, fromHigh: Int, toLow: Int, toHigh: Int) -> Int {
        return toLow + (toHigh - toLow) * (self - fromLow) / (fromHigh - fromLow)
    }
}

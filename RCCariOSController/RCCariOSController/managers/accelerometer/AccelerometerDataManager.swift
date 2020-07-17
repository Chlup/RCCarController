//
//  AccelerometerDataManager.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift

extension DI {
    static let getAccelerometerDataManager = bind(AccelerometerDataManager.self) { AccelerometerDataManagerImpl.sharedInstance }
}

protocol AccelerometerDataManager {
    var accelerometerDataStream: Observable<(Int, Int)> { get }
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

    var accelerometerDataStream: Observable<(Int, Int)> {
        // Here we are receiving data with two bytes. Every byte is in range 0...20 where 0 is -90 degrees and 20 90 degrees.
        return deps.btManager.accelerometerDataStream
            .filter { $0.count == 2 }
            .map { (Int($0[0]), Int($0[1])) }
    }

    func start() {
        deps.btManager.startReceivingAccelerometerData()
    }

    func stop() {
        deps.btManager.stopReceivingAccelerometerData()
    }
}

//
//  StatusModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 04/08/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift

struct Coordinates {
    let lon: Double
    let lat: Double
}

protocol CurrentPositionModel {
    var coordinatesStream: Observable<Coordinates> { get }

    func start()
    func stop()
}

class CurrentPositionModelImpl {

    struct Dependencies {
        let btManager = DI.getBTManager()
        let commandsManager = DI.getCommandsManager()
    }

    private let deps = Dependencies()

    init() { }
}

extension CurrentPositionModelImpl: CurrentPositionModel {
    var coordinatesStream: Observable<Coordinates> {
        return deps.btManager.currentPositionStream
            .buffer(timeSpan: .seconds(3600), count: 2, scheduler: MainScheduler.instance)
            .map { rawCoordinates in
                let lon = rawCoordinates[0].data.data.withUnsafeBytes { $0.load(as: Double.self) }
                let lat = rawCoordinates[1].data.data.withUnsafeBytes { $0.load(as: Double.self) }
                return Coordinates(lon: lon, lat: lat)
            }
    }

    func start() {
        deps.commandsManager.startUpdatingCurrentPosition()
        deps.commandsManager.commit()
    }

    func stop() {
        deps.commandsManager.stopUpdatingCurrentPosition()
        deps.commandsManager.commit()
    }
}

//
//  StatusModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 04/08/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift

struct GPSRecordingStatus {
    let requested: Bool
    let inProgress: Bool
}

protocol GPSRecordingModel {
    var statusStream: Observable<GPSRecordingStatus> { get }

    func start()
    func stop()

    func startGPSRecording()
    func stopGPSRecording()
}

class GPSRecordingModelImpl {

    struct Dependencies {
        let btManager = DI.getBTManager()
        let commandsManager = DI.getCommandsManager()
    }

    private let deps = Dependencies()

    init() { }
}

extension GPSRecordingModelImpl: GPSRecordingModel {
    var statusStream: Observable<GPSRecordingStatus> {
        return deps.btManager.statusDataStream
            .map { Statuses(data: $0.data) }
            .map { GPSRecordingStatus(requested: $0.contains(.shouldStartGPSSession), inProgress: $0.contains(.gpsSessionInProgress)) }
    }

    func start() {
        deps.commandsManager.startReceivingStatus()
        deps.commandsManager.commit()
    }

    func stop() {
        deps.commandsManager.stopReceivingStatus()
        deps.commandsManager.commit()
    }

    func startGPSRecording() {
        deps.commandsManager.startRecordingGPS()
        deps.commandsManager.commit()
    }

    func stopGPSRecording() {
        deps.commandsManager.stopRecordingGPS()
        deps.commandsManager.commit()
    }
}

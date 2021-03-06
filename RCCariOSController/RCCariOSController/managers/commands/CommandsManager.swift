//
//  CommandsManager.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 04/08/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift

extension DI {
    static let getCommandsManager = bind(CommandsManager.self) { CommandsManagerImpl.sharedInstance }
}

struct Commands: OptionSet {
    let rawValue: Int32
    init(rawValue: Int32) { self.rawValue = rawValue }

    init(data: Data) {
        rawValue = data.withUnsafeBytes { $0.load(as: Int32.self) }
    }

    static let enableAccelerometer = Commands(rawValue: 1 << 0)
    static let startGPSSession = Commands(rawValue: 1 << 1)
    static let updateStatus = Commands(rawValue: 1 << 2)
    static let updateHDOP = Commands(rawValue: 1 << 3)
    static let updateCurrentPosition = Commands(rawValue: 1 << 4)
    static let updateCommands = Commands(rawValue: 1 << 5)

    var data: Data {
        var value = rawValue
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}

struct Statuses: OptionSet {
    let rawValue: Int32
    init(rawValue: Int32) { self.rawValue = rawValue }

    init(data: Data) {
        rawValue = data.withUnsafeBytes { $0.load(as: Int32.self) }
    }

    static let accelerometerSetupError = Statuses(rawValue: 1 << 0)
    static let accelerometerReadError = Statuses(rawValue: 1 << 1)
    static let storageSetupError = Statuses(rawValue: 1 << 2)
    static let gpsHasValidData = Statuses(rawValue: 1 << 3)
    static let shouldStartGPSSession = Statuses(rawValue: 1 << 4)
    static let gpsSessionInProgress = Statuses(rawValue: 1 << 5)
    static let storeGPSDataError = Statuses(rawValue: 1 << 6)
    static let errorReadingGPSData = Statuses(rawValue: 1 << 7)
}

protocol CommandsManager {
    func start()
    func commit()

    func startReceivingAccelerometerData()
    func stopReceivingAccelerometerData()

    func startReceivingHDOP()
    func stopReceivingHDOP()

    func startReceivingStatus()
    func stopReceivingStatus()

    func startUpdatingCurrentPosition()
    func stopUpdatingCurrentPosition()

    func startRecordingGPS()
    func stopRecordingGPS()
}

class CommandsManagerImpl {
    fileprivate static let sharedInstance = CommandsManagerImpl()

    struct Dependencies {
        let btManager = DI.getBTManager()
    }

    private let deps = Dependencies()
    private var command: Commands = []
    private var status: Statuses = []
    private let bag = DisposeBag()

    init() { }

    func subscribeToCommandsStream() {
        deps.btManager.receivedCommandsStream
            .map { Commands(data: $0.data) }
            .debug()
            .subscribe(
                onNext: { [weak self] receivedCommand in self?.command = receivedCommand }
            )
            .disposed(by: bag)
    }
}

extension CommandsManagerImpl: CommandsManager {
    func start() {
        subscribeToCommandsStream()
    }

    func commit() {
        deps.btManager.updateCommand(command: command)
    }

    func startReceivingAccelerometerData() { command.insert(.enableAccelerometer) }
    func stopReceivingAccelerometerData() { command.remove(.enableAccelerometer) }
    func startReceivingHDOP() { command.insert(.updateHDOP) }
    func stopReceivingHDOP() { command.remove(.updateHDOP) }
    func startReceivingStatus() { command.insert(.updateStatus) }
    func stopReceivingStatus() { command.remove(.updateStatus) }
    func startUpdatingCurrentPosition() { command.insert(.updateCurrentPosition) }
    func stopUpdatingCurrentPosition() { command.remove(.updateCurrentPosition) }
    func startRecordingGPS() { command.insert(.startGPSSession) }
    func stopRecordingGPS() { command.remove(.startGPSSession) }
}

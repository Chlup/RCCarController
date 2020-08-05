//
//  BTManager.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import RxCocoa

extension DI {
    static var getBTManager = bind(BTManager.self) { BTManagerImpl.sharedInstance }
}

enum BTCharacteristic: CaseIterable {
    case accelerometer
    case command
    case status
    case hdop
    case currentPosition

    var uuid: CBUUID {
        switch self {
        case .accelerometer: return CBUUID(string: "3178812e-f8ca-48cb-93f6-a3387bf41a63")
        case .command: return CBUUID(string: "f6791979-f52a-4d4a-98d8-af5c3ea3cf68")
        case .status: return CBUUID(string: "1faa2a5c-0825-48d0-bfa8-e15b84145116")
        case .hdop: return CBUUID(string: "5ea3439d-c263-41ac-a74d-68015b7a7d91")
        case .currentPosition: return CBUUID(string: "67657b6a-6291-4166-b2bb-5caa09d91f95")
        }
    }
}

enum BTConnectionState {
    case disconnected
    case connecting
    case connected;
}

struct BTConnectionStatus {
    let state: BTConnectionState
    let connectedDevice: BTDevice?
    let devices: [BTDevice]

    static var `default`: BTConnectionStatus {
        return BTConnectionStatus(state: .disconnected, connectedDevice: nil, devices: [])
    }
}

enum BTCoordinateType {
    case lon
    case lat
}

struct BTCoordinate {
    let type: BTCoordinateType
    let data: Data
}

struct BTData<Type> {
    let connectionStatus: BTConnectionStatus
    let data: Type
}

protocol BTManager {
    var bluetoothConnectionStream: Observable<BTConnectionStatus> { get }
    var accelerometerDataStream: Observable<BTData<Data>> { get }
    var statusDataStream: Observable<BTData<Data>> { get }
    var hdopDataStream: Observable<BTData<Data>> { get }
    var currentPositionStream: Observable<BTData<BTCoordinate>> { get }
    var receivedCommandsStream: Observable<BTData<Data>> { get }

    func start()
    func connect(to device: BTDevice)
    func disconnect()

    func updateCommand(command: Commands)
}

class BTManagerImpl: NSObject {
    fileprivate static let sharedInstance = BTManagerImpl()

    private enum Constants {
        static let serviceUUID = CBUUID(string: "07838daa-b3df-4ca2-892c-0844b6969519")
    }

    private var connectedDevice: BTDevice? {
        didSet {
            lastConnectedDeviceIdentifier = connectedDevice?.identifier
            updateOutputStream()
        }
    }

    private var lastConnectedDeviceIdentifier: String? {
        set { UserDefaults.standard.setValue(newValue, forKey: "lastConnectedDeviceIdentifier") }
        get { UserDefaults.standard.value(forKey: "lastConnectedDeviceIdentifier") as? String }
    }

    private let queue = DispatchQueue(label: "BTManagerImpl", qos: .default)
    private lazy var scheduler: SerialDispatchQueueScheduler = {
        SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: "BTManagerImpl")
    }()
    private lazy var centralManager: CBCentralManager = {
        return CBCentralManager(delegate: self, queue: queue)
    }()

    private var timer: Timer?
    private var devices = Set<BTDevice>()
    private let outputRelay = BehaviorRelay<BTConnectionStatus?>(value: nil)

    private let accelerometerDataRelay = PublishRelay<BTData<Data>>()
    private let statusDataRelay = PublishRelay<BTData<Data>>()
    private let hdopDataRelay = PublishRelay<BTData<Data>>()
    private let currentPositionDataRelay = PublishRelay<BTData<BTCoordinate>>()
    private let receivedCommandsDataRelay = PublishRelay<BTData<Data>>()

    private var receivedLon = false

    private var state: BTConnectionState = .disconnected;
    private var status: BTConnectionStatus {
        return BTConnectionStatus(state: state, connectedDevice: connectedDevice, devices: Array(devices).sorted())
    }

    override init() {
        super.init()
    }

    private func scanForPeripherals() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals( withServices: [Constants.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        timer = Timer(interval: 3, repeats: false) { [weak self] in self?.stopScanning() }
    }

    private func stopScanning() {
        centralManager.stopScan()
    }

    private func updateOutputStream() {
        outputRelay.accept(status)
    }
}

extension BTManagerImpl: BTManager {
    var bluetoothConnectionStream: Observable<BTConnectionStatus> {
        return outputRelay
            .asObservable()
            .ignoreNil()
    }

    var accelerometerDataStream: Observable<BTData<Data>> {
        return accelerometerDataRelay.asObservable()
    }

    var statusDataStream: Observable<BTData<Data>> {
        return statusDataRelay.asObservable()
    }

    var hdopDataStream: Observable<BTData<Data>> {
        return hdopDataRelay.asObservable()
    }

    var currentPositionStream: Observable<BTData<BTCoordinate>> {
        return currentPositionDataRelay.asObservable()
    }

    var receivedCommandsStream: Observable<BTData<Data>> {
        return receivedCommandsDataRelay.asObservable()
    }

    func start() {
        _ = centralManager
        scanForPeripherals()
    }

    func connect(to device: BTDevice) {
        disconnect()
        state = .connecting
        device.isConnected = true
        device.peripheral.delegate = self
        connectedDevice = device
        centralManager.connect(device.peripheral, options: nil)
    }

    func disconnect() {
        state = .disconnected
        guard let device = connectedDevice else { return }
        centralManager.cancelPeripheralConnection(device.peripheral)
        device.isConnected = false
        connectedDevice = nil
    }

    func updateCommand(command: Commands) {
        guard let characteristic = connectedDevice?.characteristics[.command] else { return }
        print("Writing command \(command)")
        connectedDevice?.peripheral.writeValue(command.data, for: characteristic, type: .withResponse)
    }
}

extension BTManagerImpl: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update \(central.state.rawValue)")
        scanForPeripherals()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let newDevice = BTDevice(peripheral: peripheral)
        devices.insert(newDevice)
        updateOutputStream()

        if connectedDevice == nil && peripheral.identifier.uuidString == lastConnectedDeviceIdentifier {
            connect(to: newDevice)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect to \(peripheral.name ??? "unknown")")
        guard peripheral.identifier.uuidString == connectedDevice?.identifier else { return }
        peripheral.discoverServices([Constants.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Did fail to connect \(error ??? "-")")
        if peripheral.identifier.uuidString == connectedDevice?.identifier {
            disconnect()
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral peripheral \(peripheral.name ??? "unknown")")
        if connectedDevice == nil || peripheral.identifier.uuidString == connectedDevice?.identifier {
            disconnect()
        }
    }
}

extension BTManagerImpl: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Peripheral \(peripheral.name ??? "unknown") didDiscoverServices \(error ??? "-")")
        guard peripheral.identifier.uuidString == connectedDevice?.identifier else { return }

        (peripheral.services ?? []).forEach { service in
            peripheral.discoverCharacteristics(BTCharacteristic.allCases.map { $0.uuid }, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard peripheral.identifier.uuidString == connectedDevice?.identifier else { return }
        var recognizedCharacteristicsCount = 0
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                switch characteristic.uuid {
                case BTCharacteristic.accelerometer.uuid:
                    recognizedCharacteristicsCount += 1
                    connectedDevice?.characteristics[.accelerometer] = characteristic
//                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Accelerometer characteristic found")

                case BTCharacteristic.command.uuid:
                    recognizedCharacteristicsCount += 1
                    connectedDevice?.characteristics[.command] = characteristic
//                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Command characteristic found")

                case BTCharacteristic.status.uuid:
                    recognizedCharacteristicsCount += 1
                    connectedDevice?.characteristics[.status] = characteristic
//                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Status characteristic found.")

                case BTCharacteristic.hdop.uuid:
                    recognizedCharacteristicsCount += 1
                    connectedDevice?.characteristics[.hdop] = characteristic
//                    peripheral.setNotifyValue(true, for: characteristic)
                    print("HDOP characteristic found.")

                case BTCharacteristic.currentPosition.uuid:
                    recognizedCharacteristicsCount += 1
                    connectedDevice?.characteristics[.currentPosition] = characteristic
//                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Current position characteristic found.")

                default:
                    print("Found unknown characteristic")
                }
            }
        }

        if recognizedCharacteristicsCount == BTCharacteristic.allCases.count {
            peripheral.setNotifyValue(true, for: (connectedDevice?.characteristics[.command])!)
            updateCommand(command: [.updateCommands])

            let characteristics = connectedDevice?.characteristics ?? [:]
            characteristics
                .filter { $0.key != .command }
                .forEach { peripheral.setNotifyValue(true, for: $0.value) }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Peripheral \(peripheral.name ??? "unknown") didUpdateNotificationStateFor \(error ??? "-")")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case BTCharacteristic.command.uuid:
            print("Peripheral \(peripheral.name ??? "unknown") didUpdateValueFor command")
            guard let data = characteristic.value else { return }
            let commands = Commands(data: data)
            // On the start we write `updateCommands` to this characteristic so we want to ignore this value.
            guard commands != .updateCommands else { return }
            state = .connected
            updateOutputStream()
            receivedCommandsDataRelay.accept(BTData(connectionStatus: status, data: data))

        case BTCharacteristic.accelerometer.uuid:
            print("Peripheral \(peripheral.name ??? "unknown") didUpdateValueFor accelerometer")
            guard let data = characteristic.value else { return }
            accelerometerDataRelay.accept(BTData(connectionStatus: status, data: data))

        case BTCharacteristic.status.uuid:
            print("Peripheral \(peripheral.name ??? "unknown") didUpdateValueFor status")
            guard let data = characteristic.value else { return }
            statusDataRelay.accept(BTData(connectionStatus: status, data: data))

        case BTCharacteristic.hdop.uuid:
            print("Peripheral \(peripheral.name ??? "unknown") didUpdateValueFor hdop")
            guard let data = characteristic.value else { return }
            hdopDataRelay.accept(BTData(connectionStatus: status, data: data))

        case BTCharacteristic.currentPosition.uuid:
            print("Peripheral \(peripheral.name ??? "unknown") didUpdateValueFor current position")
            guard let data = characteristic.value else { return }
            let finalData: BTData<BTCoordinate>
            if receivedLon {
                finalData = BTData(connectionStatus: status, data: BTCoordinate(type: .lat, data: data))
            } else {
                finalData = BTData(connectionStatus: status, data: BTCoordinate(type: .lon, data: data))
            }

            receivedLon = !receivedLon

            currentPositionDataRelay.accept(finalData)

        default:
            break
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Peripheral \(peripheral.name ??? "unknown") didWriteValueFor \(error ??? "-")")
    }
}

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
    case config

    var uuid: CBUUID {
        switch self {
        case .accelerometer: return CBUUID(string: "3178812e-f8ca-48cb-93f6-a3387bf41a63")
        case .config: return CBUUID(string: "f6791979-f52a-4d4a-98d8-af5c3ea3cf68")
        }
    }
}

protocol BTManager {
    var devicesStream: Observable<(BTDevice?, Set<BTDevice>)> { get }
    func start()
    func connect(to device: BTDevice)
    func disconnect()

    func startReceivingAccelerometerData()
    func stopReceivingAccelerometerData()
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
    private var outputRelay = BehaviorRelay<(BTDevice?, Set<BTDevice>)>(value: (nil, []))

    private var config = BTConfig()

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
        outputRelay.accept((connectedDevice, devices))
    }

    private func writeConfig() {
        guard let characteristic = connectedDevice?.characteristics[.config] else { return }
        print("Writing Config \(config.data.description)")
        connectedDevice?.peripheral.writeValue(config.data, for: characteristic, type: .withResponse)
    }
}

extension BTManagerImpl: BTManager {
    var devicesStream: Observable<(BTDevice?, Set<BTDevice>)> {
        return outputRelay
            .asObservable()
    }

    func start() {
        _ = centralManager
        scanForPeripherals()
    }

    func connect(to device: BTDevice) {
        disconnect()
        device.isConnected = true
        device.peripheral.delegate = self
        connectedDevice = device
        centralManager.connect(device.peripheral, options: nil)
    }

    func disconnect() {
        guard let device = connectedDevice else { return }
        centralManager.cancelPeripheralConnection(device.peripheral)
        device.isConnected = false
        connectedDevice = nil
    }

    func startReceivingAccelerometerData() {
        config.insert(.sendAccelerometerData)
        writeConfig()
    }

    func stopReceivingAccelerometerData() {
        config.remove(.sendAccelerometerData)
        writeConfig()
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
        if peripheral.identifier.uuidString == connectedDevice?.identifier {
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
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                switch characteristic.uuid {
                case BTCharacteristic.accelerometer.uuid:
                    connectedDevice?.characteristics[.accelerometer] = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Accelerometer characteristic found")

                case BTCharacteristic.config.uuid:
                    connectedDevice?.characteristics[.config] = characteristic
                    print("Config characteristic found")

                default:
                    print("Found unknown characteristic")
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Peripheral \(peripheral.name ??? "unknown") didUpdateNotificationStateFor \(error ??? "-")")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Peripheral \(peripheral.name ??? "unknown") didUpdateValueFor")
        print(characteristic.value ??? "-no value-")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Peripheral \(peripheral.name ??? "unknown") didWriteValueFor \(error ??? "-")")
    }
}

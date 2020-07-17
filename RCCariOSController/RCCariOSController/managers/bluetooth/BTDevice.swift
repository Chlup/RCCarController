//
//  BTDevice.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTDevice {
    let peripheral: CBPeripheral
    var isConnected = false

    var name: String { return peripheral.name ?? "(unknown)" }
    var identifier: String { peripheral.identifier.uuidString }

    var characteristics: [BTCharacteristic: CBCharacteristic] = [:]

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
}

extension BTDevice: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension BTDevice: Equatable {
    static func == (lhs: BTDevice, rhs: BTDevice) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension BTDevice: Comparable {
    static func < (lhs: BTDevice, rhs: BTDevice) -> Bool {
        return lhs.identifier < rhs.identifier
    }
}

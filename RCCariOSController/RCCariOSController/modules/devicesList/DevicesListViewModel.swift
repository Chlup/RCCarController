//
//  DevicesListViewModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct DevicesListFlow {
    let close: () -> Void
}

protocol DevicesListViewModel {
    var devicesStream: Driver<BTConnectionStatus> { get }

    func closeTapped()

    func tapOnConnectButton(with device: BTDevice)
    func tapOnRefresh()
    func start()
}

class DevicesListViewModelImpl {

    struct Dependencies {
        let btManager = DI.getBTManager()
    }

    let deps = Dependencies()
    let model: DevicesListModel
    let flow: DevicesListFlow
    init(model: DevicesListModel, flow: DevicesListFlow) {
        self.model = model
        self.flow = flow
    }
}

extension DevicesListViewModelImpl: DevicesListViewModel {
    var devicesStream: Driver<BTConnectionStatus> {
        return model.devicesStream
            .asDriver(onErrorJustReturn: BTConnectionStatus(state: .disconnected, connectedDevice: nil, devices: []))
    }

    func tapOnConnectButton(with device: BTDevice) {
        if device.isConnected {
            deps.btManager.disconnect()
        } else {
            deps.btManager.connect(to: device)
        }
    }

    func tapOnRefresh() {
        deps.btManager.start()
    }

    func start() { model.start() }

    func closeTapped() { flow.close() }
}

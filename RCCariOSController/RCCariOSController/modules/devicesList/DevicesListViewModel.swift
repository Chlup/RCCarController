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
    let didConnectDevice: (String?) -> Void
    let didDisconnectDevice: () -> Void
}

protocol DevicesListViewModel {
    var devicesStream: Driver<BTConnectionStatus> { get }

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

    private var status: BTConnectionStatus = .default

    init(model: DevicesListModel, flow: DevicesListFlow) {
        self.model = model
        self.flow = flow
    }

    private func process(new connectionStatus: BTConnectionStatus) {
        defer { status = connectionStatus }
        guard connectionStatus.state != status.state else { return }

        switch connectionStatus.state {
        case .disconnected:
            flow.didDisconnectDevice()
        case .connected:
            flow.didConnectDevice(connectionStatus.connectedDevice?.name)
        case .connecting:
            break
        }
    }
}

extension DevicesListViewModelImpl: DevicesListViewModel {
    var devicesStream: Driver<BTConnectionStatus> {
        return model.devicesStream
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] connectionStatus in self?.process(new: connectionStatus) })
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
}

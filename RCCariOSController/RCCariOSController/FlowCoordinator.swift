//
//  FlowCoordinator.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import UIKit

protocol FlowCoordinator {
    func start() -> UIViewController
}

struct FlowCoordinatorFactory {
    func make() -> FlowCoordinator {
        return FlowCoordinatorImpl()
    }
}

class FlowCoordinatorImpl {

    struct Dependencies {
        let btManager = DI.getBTManager()
        let commandsManager = DI.getCommandsManager()
    }

    let deps = Dependencies()

    init() { }

    var navigationController: UINavigationController? {
        return UIApplication.shared.windows.first?.rootViewController as? UINavigationController
    }

    private func makeHome(deviceName: String?) -> UIViewController {
        let flow = HomeFlow(
            dashboardTapped: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.makeDashboard(), animated: true)
            },
            statusTapped: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.makeStatus(), animated: true)
            },
            currentPositionTapped: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.makeCurrentPosition(), animated: true)
            },
            gpsRecordingTapped: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.makeGPSRecording(), animated: true)
            }
        )

        let viewModel = HomeViewModelImpl(flow: flow)
        return HomeController(viewModel: viewModel, deviceName: deviceName)
    }

    private func makeDevicesList() -> UIViewController {
        let flow = DevicesListFlow(
            didConnectDevice: { [weak self] deviceName in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.makeHome(deviceName: deviceName), animated: true)
            },
            didDisconnectDevice: { [weak self] in
                guard let nc = self?.navigationController else { return }
                nc.popToRootViewController(animated: true)
                let alert = UIAlertController(title: "", message: "Car did disconnect.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in }))
                nc.present(alert, animated: true, completion: nil)
            }
        )

        let model = DevicesListModelImpl()
        let viewModel = DevicesListViewModelImpl(model: model, flow: flow)
        return DevicesListController(viewModel: viewModel)
    }

    private func makeDashboard() -> UIViewController {
        let flow = DashboardFlow(
            close: { [weak self] in self?.navigationController?.popViewController(animated: true) }
        )

        let model = DashboardModelImpl()
        let viewModel = DashboardViewModelImpl(model: model, flow: flow)
        return DashboardController(viewModel: viewModel)
    }

    func makeStatus() -> UIViewController {
        let flow = StatusFlow(
            close: { [weak self] in self?.navigationController?.popViewController(animated: true) }
        )

        let model = StatusModelImpl()
        let viewModel = StatusViewModelImpl(model: model, flow: flow)
        return StatusController(viewModel: viewModel)
    }

    func makeCurrentPosition() -> UIViewController {
        let flow = CurrentPositionFlow(
            close: { [weak self] in self?.navigationController?.popViewController(animated: true) }
        )

        let model = CurrentPositionModelImpl()
        let viewModel = CurrentPositionViewModelImpl(model: model, flow: flow)
        return CurrentPositionController(viewModel: viewModel)
    }

    func makeGPSRecording() -> UIViewController {
        let flow = GPSRecordingFlow(
            close: { [weak self] in self?.navigationController?.popViewController(animated: true) }
        )

        let model = GPSRecordingModelImpl()
        let viewModel = GPSRecordingViewModelImpl(model: model, flow: flow)
        return GPSRecordingController(viewModel: viewModel)
    }
}

extension FlowCoordinatorImpl: FlowCoordinator {
    func start() -> UIViewController {
        deps.btManager.start()
        deps.commandsManager.start()
        return makeDevicesList()
    }

}

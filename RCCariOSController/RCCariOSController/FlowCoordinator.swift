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
    }

    let deps = Dependencies()

    init() { }

    var navigationController: UINavigationController? {
        return UIApplication.shared.windows.first?.rootViewController as? UINavigationController
    }

    private func makeHome() -> UIViewController {
        let flow = HomeFlow(
            connectTapped: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.makeDevicesList(), animated: true)
            },
            dashboardTapped: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(self.makeDashboard(), animated: true)
            }
        )

        let viewModel = HomeViewModelImpl(flow: flow)
        return HomeController(viewModel: viewModel)
    }

    private func makeDevicesList() -> UIViewController {
        let flow = DevicesListFlow(
            close: { [weak self] in self?.navigationController?.popViewController(animated: true) }
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
}

extension FlowCoordinatorImpl: FlowCoordinator {
    func start() -> UIViewController {
        deps.btManager.start()
        return makeHome()
    }

}

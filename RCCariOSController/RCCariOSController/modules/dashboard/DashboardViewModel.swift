//
//  DashboardViewModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

struct DashboardFlow {
    let close: () -> Void
}

protocol DashboardViewModel {
    func start()
    func stop()

}

class DashboardViewModelImpl {
    let model: DashboardModel
    let flow: DashboardFlow
    init(model: DashboardModel, flow: DashboardFlow) {
        self.model = model
        self.flow = flow
    }
}

extension DashboardViewModelImpl: DashboardViewModel {
    func start() { model.start() }
    func stop() { model.stop() }
}
